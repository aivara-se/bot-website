# Agent Instructions

The template for an Aivara bot's personal website: one screen that says who the bot is, plus a dated log written in public.

Static HTML with inline CSS — no build step, no dependencies, no JavaScript, no third-party requests. `index.html` and `log.html` are the pages, `docs/` holds the design, product and deployment documents, and `scripts/verify-site.ts` is the check. How a site is made from this template, and every value a generated site fills in, is in `README.md`.

This file is the `aivara-se` agent convention, version `2`, adopted from `0bbd7e674d395dc210397621164654b4d36dd7e0`. Adopt it, do not fork it: repository-specific facts live in the sections below, and nothing else here is meant to be edited per repository.

## Current Project Focus

Keep the template generic: it is the source every bot site is generated from, and it stays the source. No one bot's name, accent, copy or portrait belongs in it, and neither does a build step, a dependency or a third-party request.

This section is steering, not policy. It is the one place where what matters right now outranks the standing rules below, it changes often, and it is replaced rather than appended to. Keep it short enough to read in full, and current enough to be worth reading.

## House rules

- **Never** add a third-party request: no CDN fonts, no analytics, no tracking pixels, no external scripts. The pages load their own files and nothing else.
- **Never** introduce a build step or a dependency. Static HTML and inline CSS is the whole system, and it is what keeps the sites impossible to break.
- **Never** edit this repository to build one bot's site: generate a repository from the template and work there. The template must stay generic.
- **Never** push to another bot's repository.
- **Always** keep one accent hue, keep the front page to a single phone screen, and re-run `bun run scripts/verify-site.ts` after any change to colour, type or the log.

## Tooling

- **Bun is the runtime for scripts.** A script that runs commands — a check, a build, a release, a data fix — is written in TypeScript and run with `bun`: `bun run scripts/<name>.ts`. **Never** Python; prefer it over a bash shell script, because a shell script past a handful of lines has no types, no argument handling and no error handling. A one-line command typed at the prompt is not a script.
- **Never** add a second package manager, a second lockfile, a second formatter or a second test runner. The toolchain is the one the repository already uses, declared in the files it already has.
- **Never** report "tests pass", "it builds" or "verified" without the command and the tree it ran against.

## Verify before pushing

```bash
bun run scripts/verify-site.ts
```

Run the whole sequence, not just its fast part, and read every result — the exit code of the last command says nothing about the first.

In this template repository the script is **expected to fail**: the placeholders are unfilled, `--accent` is still a placeholder token and `assets/avatar.webp` is the placeholder portrait. A site generated from this template must reach `all checks passed`. Then the two things the script cannot see, before claiming a site works: the **phone viewport**, ~360×800 — the front page fits one screen with no horizontal scroll and no clipped text, and the log page does not overflow; and the **rendered page**, not the source — computed styles and pixels, so that the fonts are loaded, the avatar is visible and the byline is small and grey rather than body-sized.

## Version Control

- **Branches**: lowercase, hyphens only, one per task, named for the change — `fix-log-timezone`, `chore/adopt-agents-config`. No uppercase, no underscores, no personal prefixes.
- **Commits**: Conventional Commits, lowercase, single line, no scopes — `type: short description`.
- **Never** commit to `main` directly. **Never** force-push a branch another agent or person has seen.
- Keep history linear: no merge commits, no empty commits, no work-in-progress commits left behind.
- Commit under your own identity — your name, your address at this organisation. Never a generic bot, never another agent's identity.
- Remote work is always a branch plus a pull request. The pull request body says what changed, what was verified and how, and what was left out; request review from the operator (`thani-sh`) and one peer agent. Leave the working tree clean: no scratch files, no editor backups, no `.env` you created.

## Repository Structure

- `index.html`: the front page — name, tagline, intro, links
- `log.html`: dated entries, newest first, between the `ENTRIES` markers
- `assets/avatar.webp`: the portrait, 256×256 WebP — a placeholder here, replaced in a generated site
- `assets/fonts/`: self-hosted Inter and Space Grotesk, latin subset (OFL 1.1)
- `assets/diagrams/`: optional figures for log entries, editable source beside the SVG
- `docs/DESIGN.md`: the design and structure reference
- `docs/SYSTEM.md`: deployment — GitHub Pages, DNS, HTTPS, access
- `docs/PRODUCT.md`: purpose and scope
- `scripts/verify-site.ts`: the checks a machine can run
- `README.md`: how a site is made from this template
- `.agents/skills/`: the convention's skills

New markdown goes in the directory that already owns its subject, and a fact has exactly one home. Never add a second copy of something a document already says; link to it. If a path in the map above stops being true, fix the map in the same pull request. A map that lies is worse than no map.

## Agent Skills

`.agents/skills/` holds one skill per kind of work — the procedure to follow, not a second copy of these instructions. A skill stands on its own: it names no file of this convention and points at no other skill, so a reader who has it has everything it needs. This file is what points at the skills; they never point back. Each skill declares in its front matter what it covers and its `when-to-use`: the situation in which you must open it. Read the skill that covers the work before you start it.

- .agents/skills/coding/SKILL.md
- .agents/skills/testing/SKILL.md
- .agents/skills/writing/SKILL.md
- .agents/skills/review/SKILL.md

Every skill on disk is listed above, and every skill listed above exists. A new skill is added here in the same pull request that adds it, and a skill deleted from disk is deleted from this list in the same commit. An index that has drifted is worse than a short one.

Front matter is exactly three keys: `name`, equal to the directory; `description`, one sentence; `when-to-use`, the trigger in the reader's words. A skill stays under about 120 lines, covers one concern, and names every file it ships. Skills are flat until this repository has more than eight of them or two clearly unrelated groups, then they are grouped under `.agents/skills/<group>/<skill>/` and this index is updated with them.

A skill that is true only of this repository stays here. A skill that would be true of every repository belongs in the `aivara-se` convention instead, in a pull request of its own.
