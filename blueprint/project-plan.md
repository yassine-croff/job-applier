# Project Plan

## 1. Problem - What problem are we solving?

Finding and applying to backend jobs is repetitive and low-signal: the same job
gets scraped across ten boards, most postings aren't a real fit, and every
application needs a CV tweaked to match the posting plus a fresh cover letter.
Doing this by hand doesn't scale past a handful of applications a day, and a lot
of the time goes into work that's mechanical, not judgment. This project
automates the pipeline end to end — fetch jobs, score them against a real CV,
tailor a CV and cover letter per posting, and (optionally) submit the
application — while keeping a human able to review, throttle, or kill the
process at any point.

## 2. Users - Who is this for?

Primary: me, applying to backend/AI-adjacent roles right now. This is a personal
tool run against my own accounts (LinkedIn, Indeed), not a multi-tenant product —
automating someone else's job-board session isn't something this is built for.
Secondary (portfolio direction): a public write-up/demo of the architecture as a
"muscle-flexing" project for interviews — scraping, queues, AI integration,
browser-free automation, and safety-conscious auto-apply design are the things
it's meant to showcase.

## 3. Features - What does v1 need?

v1 is a working end-to-end pipeline with auto-apply gated hard behind manual
review; the Chrome extension exists to sync session cookies, not to drive
automation from the browser.

- HTTP-based scrapers (no headless browser) per source (LinkedIn, Indeed, others
  later), each as a queued job implementing a common `JobSourceAdapter` interface
- Chrome extension that reads and syncs LinkedIn/Indeed session cookies to the
  backend on a schedule; read-only with respect to app state, no write access to
  settings
- Encrypted session storage per source, with a periodic health-check job that
  detects expired sessions and pauses that source instead of failing silently
- Job normalization + dedup into a common `Job` schema across sources
- Matching/scoring: embedding similarity (pgvector) as a cheap first filter, then
  an LLM call producing a structured `{match_score, missing_skills, reasoning}`
  JSON, validated against a schema before being trusted
- CV stored as structured data (not just a PDF); LLM tailors wording/emphasis per
  job but is constrained to reorder/reword only — never invent experience — with
  a diff check against the base facts to catch fabrication
- Cover letter generation from the same structured facts, tone-anchored to
  samples of my own writing
- PDF rendering of the tailored CV and cover letter
- Auto-apply gate: single source of truth in `automation_settings` /
  `source_settings`, with a global toggle, a per-source toggle, a daily
  application cap, and a dry-run mode that runs the full pipeline and logs what
  would have been submitted without sending it
- Dashboard: jobs found/matched/applied/responded, per-source toggles (write),
  session health per source, AI cost per run
- Extension popup: read-only view of effective auto-apply state via
  `GET /settings/status`, polled periodically — no toggle control there

Later, not v1:
- Real-time toggle sync over websockets instead of polling
- Additional job sources / additional CV "profiles" for different role types
- Response tracking via email parsing (detecting interview invites/rejections)
- Packaging any part of this for someone else to run against their own accounts

## 4. Data - What are we storing?

Server-side database (this is not a local-only tool, since it runs scheduled
background jobs):

- `jobs` — normalized postings: source, title, company, description,
  requirements, url, salary, dedup hash, discovered_at
- `job_scores` — match_score, missing_skills, reasoning (LLM output), validated
  and linked to a job
- `platform_sessions` — source, encrypted cookie jar, csrf_token, expires_at,
  last_synced_at, health status
- `automation_settings` — global_auto_apply_enabled, daily_application_cap
- `source_settings` — source, auto_apply_enabled
- `applications` — job_id, state machine
  (`discovered → scored → tailored → reviewed → applied → responded`), tailored
  CV/cover-letter references, submitted_at, response status
- `cv_profile` — my CV as structured JSON/YAML (the source of truth the tailoring
  step is constrained to)
- Generated PDFs (tailored CV, cover letter) stored on disk/object storage,
  referenced from `applications`, not regenerated on every view

## 5. Tech - What stack are we using?

- Laravel (PHP) for the core API, orchestration, and job pipeline
- Redis + Horizon for queues — scraping, embedding, LLM calls, PDF rendering all
  run as jobs, consistent with the async/queue-heavy work I already do
- Postgres + pgvector for job and CV embeddings
- Chrome extension (Manifest V3) for cookie/session sync only —
  `chrome.cookies` + `chrome.alarms` for periodic resync, calling a narrowly
  scoped API token (Sanctum ability limited to `sessions:write, status:read`)
- HTTP client (Laravel HTTP) with per-source cookie jars and browser-like headers
  for scraping — no Playwright/Puppeteer for this pipeline
- Anthropic/OpenAI API for scoring, CV tailoring, and cover letter generation,
  with strict JSON-schema-validated responses
- Redis token bucket for per-source rate limiting
- Docker Compose to run the full stack locally
- GitHub Actions for CI/CD

## 6. Monetize - How will this make money?

Not monetized. This is a personal-use automation tool and a portfolio project,
not a product — running it against someone else's LinkedIn/Indeed session isn't
in scope, so there's no path to "other users" without rethinking the ToS and
auth model entirely.

## 7. UI/UX - How should this look and feel?

A single dashboard: a job feed (discovered → scored → tailored → applied) with
filters by source and match score, a settings panel with the global and
per-source auto-apply toggles plus the daily cap, and a session-health panel
showing each platform's sync status. Clicking into a job shows its score
breakdown, the tailored CV/cover letter (editable before it's marked reviewed),
and the current state in the application state machine. Dry-run results show up
in the same feed, clearly marked, so I can trust the pipeline before flipping
auto-apply live. The Chrome extension is a small popup: sync status per platform
and the current effective auto-apply state, read-only, with a link back to the
dashboard to actually change anything.