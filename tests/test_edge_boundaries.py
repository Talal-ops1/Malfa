#!/usr/bin/env python3
"""Non-mutating live checks for Edge Function origin and auth boundaries."""

import ssl
from urllib.error import HTTPError
from urllib.request import Request, urlopen


BASE = "https://ntpwnrsckacwqzvgoysb.supabase.co/functions/v1"
APP_ORIGIN = "https://malfaapp.vercel.app"
ADMIN_ORIGIN = "https://malfaappl.vercel.app"
EVIL_ORIGIN = "https://attacker.invalid"
TLS_CONTEXT = ssl.create_default_context(cafile="/etc/ssl/cert.pem")
PUBLISHABLE_KEY = "sb_publishable_gM0UmkhBzwUNGVV3OnxfFA_IRey-gUp"


def request(path, method="GET", origin=None, data=None):
    headers = {"apikey": PUBLISHABLE_KEY}
    if origin:
        headers["Origin"] = origin
    if data is not None:
        headers["Content-Type"] = "application/json"
        data = data.encode("utf-8")
    req = Request(f"{BASE}/{path}", method=method, headers=headers, data=data)
    try:
        with urlopen(req, timeout=15, context=TLS_CONTEXT) as response:
            return response.status, dict(response.headers)
    except HTTPError as error:
        return error.code, dict(error.headers)


def expect(path, method, origin, status, allow_origin=None, data=None):
    actual, headers = request(path, method, origin, data)
    assert actual == status, f"{path}: expected {status}, got {actual}"
    actual_allow = headers.get("Access-Control-Allow-Origin")
    assert actual_allow == allow_origin, (
        f"{path}: expected allow-origin {allow_origin!r}, got {actual_allow!r}"
    )


for function in ("upload-cover", "delete-account", "summarize-journey", "log-failed-signin"):
    expect(function, "OPTIONS", APP_ORIGIN, 204, APP_ORIGIN)
    expect(function, "POST", EVIL_ORIGIN, 403, None, "{}")

# These calls cannot mutate data because no authenticated identity is supplied.
expect("upload-cover", "POST", APP_ORIGIN, 401, APP_ORIGIN, "{}")
expect("delete-account", "POST", APP_ORIGIN, 401, APP_ORIGIN, "{}")
expect("summarize-journey", "POST", APP_ORIGIN, 401, APP_ORIGIN, "{}")

# Wrong method exits before the failed-login logger parses or stores an attempt.
expect("log-failed-signin", "GET", APP_ORIGIN, 204, APP_ORIGIN)

expect("admin-api?action=stats", "GET", EVIL_ORIGIN, 403, None)
expect("admin-api?action=stats", "GET", ADMIN_ORIGIN, 401, ADMIN_ORIGIN)

print("EDGE BOUNDARIES OK — exact origins, preflight, unauthenticated rejection")
