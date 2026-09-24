# Agent Instructions

`aivara-se/bot-website` is worked on by agents as much as by people, and this file is the instruction set every one of them reads first. It is a copy of the `aivara-se` agent convention, version `1`, adopted from `fdd819d751034bc7872dd25fbe29bbee161fc8a2`. Adopt it, do not fork it: repository-specific facts live in `.agents/config.yml` and in the sections below, and nothing else here is meant to be edited per repository.

The template repository the four `bot-*` personal sites are generated from (`gh api -X POST repos/aivara-se/bot-website/generate`). It is deliberately generic and is not itself a published site.

## Repository-Specific Instructions

<!-- Preserved from this repository's own `AGENTS.md` as it stood before it adopted the
     aivara-se agent convention (version 1, commit 45f35fbf159fb8ecda8c7ce8da010f875bdc459a). Nothing was deleted: every heading is two
     levels deeper than it was so that the preserved title sits inside this section, and the body text is
     otherwise unchanged. This is the repository-specific half of the instructions — the shared half is
     above and below it. Where the two disagree, the shared text wins; the pull request that made this
     change lists every place they disagree. -->

### AGENTS.md — using this template

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

#### 1. Create a new personal website repository

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

#### 2. Fill in every placeholder

Replace every placeholder token (the `BOT_NAME`-style tokens in the table below; they are written here without their braces because the agent convention reserves the double-braced form for its own slots). `scripts/verify-site.sh` fails while any remain.

| Placeholder | Files | What it is | Example |
|---|---|---|---|
| `BOT_NAME` | `index.html`, `log.html` | display name, exactly as the bot writes it | `MaMa` |
| `TAGLINE` | `index.html` | one line under the name: role, from the bot's personality traits | `Orchestrator · strategic · keeps everything moving` |
| `INTRO` | `index.html` | one first-person sentence, plain language | `I plan the work, split it, and make sure it lands.` |
| `SITE_ORIGIN` | `index.html`, `log.html` | canonical origin, **no trailing slash** | `https://mama.aivara.se` |
| `EMAIL` | `index.html` | address shown in the footer line, used as `mailto:` | `mama@aivara.se` |
| `GITHUB_HANDLE` | `index.html` | account (or org) the GitHub/Repos links point at | `thani-sh-mimi`, `aivara-se` |
| `ACCENT` | `index.html`, `log.html` | **one** hex colour — this bot's own | `#f7a8d8` |

Then, outside the placeholders:

- **`assets/avatar.webp`** — 256×256 WebP. The file shipped here is a placeholder: replace
  it with the bot's own portrait. Keep the filename; both pages reference it.
- **`assets/fonts/`** — leave as is. Inter and Space Grotesk, latin subset, self-hosted,
  OFL 1.1 (licences in the same directory).
- **`CNAME`** — do **not** add this yet. It is the last step of deployment, after DNS
  resolves; committing it early takes the site dark. See `docs/SYSTEM.md`.

#### 3. Pick the accent

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

#### 4. Write the copy

The name, tagline and intro are the only prose on the front page, and they should be
specific to the bot — a tagline derived from its traits, not a generic slogan. Keep the
page to one phone screen (roughly 640px of content); prefer shorter copy over smaller type.

#### 5. Adding a log entry

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

#### 6. Verify before you push

```bash
./scripts/verify-site.sh          # placeholders, assets, markers, accents, contrast, JS
```

It checks the mechanisable rules: no placeholder token left, every referenced local asset exists,
exactly one ENTRIES pair with entries newest-first, the accent clears AA against the ground,
no `<script>`, no third-party request, and the empty state is gone once entries exist.

Then the two things a script cannot see — do them before saying it works:

1. **Phone viewport**, ~360×800: the front page must fit one screen with no horizontal
   scroll, no clipped text, and no overflow on the log page.
2. **The rendered page**, not the source: read the computed styles and the pixels (fonts
   loaded, avatar visible, byline small and grey rather than body-sized).

#### 7. Deploy

See [`docs/SYSTEM.md`](docs/SYSTEM.md). In short: push to `main`, enable GitHub Pages from
the branch root, let the owner point DNS at `<org>.github.io`, and add `CNAME` **last**.

#### Always / never

- **Never** push to another bot's repository, and never edit `aivara-se/bot-website` while
  customising a site — the template must stay generic.
- **Never** add a third-party request: no CDN fonts, no analytics, no tracking pixels, no
  external scripts. The pages load their own files and nothing else.
- **Never** introduce a build step or a dependency. Static HTML and inline CSS is the whole
  system, and it is what keeps the sites impossible to break.
- **Always** keep one accent hue, keep the page to a single phone screen, and re-run
  `scripts/verify-site.sh` after any change to colour, type or the log.

## Current Project Focus

Keep the template generic: any of the four `bot-*` sites must still be generated from it. Do not customise it for one bot, and do not add a dependency or a build step.

This section is steering, not policy. It is the one place where what matters right now outranks the standing rules below, it changes often, and it is replaced rather than appended to. Keep it short enough to read in full, and current enough to be worth reading.

## Agent Roles

Work in this repository is done by agents taking one of three roles. A task names the role that owns it; every role reads this same file and is held to it.

- **Orchestrator** — turns a goal into tasks with acceptance criteria, settles the questions two tasks would otherwise answer differently, and routes work to the other roles. Does not implement.
- **Builder** — does the work. Reads the task, its parents' handoffs and its comments; writes the change; runs the commands in `.agents/config.yml`; hands back what changed, what was verified, and what was left out.
- **Reviewer** — verifies a handoff or a pull request the reviewer did not write: reads the diff twice, runs it, tests the claim, and returns a verdict. The author of a branch never reviews it.

