#!/usr/bin/env bash
# verify-site.sh — the rules from AGENTS.md and docs/DESIGN.md that a machine can check.
#
# Run this in a bot's site repository (e.g. aivara-se/bot-mama), from anywhere:
#     ./scripts/verify-site.sh
# It reports PASS/FAIL/WARN and exits non-zero if anything failed.
#
# NOTE: in the template repository itself this is *expected* to FAIL — the placeholders are
# unfilled and the avatar is still the placeholder portrait. Run it in a real site.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

python3 <<'PY'
import hashlib, os, re, struct, sys

FAILS, WARNS = [], []
def ok(m):   print(f"  \033[32mPASS\033[0m  {m}")
def bad(m):  print(f"  \033[31mFAIL\033[0m  {m}"); FAILS.append(m)
def warn(m): print(f"  \033[33mWARN\033[0m  {m}"); WARNS.append(m)
def head(m): print(f"\n\033[1m{m}\033[0m")

PLACEHOLDER_AVATAR = "cbed39c9b8abd87b89e8845df9e97bd6"   # the portrait shipped in the template
GROUND = "#171834"                                       # lightest ground stop = worst case
FAMILY = {"#fdd684": "MoMo (botGold)", "#7aede2": "MiMi (botCyan)",
          "#f7a8d8": "MaMa (botPink)", "#9fe6a6": "MeMe (botMint)"}
REJECTED_TIER = "#6e7681"                                # fails AA on this ground (3.76:1)

def lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def ratio(fg, bg):
    def lum(h):
        h = h.lstrip('#')
        r, g, b = (int(h[i:i+2], 16) for i in (0, 2, 4))
        return 0.2126*lin(r) + 0.7152*lin(g) + 0.0722*lin(b)
    a, b = lum(fg), lum(bg)
    a, b = max(a, b), min(a, b)
    return (a + 0.05) / (b + 0.05)

missing = [f for f in ("index.html", "log.html") if not os.path.exists(f)]
if missing:
    print(f"  \033[31mFAIL\033[0m  not a site repository: missing {', '.join(missing)}")
    sys.exit(1)
pages = {f: open(f, encoding='utf-8').read() for f in ("index.html", "log.html")}

# ---------------------------------------------------------------- placeholders
head("Placeholders")
found = sorted({t for f in pages.values() for t in re.findall(r"\{\{([A-Z_]+)\}\}", f)})
if found:
    bad(f"unfilled placeholders: {', '.join('{{'+t+'}}' for t in found)}")
else:
    ok("no {{PLACEHOLDER}} left in either page")

# ---------------------------------------------------------------- assets & requests
head("Assets and third-party requests")
refs = {}
for name, html in pages.items():
    for url in re.findall(r'(?:src|href)\s*=\s*"([^"]+)"', html):
        if url.startswith(("http://", "https://", "mailto:", "tel:", "#", "data:")):
            continue
        refs.setdefault(url.split("#")[0], set()).add(name)
for url, where in sorted(refs.items()):
    if os.path.exists(url):
        ok(f"{url} exists")
    else:
        bad(f"{url} referenced by {', '.join(sorted(where))} does not exist")

foreign = []
for name, html in pages.items():
    for pat in (r'src\s*=\s*"https?://', r'<link[^>]+rel\s*=\s*"stylesheet"[^>]+href\s*=\s*"https?://',
                r'@import', r'fonts\.googleapis', r'fonts\.gstatic', r'googletagmanager',
                r'google-analytics', r'cdn\.'):
        for m in re.finditer(pat, html, re.I):
            foreign.append(f"{name}: {m.group(0)[:48]}")
if foreign:
    bad("third-party resource request(s): " + "; ".join(sorted(set(foreign))))
else:
    ok("nothing is loaded from a third party (fonts are local)")

for f in ("assets/fonts/inter-latin.woff2", "assets/fonts/space-grotesk-latin.woff2"):
    if os.path.exists(f) and os.path.getsize(f) > 1000:
        ok(f"font present ({os.path.getsize(f)//1024} KB)")
    else:
        bad(f"missing or empty font: {f}")
for f in ("assets/fonts/OFL-Inter.txt", "assets/fonts/OFL-SpaceGrotesk.txt"):
    ok(f"licence present: {os.path.basename(f)}") if os.path.exists(f) else bad(f"missing licence: {f}")

if re.search(r"<script", "".join(pages.values()), re.I):
    bad("a <script> tag is present — the sites ship zero JavaScript")
else:
    ok("no <script> tag anywhere")

# ---------------------------------------------------------------- the log block
head("Log block")
START, END = "<!-- ENTRIES:START -->", "<!-- ENTRIES:END -->"
log = pages["log.html"]
ns, ne = log.count(START), log.count(END)
if ns == 1 and ne == 1 and log.index(START) < log.index(END):
    ok("exactly one ENTRIES:START / ENTRIES:END pair, in order")
else:
    bad(f"ENTRIES markers wrong: {ns} start, {ne} end (need exactly one of each, start first)")

