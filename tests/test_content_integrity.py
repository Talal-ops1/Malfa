#!/usr/bin/env python3
"""Static product-contract checks for the current MALFA build."""

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HTML = (ROOT / "v4" / "index.html").read_text(encoding="utf-8")
COVERS = ROOT / "v4" / "assets" / "covers"

for forbidden in ("خواطر", "دردشة", "كليلة ودمنة", "البخلاء", "حي بن يقظان"):
    assert forbidden not in HTML, f"forbidden product copy remains: {forbidden}"

assert "مكان كل القراء" in HTML
assert "صُنع بحب من عيينة | الرياض" in HTML
assert "bootTimer=setTimeout(finishWelcome,3200)" in HTML
assert "هنا يقف الراوي على أطلال رحلته وتلخيصها." in HTML
assert "مشاركة منارتي مع الآخرين" in HTML
assert "data-reflmore" in HTML and "-webkit-line-clamp:2" in HTML
assert "اكتب اسم الحساب اللي تبي تشاركه الكتاب" in HTML

book_block = re.search(r"var B=\{(.*?)\n\};", HTML, re.S)
assert book_block, "catalog definition missing"
entries = re.findall(r"^([a-z][a-z0-9]*):\{", book_block.group(1), re.M)
assert len(entries) == 10, f"expected 10 starter books, got {len(entries)}"

cover_names = sorted(path.name for path in COVERS.glob("*.jpg"))
assert len(cover_names) == 10, f"expected 10 local covers, got {len(cover_names)}"
for name in cover_names:
    data = (COVERS / name).read_bytes()
    assert data[:3] == b"\xff\xd8\xff", f"{name} is not a JPEG"
    assert 4_000 <= len(data) <= 500_000, f"{name} has an unexpected size"

source_doc = (COVERS / "SOURCES.md").read_text(encoding="utf-8")
assert source_doc.count("| Public domain |") == 10
for name in cover_names:
    assert f"`{name}`" in source_doc, f"missing licence record for {name}"

# "قريبًا" may appear only in honest prose, never as a clickable placeholder.
assert not re.search(r"data-[^>]+[^>]*>[^<]*قريبًا|قريبًا[^<]*</(?:button|a)>", HTML)

print("CONTENT OK — welcome, Menara, reflection, 10 verified books, no filler")
