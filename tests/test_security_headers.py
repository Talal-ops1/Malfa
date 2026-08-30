#!/usr/bin/env python3
"""Verify both Vercel applications ship the required production headers."""

from base64 import b64encode
from hashlib import sha256
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = {
    "content-security-policy",
    "x-content-type-options",
    "referrer-policy",
    "permissions-policy",
    "cross-origin-opener-policy",
    "x-frame-options",
    "strict-transport-security",
}


for folder in ("v4", "admin"):
    html = (ROOT / folder / "index.html").read_text(encoding="utf-8")
    config = json.loads((ROOT / folder / "vercel.json").read_text(encoding="utf-8"))
    headers = {item["key"].lower(): item["value"] for item in config["headers"][0]["headers"]}
    missing = REQUIRED - headers.keys()
    if missing:
        raise AssertionError(f"{folder}: missing headers {sorted(missing)}")
    csp = headers["content-security-policy"]
    for directive in ("default-src 'self'", "object-src 'none'", "frame-ancestors 'none'", "script-src-attr 'none'"):
        if directive not in csp:
            raise AssertionError(f"{folder}: missing CSP directive {directive}")
    if "script-src 'self' 'unsafe-inline'" in csp:
        raise AssertionError(f"{folder}: unsafe inline scripts allowed")
    scripts = re.findall(r"<script(?![^>]*\bsrc=)[^>]*>(.*?)</script>", html, re.I | re.S)
    for script in scripts:
        digest = "'sha256-" + b64encode(sha256(script.encode()).digest()).decode() + "'"
        if digest not in csp:
            raise AssertionError(f"{folder}: stale inline-script CSP hash")
    permissions = headers["permissions-policy"]
    expected_microphone = "microphone=(self)" if folder == "v4" else "microphone=()"
    if expected_microphone not in permissions:
        raise AssertionError(f"{folder}: incorrect microphone policy")
    if headers["x-content-type-options"] != "nosniff":
        raise AssertionError(f"{folder}: nosniff missing")
    if headers["referrer-policy"] != "strict-origin-when-cross-origin":
        raise AssertionError(f"{folder}: incorrect referrer policy")

print("SECURITY HEADERS OK — consumer and admin")
