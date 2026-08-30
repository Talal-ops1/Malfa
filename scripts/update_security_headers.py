#!/usr/bin/env python3
"""Generate Vercel security headers with hashes for MALFA's inline scripts."""

from base64 import b64encode
from hashlib import sha256
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
SUPABASE_HTTP = "https://ntpwnrsckacwqzvgoysb.supabase.co"
SUPABASE_WS = "wss://ntpwnrsckacwqzvgoysb.supabase.co"


def inline_script_hashes(html: str) -> list[str]:
    scripts = re.findall(r"<script(?![^>]*\bsrc=)[^>]*>(.*?)</script>", html, re.I | re.S)
    if not scripts:
        raise RuntimeError("no inline script found")
    return ["'sha256-" + b64encode(sha256(script.encode()).digest()).decode() + "'" for script in scripts]


def write_config(folder: str, microphone: bool, google_fonts: bool = False) -> None:
    page = ROOT / folder / "index.html"
    hashes = inline_script_hashes(page.read_text(encoding="utf-8"))
    style_sources = ["'self'", "'unsafe-inline'"]
    font_sources = ["'self'", "data:"]
    if google_fonts:
        style_sources.append("https://fonts.googleapis.com")
        font_sources.append("https://fonts.gstatic.com")
    csp = "; ".join([
        "default-src 'self'",
        "base-uri 'self'",
        "object-src 'none'",
        "frame-ancestors 'none'",
        "form-action 'self'",
        "script-src 'self' " + " ".join(hashes),
        "script-src-attr 'none'",
        "style-src " + " ".join(style_sources),
        "font-src " + " ".join(font_sources),
        f"img-src 'self' data: blob: {SUPABASE_HTTP}",
        f"media-src 'self' blob: {SUPABASE_HTTP}",
        f"connect-src 'self' {SUPABASE_HTTP} {SUPABASE_WS}",
        "worker-src 'self' blob:",
        "manifest-src 'self'",
        "upgrade-insecure-requests",
    ])
    permissions = "microphone=(self)" if microphone else "microphone=()"
    permissions += ", camera=(), geolocation=(), payment=(), usb=(), serial=(), bluetooth=()"
    headers = [
        ("Content-Security-Policy", csp),
        ("X-Content-Type-Options", "nosniff"),
        ("Referrer-Policy", "strict-origin-when-cross-origin"),
        ("Permissions-Policy", permissions),
        ("Cross-Origin-Opener-Policy", "same-origin"),
        ("X-Frame-Options", "DENY"),
        ("Strict-Transport-Security", "max-age=63072000; includeSubDomains; preload"),
        ("Cache-Control", "no-cache"),
    ]
    config = {"headers": [{"source": "/(.*)", "headers": [{"key": k, "value": v} for k, v in headers]}]}
    (ROOT / folder / "vercel.json").write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


write_config("v4", microphone=True)
write_config("admin", microphone=False, google_fonts=True)
print("SECURITY HEADERS GENERATED")
