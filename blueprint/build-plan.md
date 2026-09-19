# Build Plan

v1 is a single-user pipeline running against my own accounts: Laravel + Redis
queues + Postgres, no multi-tenant auth. Build order follows the pipeline itself
— scrape first, then score, then tailor, then the apply gate — so every stage is
runnable and inspectable on its own before the next one depends on it. The
Chrome extension is built once real cookies are needed (step 3), not before.
Auto-apply stays behind a global kill switch from the moment it exists.

- [ ] 1. **Job schema + adapter interface** - `Job` model/migration (source,
      title, company, description, requirements, url, salary, dedup hash), and
      a `JobSourceAdapter` interface that any scraper implements, with dedup by
      company+title+description hash
- [ ] 2. **First HTTP scraper (one source)** - Laravel HTTP client scraper for a
      single source, run manually (no cookies yet — start with whatever's
      publicly fetchable), normalized into `Job` and stored. Prove the
      adapter/dedup pipeline end to end before adding a second source
- [ ] 3. **Chrome extension: cookie sync** - Manifest V3 extension reading
      session cookies for the first source, `POST /sessions/sync` to the
      backend, `platform_sessions` table (encrypted cookie jar, csrf_token,
      expires_at). Swap the scraper from public fetch to authenticated fetch
      using the synced session
- [ ] 4. **Session health check** - scheduled job that pings an authenticated
      endpoint per source, marks `platform_sessions` healthy/expired, and pauses
      that source's scrape jobs on expiry instead of letting them fail loudly
- [ ] 5. **Second scraper source** - repeat step 2–3 for a second source against
      the same `JobSourceAdapter` interface, confirming the abstraction actually
      holds before scoring is built on top of it
- [ ] 6. **CV profile + embeddings** - `cv_profile` structured JSON (source of
      truth for tailoring), embed it and every scraped job with pgvector,
      similarity score as the cheap first filter
- [ ] 7. **LLM scoring pass** - for jobs above the similarity threshold, an LLM
      call returning `{match_score, missing_skills, reasoning}`, schema-validated
      before being saved to `job_scores`; anything that fails validation is
      logged, not silently dropped
- [ ] 8. **CV tailoring (constrained)** - LLM call that reorders/rewords
      `cv_profile` sections for a specific job, **never inventing facts** — diff
      the output against `cv_profile` and flag anything not traceable to the
      base data for manual review
- [ ] 9. **PDF rendering** - render the tailored CV to a print-ready PDF; wire
      the same pipeline for the cover letter once tailoring is proven
- [ ] 10. **Cover letter generation** - same structured-facts approach as step
      8, tone-anchored to a few writing samples, rendered alongside the CV
- [ ] 11. **Application state machine** - `applications` table with
      `discovered → scored → tailored → reviewed → applied → responded`,
      driven by the pipeline so far; nothing auto-applies yet — everything stops
      at `reviewed`
- [ ] 12. **Auto-apply gate (dry-run only)** - `automation_settings` /
      `source_settings` tables, global + per-source toggles, daily cap,
      `GET /settings/status` effective-state resolver. Dry-run mode only at
      this step: pipeline runs through to "would submit" and logs it, no real
      submission exists yet
- [ ] 13. **Real submission** - HTTP-based submission using the stored session,
      gated behind the dry-run-proven pipeline, the kill-switch check
      re-evaluated immediately before every submit call (not just at dispatch),
      and the daily cap enforced regardless of toggle state
- [ ] 14. **Extension: read-only status** - popup calls
      `GET /settings/status` on open and on a `chrome.alarms` interval, renders
      effective per-source state, no write path — link out to the dashboard for
      changes
- [ ] 15. **Dashboard** - job feed by state, per-source toggles (write), session
      health panel, AI cost per run, application history

## Auth notes (extension vs dashboard)

Decisions settled up front so step 3 and step 14 don't relitigate them:

- **One source of truth, one writer.** `automation_settings`/`source_settings`
  are only ever written through the dashboard's authenticated session. The
  extension never gets a write-capable token for these tables
- **Separate, scoped token for the extension** - Sanctum token with abilities
  limited to `sessions:write, status:read` only, so a leaked extension token
  can't flip auto-apply or read anything beyond status
- **Effective state is computed, never duplicated** -
  `global_auto_apply_enabled AND source_settings.auto_apply_enabled`, resolved
  server-side on every `/settings/status` call; no cached/derived copy stored
  anywhere
- **Kill-switch check happens at submit time, not dispatch time** - a job can
  sit in the queue for a while; the toggle is re-read immediately before the
  HTTP submit call fires, not just when the job was enqueued
- **Rate limiting is separate from the toggle** - the daily application cap and
  per-source token-bucket (scraping) are enforced independently of whether
  auto-apply is "on," so a toggle bug can't turn into a burst of applications

## Later (not v1)

Only if this grows past a personal tool. Not scheduled; revisit after v1 is
running reliably.

- Real-time toggle sync over websockets instead of polling
- Additional job sources beyond the first two
- Response tracking via email parsing (interview invites / rejections)
- Multi-profile support (different CV profiles for different role types)
- Packaging any part of this for someone else to run against their own accounts
  (would need a real ToS/auth rethink — out of scope as designed)