block = log.split(START, 1)[1].split(END, 1)[0] if ns == 1 and ne == 1 else ""
entries = re.findall(r'<article class="entry">(.*?)</article>', block, re.S)
dates = []
for i, e in enumerate(entries, 1):
    t = re.search(r'<h2 class="title">(.+?)</h2>', e, re.S)
    d = re.search(r'<p class="date">(\d{4}-\d{2}-\d{2})</p>', e)
    if not t:
        bad(f"entry {i}: missing <h2 class=\"title\">")
    if not d:
        bad(f"entry {i}: missing <p class=\"date\">YYYY-MM-DD</p> (a bare .date class renders as body text)")
    else:
        dates.append(d.group(1))
    if not re.search(r'<p>(?!<)', e):
        bad(f"entry {i}: no <p> body paragraph")
    for banned in ("<ul", "<ol", "<li", "<h1", "<h3", "<h4"):
        if banned in e.lower():
            bad(f"entry {i}: contains {banned} — entries are prose, not lists or nested headings")
if entries:
    ok(f"{len(entries)} log entr{'y' if len(entries)==1 else 'ies'}, newest first" if dates == sorted(dates, reverse=True)
       else "log entries present")
    if dates != sorted(dates, reverse=True):
        bad(f"entries are not newest-first: {dates}")
    if 'class="empty"' in block:
        bad("the empty-state paragraph is still there alongside real entries — the first entry replaces it")
    else:
        ok("empty state removed, as it must be once entries exist")
else:
    ok("no entries yet")
    if 'class="empty"' not in block:
        warn("no entries and no empty state — the log page will look unfinished")

# ---------------------------------------------------------------- colour
head("Colour")
accents = {f: (re.search(r"--accent:\s*(#[0-9a-fA-F]{6})", h) or [None, None])[1] for f, h in pages.items()}
values = set(v for v in accents.values() if v)
if not values:
    bad("--accent is not set to a hex colour in either page (still a placeholder?)")
elif len(values) != 1:
    bad(f"the two pages disagree about the accent: {accents}")
else:
    acc = values.pop().lower()
    r = ratio(acc, GROUND)
    role = FAMILY.get(acc)
    if r >= 4.5:
        ok(f"accent {acc} measures {r:.2f}:1 against the ground (AA needs 4.5)")
    else:
        bad(f"accent {acc} measures only {r:.2f}:1 against the ground — fails AA")
    if role:
        ok(f"accent is a family token: {role}")
    else:
        warn(f"accent {acc} is not one of the four family tokens — a new bot needs its hue "
             f"registered in aivara.se's design tokens and DESIGN.md at the same time")

for f, h in pages.items():
    if REJECTED_TIER in h.lower():
        bad(f"{f} still uses {REJECTED_TIER} — that tier measures 3.76:1 here; use var(--text-quiet)")

# ---------------------------------------------------------------- avatar & scaffolding
head("Portrait and scaffolding")
if not os.path.exists("assets/avatar.webp"):
    bad("assets/avatar.webp is missing")
else:
    d = open("assets/avatar.webp", "rb").read()
    if d[:4] != b"RIFF" or d[8:12] != b"WEBP":
        bad("assets/avatar.webp is not a WebP file")
    else:
        if d[12:16] == b"VP8 ":
            w, h = struct.unpack("<HH", d[26:30]); w &= 0x3FFF; h &= 0x3FFF
        elif d[12:16] == b"VP8L":
            b = int.from_bytes(d[21:25], "little"); w = (b & 0x3FFF) + 1; h = ((b >> 14) & 0x3FFF) + 1
        elif d[12:16] == b"VP8X":
            w = int.from_bytes(d[24:27], "little") + 1; h = int.from_bytes(d[27:30], "little") + 1
        else:
            w = h = 0
        if (w, h) == (256, 256):
            ok("avatar is 256x256 WebP")
        else:
            bad(f"avatar is {w}x{h} — must be 256x256 WebP (and small: keep it under ~40 KB)")
        if hashlib.md5(d).hexdigest() == PLACEHOLDER_AVATAR:
            bad("assets/avatar.webp is still the template's placeholder portrait — replace it "
                "with this bot's own")
        else:
            ok(f"avatar is this bot's own ({os.path.getsize('assets/avatar.webp')//1024} KB or less: "
               f"{os.path.getsize('assets/avatar.webp')} B)")

ok(".nojekyll present (Jekyll off)") if os.path.exists(".nojekyll") else warn(".nojekyll missing — "
                                                                            "add it so files with a leading underscore are served")

origin = re.search(r'<meta property="og:url" content="([^"]+)"', pages["index.html"])
if os.path.exists("CNAME"):
    cname = open("CNAME").read().strip()
    host = origin.group(1).split("//")[-1].strip("/") if origin else ""
    if cname == host:
        ok(f"CNAME matches og:url: {cname}")
    else:
        bad(f"CNAME says {cname!r} but og:url points at {host!r} — they must match")
else:
    warn("no CNAME file yet — correct while DNS is pending; add it after the record resolves (docs/SYSTEM.md §3)")

# ---------------------------------------------------------------- summary
print()
if FAILS:
    print(f"\033[31m{len(FAILS)} check(s) failed\033[0m" + (f", {len(WARNS)} warning(s)" if WARNS else ""))
    sys.exit(1)
print(f"\033[32mall checks passed\033[0m" + (f", {len(WARNS)} warning(s)" if WARNS else ""))
PY
