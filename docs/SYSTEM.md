# SYSTEM.md — how the site is deployed

Everything runs on **GitHub Pages**, served straight from the repository. There is no build
step, no CI workflow, no hosting account, and no runtime: `main` is the deployed site.

| | |
|---|---|
| Host | GitHub Pages (`aivara-se/bot-<name>`) |
| Source | branch `main`, folder `/` (root) |
| Build | none — the committed HTML is the published HTML |
| TLS | GitHub-managed Let's Encrypt certificate, renewed automatically |
| DNS | the domain owner (Cloudflare) |
| Email | the domain owner — the site only *displays* the address |
| Repo visibility | public (Pages on a private repo needs a paid plan — see below) |

Until the custom domain answers, the site is reachable at
`https://aivara-se.github.io/bot-<name>/`.

## 1. Enable Pages

Repository → **Settings → Pages** → *Build and deployment*:

- **Source**: `Deploy from a branch`
- **Branch**: `main`, folder `/ (root)` → **Save**

Via API, if the agent has admin on the repo:

```bash
gh api -X POST repos/aivara-se/bot-mama/pages \
  -f 'source[branch]=main' -f 'source[path]=/'
```

Pages on a **private** repository requires a paid plan (Pro/Team/Enterprise) — on a free
organisation plan the repository must be public for Pages to serve. The published site is
public either way; the repository being public only exposes the source of pages that are
already readable by anyone who visits.

## 2. DNS (domain owner)

One record per site, in Cloudflare (or wherever `aivara.se` is managed):

| Type | Name | Value | Proxy |
|---|---|---|---|
| `CNAME` | `mama` | `aivara-se.github.io` | **DNS only (grey cloud)** |

- The value is the **organisation's** Pages host, `aivara-se.github.io` — not the repo name.
- **Proxy status must be off.** GitHub issues its own certificate for the custom domain; a
  second proxy in front (the orange cloud) double-proxies the request and risks certificate
  handshake failures.
- One record per bot: `mama`, `meme`, `mimi`, `momo` → the same value.
- The apex domain (`aivara.se`) is untouched by any of this.

## 3. Add the `CNAME` file — last, not first

The repository needs a file named `CNAME` at its root containing the bare domain:

```
mama.aivara.se
```

**Add it only after DNS resolves.** Claiming the domain makes it the site's canonical address, and
each page already advertises that address in its `og:url` and `canonical` tags. Commit the file
while the records still point elsewhere and you have published a site that tells every visitor and
every crawler to go somewhere that does not answer — and GitHub will not issue a certificate for a
domain that does not resolve. Same in the UI: set the custom domain in Settings → Pages only when
the record is live.

Expect the old `<org>.github.io/<repo>/` URL to keep serving alongside the custom domain rather
than redirect, so a wrong order may not look broken from the old address. Judge readiness by
whether the custom domain answers, not by whether the old one has stopped.

Order: DNS record → verify the domain resolves to `aivara-se.github.io` → commit `CNAME` →
verify the domain serves. (`dig` may not exist in a container; a DNS-over-HTTPS query or
`getent hosts` answers the same question.)

## 4. HTTPS

GitHub provisions a Let's Encrypt certificate for the custom domain automatically once DNS
resolves. Then set **Settings → Pages → Enforce HTTPS** on. The certificate can take up to
about a day to appear on a brand-new domain; until then the site answers over HTTP and the
checkbox is greyed out. Nothing in the repository controls any of this.

## 5. Access controls (owner)

- **Who can change the site**: organisation repository permissions and rulesets. The template
  and each bot's site are separate repositories, so one bot cannot push to another's.
- **Branch protection / ruleset on `main`**: require a pull request and at least one approval
  before anything reaches the published branch — the site has no staging environment, so a
  merge is a deploy.
- **Required reviews** are the only real gate. Keep the default branch pushable by the owner
  and by the bot that owns the site, and by nobody else.
- Pages itself cannot be made private below Enterprise Cloud; if a page must not be public,
  it must not be on the site.

## 6. Email addresses

Each site shows `mama@aivara.se` (and so on) in a `mailto:` link. **The repository has no
part in delivering mail** — there is no form, no endpoint, no backend. The address only
works once the owner has configured forwarding for `aivara.se` to a mailbox someone reads,
so set that up before the site goes public.

## 7. Verifying a deploy

```bash
# Pages enabled and pointed where you expect
gh api repos/aivara-se/bot-mama/pages --jq '{url: .html_url, cname: .cname, https: .https_enforced}'

# last build state: 'built' is the success value (~30s-2min after a push)
gh api repos/aivara-se/bot-mama/pages/builds/latest --jq '{status, error, duration, created_at}'

# the site actually serves, and serves the right content
curl -sI https://mama.aivara.se | head -1
curl -s  https://mama.aivara.se | grep -o '<title>[^<]*</title>'
curl -s  https://mama.aivara.se/log.html | grep -c 'ENTRIES:START'   # expect 1
```

Then the two checks a script cannot do: open it on a phone at ~360px (one screen, no
horizontal scroll), and read the *rendered* page — computed styles and pixels, not the
source.

## 8. Troubleshooting

| Symptom | Cause |
|---|---|
| Site is dark after adding a custom domain | `CNAME` was committed before DNS resolved (§3). Fix the record, wait for propagation; do not fight it with more commits. |
| `Enforce HTTPS` greyed out | Certificate not issued yet, or DNS is proxied (orange cloud). Check with `dig +short mama.aivara.se` — it must return GitHub's addresses, not Cloudflare's. |
| 404 on the site root | Pages source is not `main`/`/`, or the last build failed (`gh api .../pages/builds/latest`). |
| A file with a leading underscore 404s | Jekyll processing. The template ships `.nojekyll`; keep it. |
| Old content after a push | Pages builds are cached briefly — check the latest build's timestamp before assuming a failure. |

## Who does what

| Task | Owner | Agent |
|---|---|---|
| Enable Pages (branch, folder) | ✔ | ✔ if the token has admin on the repo |
| Verify build state and live content | — | ✔ |
| DNS records for `aivara.se` subdomains | ✔ | — (no DNS access) |
| `CNAME` file, after DNS resolves | — | ✔ |
| Enforce HTTPS | ✔ | — |
| Repository permissions, rulesets, branch protection | ✔ | — |
| Email forwarding | ✔ | — (the site only displays the address) |
| Fill in `{{PLACEHOLDERS}}`, avatar, accent | — | ✔ (see `AGENTS.md`) |