The **operator** is the human who owns this repository. The operator decides what is worth doing, grants access, and answers what an agent cannot. An agent that needs a decision says so and stops; it does not make the decision for the operator.

## How Work Moves

- Work arrives as a task on the shared board (Hermes Kanban), with a body: what is wanted, and the acceptance criteria the work will be judged on. The task generally carries the handoffs of the tasks it depends on and the comments on it — read those before you start, not after.
- The claim in a task and its acceptance criteria are not always the same thing. Where they differ, the criteria and the diff decide; the difference is a finding.
- Work happens in that task's workspace and on that task's branch. One task, one branch; never mix two tasks in one branch, and never continue another task's branch.
- A handoff states what changed, what was verified — the exact command, the result, and the tree it ran against — and what was deliberately left out. A handoff without that output is a claim, not a handoff.
- Implementation is finished when someone else has reviewed it and approved. A branch with no reviewer is unfinished work, not done work.
- A reviewer's verdict is exactly one of `approve`, `request changes` or `block`, and the `review` skill defines what each requires. The reviewer's report follows the fixed five-section schema in `.agents/prompts/code-review.md`, so that two reviewers of the same diff produce comparable reports.
- **What you may do unasked:** read the repository; create a branch; commit to it; push it; open a pull request against `main`; run the commands declared in `.agents/config.yml`. **Nothing else.** Merging, tagging, releasing, changing repository settings, and writing outside the task's workspace are the operator's calls.

## Clarifying Requirements

- Ask before assuming, when a wrong assumption would cost a rewrite: an ambiguous requirement, a missing input, a decision the task does not make. Ask once, state the options you see, and recommend one.
- Ask first, then act. Do not spend the task on a guess the operator will reject.
- If the task is larger than it says, say so in a comment, with what you found, and let the owner decide whether to widen it or split it. Never quietly widen it yourself.

## Tooling and Verification

- `.agents/config.yml` is the only home for this repository's language, its package manager, its commands and the paths of its authoritative documents. Reference them by key, from here and from every skill; never restate a command in prose.
- `commands.check` is the wrapper: one command that runs everything this repository gates on. **ALWAYS** run it on the final tree, after the last edit, and quote the real output. CI runs the same wrapper — if the two sequences differ, the CI file is the bug.
- `commands.test`, `commands.lint` and `commands.build` are the narrower steps. `null` means this repository has no such gate: say so plainly, **never** invent a command to fill it, and never install a tool this repository does not use.
- **Never** report "tests pass", "it builds" or "verified" without the command and the tree it ran against.
- **Never** add a second package manager, a second lockfile, a second formatter or a second test runner — the toolchain is the one declared in `.agents/config.yml`.

## Version Control

- **Branches**: lowercase, hyphens only, one per task, named for the change — `fix-log-timezone`, `chore/adopt-agents-config`. No uppercase, no underscores, no personal prefixes.
- **Commits**: Conventional Commits, lowercase, single line, no scopes — `type: short description`.
- **Never** commit to `main` directly. **Never** force-push a branch another agent or person has seen.
- Keep history linear: no merge commits, no empty commits, no work-in-progress commits left behind.
- Commit under your own identity — your name, your address at this organisation. Never a generic bot, never another agent's identity.
- Remote work is always a branch plus a pull request. The pull request body says what changed, what was verified and how, and what was left out; request review from the operator (`thani-sh`) and one peer agent. Leave the working tree clean: no scratch files, no editor backups, no `.env` you created.

## Repository Structure

- `index.html`, `log.html`: the two pages, still carrying the placeholder tokens a generated site replaces
- `docs/`: the authoritative documents — `DESIGN.md` (design), `PRODUCT.md` (purpose and scope), `SYSTEM.md` (deployment)
- `assets/`: the placeholder portrait, the self-hosted fonts and their licences
- `scripts/verify-site.sh`: the check every generated site must pass

- New markdown goes in the directory that already owns its subject, and a fact has exactly one home. Never add a second copy of something a document already says; link to it.
- The documents authoritative for architecture, product and design are declared in `.agents/config.yml` under `paths`. A change that makes one of them wrong is not finished until that document is right, in the same change.
- If a path in the map above stops being true, fix the map in the same pull request. A map that lies is worse than no map.

## Agent Skills

`.agents/skills/` holds one skill per kind of work — the procedure to follow, not a second copy of these instructions. Each skill declares in its front matter what it covers and its `when-to-use`: the situation in which you must open it. Read the skill that covers the work before you start it.

- .agents/skills/repo-workflow/SKILL.md
- .agents/skills/coding/SKILL.md
- .agents/skills/testing/SKILL.md
- .agents/skills/writing/SKILL.md
- .agents/skills/review/SKILL.md

How this index stays true:

- Every skill on disk is listed above, and every skill listed above exists. A new skill is added here in the same pull request; run `python3 .agents/scripts/validate_agents_config.py` and it will fail if the index and the directory disagree.
- Front matter is exactly three keys: `name`, equal to the directory; `description`, one sentence; `when-to-use`, the trigger in the reader's words. A skill stays under about 120 lines, covers one concern, and names every file it ships.
- Skills are flat until this repository has more than eight of them or two clearly unrelated groups, then they are grouped under `.agents/skills/<group>/<skill>/` and this index is updated with them.
- A skill that is true only of this repository stays here. A skill that would be true of every repository belongs in the `aivara-se` convention instead, in a pull request of its own.
