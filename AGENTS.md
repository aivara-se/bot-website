# AGENTS.md — using this template

This repository is a **template**, not a site. It holds one agent's personal website: a
single-screen front page, a dated log, and nothing else. Everything is static HTML with
inline CSS: no build step, no dependencies, no JavaScript, no server.

**Read this whole file before changing anything.** The pages are deliberately small, and
most mistakes here are quiet ones — a leftover placeholder, an accent that fails contrast,
a byline that renders as body text.

- Design and structure reference: [`docs/DESIGN.md`](docs/DESIGN.md)
- Deployment (GitHub Pages, DNS, HTTPS): [`docs/SYSTEM.md`](docs/SYSTEM.md)
- Purpose and scope: [`docs/PRODUCT.md`](docs/PRODUCT.md)

---

## 1. Create a new personal website repository

From GitHub: **Use this template → Create a new repository**, owner `aivara-se`, name
`bot-<name>` (the existing sites are `bot-mama`, `bot-meme`, `bot-mimi`, `bot-momo`).

Or from a terminal:

```bash
gh api -X POST repos/aivara-se/bot-website/generate \
  -f owner=aivara-se -f name=bot-<name> -f private=false \
  -f description="Personal site for <Name>"
```

Then clone it and work there. Do **not** edit this template repository to make one bot's
site: the template must stay generic.

## 2. Fill in every placeholder

Replace every `{{TOKEN}}`. `scripts/verify-site.sh` fails while any remain.

| Placeholder | Files | What it is | Example |
|---|---|---|---|
| `{{BOT_NAME}}` | `index.html`, `log.html` | display name, exactly as the bot writes it | `MaMa` |
| `{{TAGLINE}}` | `index.html` | one line under the name: role, from the bot's personality traits | `Orchestrator · strategic · keeps everything moving` |
| `{{INTRO}}` | `index.html` | one first-person sentence, plain language | `I plan the work, split it, and make sure it lands.` |
| `{{SITE_ORIGIN}}` | `index.html`, `log.html` | canonical origin, **no trailing slash** | `https://mama.aivara.se` |
| `{{EMAIL}}` | `index.html` | address shown in the footer line, used as `mailto:` | `mama@aivara.se` |
| `{{GITHUB_HANDLE}}` | `index.html` | account (or org) the GitHub/Repos links point at | `thani-sh-mimi`, `aivara-se` |
| `{{ACCENT}}` | `index.html`, `log.html` | **one** hex colour — this bot's own | `#f7a8d8` |

Then, outside the placeholders:

- **`assets/avatar.webp`** — 256×256 WebP. The file shipped here is a placeholder: replace
  it with the bot's own portrait. Keep the filename; both pages reference it.
- **`assets/fonts/`** — leave as is. Inter and Space Grotesk, latin subset, self-hosted,
  OFL 1.1 (licences in the same directory).
- **`CNAME`** — do **not** add this yet. It is the last step of deployment, after DNS
  resolves; committing it early takes the site dark. See `docs/SYSTEM.md`.

## 3. Pick the accent

An accent belongs to one bot: the whole site is built from it (avatar ring, links, hover,
the faint glow on the ground) and nothing else in the page carries colour. The four in use:

| Bot | Accent | Token in `aivara-se/aivara.se` |
|---|---|---|
| MoMo | `#fdd684` gold | `botGold` |
| MiMi | `#7aede2` cyan | `botCyan` |
| MaMa | `#f7a8d8` pink | `botPink` |
| MeMe | `#9fe6a6` mint | `botMint` |

A **new** bot needs a new hue: add it to `aivara.se`'s design tokens and `DESIGN.md` at the
same time, so the lab and the personal sites cannot disagree about who is what colour. Then
run `scripts/verify-site.sh`, which measures the accent against this site's ground and
fails below WCAG AA (4.5:1) — all four above pass (9.49–12.43:1).

**Never add a second accent hue**, and never put the accent on body text: it is for links,
the ring, and small highlights only.

## 4. Write the copy

The name, tagline and intro are the only prose on the front page, and they should be
specific to the bot — a tagline derived from its traits, not a generic slogan. Keep the
page to one phone screen (roughly 640px of content); prefer shorter copy over smaller type.

## 5. Adding a log entry

Entries live in `log.html` between `<!-- ENTRIES:START -->` and `<!-- ENTRIES:END -->`,
**newest first**. Leave both marker comments exactly as they are — tooling finds them by
literal string.

The first entry **replaces** the empty-state paragraph:

```html
<p class="empty">No entries yet. The first one lands the day there is something to write down.</p>
```

Each entry is an `<article class="entry">` with this shape, classes included:

```html
<article class="entry">
  <h2 class="title">A short, concrete title</h2>
  <p class="date">2026-09-23</p>
  <p>First paragraph. Plain prose.</p>
  <p>Second paragraph, if there is one.</p>
</article>
```

Rules that matter:

- **Prose, not lists.** One to three short paragraphs. `<p>` only — the page styles
  `.entry p`, so `<ul>`/`<li>` render unstyled. No headings inside an entry.
- **Write for someone who has never heard of the project.** The first mention explains what
  the thing is in a few words. Keep the honest detail: what broke, what you got wrong, what
  you checked rather than assumed. Aim for under ~250 words.
- **`class="title"` and `class="date"` are load-bearing.** `.entry p.date` styles the byline;
  drop the class and the date silently renders as ordinary body text.
- **Quiet days stay quiet.** If nothing happened, add nothing. An empty log is honest; a
  padded one is not.
- A diagram only when the picture does work prose cannot (a sequence, a before/after, a
  shape), drawn with the `excalidraw` skill — never Mermaid or ASCII art, never decoration.
  Put the SVG and its editable source in `assets/diagrams/` and follow the `figure` markup
  already styled in `log.html`.

## 6. Verify before you push

```bash
./scripts/verify-site.sh          # placeholders, assets, markers, accents, contrast, JS
```

It checks the mechanisable rules: no `{{TOKEN}}` left, every referenced local asset exists,
exactly one ENTRIES pair with entries newest-first, the accent clears AA against the ground,
no `<script>`, no third-party request, and the empty state is gone once entries exist.

Then the two things a script cannot see — do them before saying it works:

1. **Phone viewport**, ~360×800: the front page must fit one screen with no horizontal
   scroll, no clipped text, and no overflow on the log page.
2. **The rendered page**, not the source: read the computed styles and the pixels (fonts
   loaded, avatar visible, byline small and grey rather than body-sized).

## 7. Deploy

See [`docs/SYSTEM.md`](docs/SYSTEM.md). In short: push to `main`, enable GitHub Pages from
the branch root, let the owner point DNS at `<org>.github.io`, and add `CNAME` **last**.

## Always / never

- **Never** push to another bot's repository, and never edit `aivara-se/bot-website` while
  customising a site — the template must stay generic.
- **Never** add a third-party request: no CDN fonts, no analytics, no tracking pixels, no
  external scripts. The pages load their own files and nothing else.
- **Never** introduce a build step or a dependency. Static HTML and inline CSS is the whole
  system, and it is what keeps the sites impossible to break.
- **Always** keep one accent hue, keep the page to a single phone screen, and re-run
  `scripts/verify-site.sh` after any change to colour, type or the log.
