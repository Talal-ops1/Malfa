#!/usr/bin/env python3
"""Static security contract for every user-controlled MALFA rendering path."""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
APP = (ROOT / "v4" / "index.html").read_text(encoding="utf-8")
ADMIN = (ROOT / "admin" / "index.html").read_text(encoding="utf-8")


def require(source: str, pattern: str, label: str) -> None:
    if not re.search(pattern, source, re.S):
        raise AssertionError(f"missing XSS protection: {label}")


def test_escape_contract(source: str, label: str) -> None:
    match = re.search(r"function esc\(s\)\s*\{(?P<body>.*?)\n\}", source, re.S)
    if not match:
        raise AssertionError(f"{label}: esc() not found")
    body = match.group("body")
    for token in ("&amp;", "&lt;", "&gt;", "&quot;", "&#39;"):
        if token not in body:
            raise AssertionError(f"{label}: esc() does not encode {token}")


test_escape_contract(APP, "consumer")
test_escape_contract(ADMIN, "admin")

# Account identity and public handles.
require(APP, r"esc\(MY_NAME", "account display name")
require(APP, r"esc\(MY_HANDLE", "account handle")

# Catalog and manually-created book title/author/cover attribute output.
require(APP, r"esc\(b\.t\)", "book title")
require(APP, r"esc\(b\.a\)", "book author")
require(APP, r"img src=\"'\+esc\(b\.cover_url\)", "book cover URL")

# Collection titles.
require(APP, r"esc\(c\.title\)", "collection title")
require(APP, r"انعملت مجموعة.*esc\(title\)", "new collection confirmation")

# Invitation names, identifiers, handles, and authorized shared progress.
for pattern, label in (
    (r"esc\(inv\.from_name\)", "invitation sender"),
    (r"data-inviteaccept=\"'\+esc\(inv\.id\)", "invitation accept id"),
    (r"data-invitedecline=\"'\+esc\(inv\.id\)", "invitation decline id"),
    (r"esc\(p\.name", "profile search name"),
    (r"esc\(p\.handle", "profile search handle"),
    (r"esc\(row\.other_name", "shared progress name"),
):
    require(APP, pattern, label)

# Journey notes, transcripts, and Menara paragraphs.
require(APP, r"esc\(latest\.row\.note\)", "home reflection")
require(APP, r"esc\(e\.q\)", "journey note")
require(APP, r"map\(function\(p\)\{return '<p>'\+esc\(p\)", "Menara paragraph")

# Admin API values rendered into text and attribute contexts.
for pattern, label in (
    (r"data-uid=\"'\+esc\(u\.id\)", "admin user id"),
    (r"esc\(u\.name", "admin user name"),
    (r"esc\(u\.email", "admin user email"),
    (r"esc\(ev\.failure_reason", "admin failure reason"),
    (r"esc\(EVENT_LABELS\[ev\.event_type\]\|\|ev\.event_type\)", "admin event type"),
):
    require(ADMIN, pattern, label)

# There must be no event-handler attributes or javascript: URLs in either app.
for source, label in ((APP, "consumer"), (ADMIN, "admin")):
    if re.search(r"\son[a-z]+\s*=", source, re.I):
        raise AssertionError(f"{label}: inline event handler found")
    if re.search(r"javascript\s*:", source, re.I):
        raise AssertionError(f"{label}: javascript URL found")

print("XSS OK — account, books, collections, invitations, notes, Menara, admin")
