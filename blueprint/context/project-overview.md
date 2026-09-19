# Job Applier - Project Overview

<!-- blueprint:source-hash 469fd670748832e84257d936cd2e2bafc8ff4d0b47f976954521a90cd16bd584 -->

> A personal automation tool that streamlines backend job applications by fetching, scoring, tailoring materials, and optionally submitting applications.

## Problem

Finding and applying to backend jobs is repetitive and low-signal: the same job gets scraped across ten boards, most postings aren't a real fit, and every application needs a CV tweaked to match the posting plus a fresh cover letter. Doing this by hand doesn't scale past a handful of applications a day, and much time goes into mechanical work rather than judgment. This project automates the pipeline end to end while keeping human oversight.

## Users

Primary: The developer, applying to backend/AI-adjacent roles. Secondary: Portfolio showcase for interviews demonstrating scraping, queues, AI integration, and safety-conscious design. This is a personal tool run against the developer's own accounts (LinkedIn, Indeed), not a multi-tenant product.

## Usage model

Personal-scale, single-user tool running against the developer's own job-board accounts. Not designed for multi-tenant use or automation of others' sessions. Trust boundary: user owns all data and sessions. No enterprise, hostile-user, or compliance requirements inferred. Availability requirements are personal use only. Audit constraints: manual review gates for sensitive operations.

## Features

The MVP feature set in build-plan order - one line of purpose each. Flag the headline feature.

1. **Job schema + adapter interface** - Define core Job model and scraper interface for normalized job storage and deduplication
2. **First HTTP scraper (one source)** - Implement a scraper for one job source using Laravel HTTP client, storing normalized jobs
3. **Chrome extension: cookie sync** - Build Manifest V3 extension to sync session cookies from job boards to backend
4. **Session health check** - Add scheduled job to monitor session health and pause scraping on expiry
5. **Second scraper source** - Implement scraper for a second source to validate the adapter abstraction
6. **CV profile + embeddings** - Store CV as structured data and create vector embeddings for similarity matching
7. **LLM scoring pass** - Use LLM to score job-CV matches with structured output validation
8. **CV tailoring (constrained)** - Use LLM to tailor CV wording per job without inventing facts
9. **PDF rendering** - Generate print-ready PDFs of tailored CVs
10. **Cover letter generation** - Generate cover letters using same structured-facts approach as CV tailoring
11. **Application state machine** - Track applications through states: discovered → scored → tailored → reviewed → applied → responded
12. **Auto-apply gate (dry-run only)** - Implement toggles and daily cap with dry-run mode to test pipeline
13. **Real submission** - Enable actual job applications using stored sessions, gated by dry-run validation
14. **Extension: read-only status** - Add popup to extension showing effective auto-apply state
15. **Dashboard** - Build UI showing job feed, controls, session health, and metrics

## Data model

The concrete shape of stored data, derived from planned features.

### Job

- `source` (string) - Job board identifier (LinkedIn, Indeed, etc.)
- `title` (string) - Job position title
- `company` (string) - Employer name
- `description` (text) - Full job description
- `requirements` (text) - Job requirements and qualifications
- `url` (string) - Original job posting URL
- `salary` (string) - Compensation information
- `dedup_hash` (string) - Hash for deduplication across sources
- `discovered_at` (datetime) - When job was first scraped

### JobScore

- `match_score` (float) - LLM-generated match score (0-1)
- `missing_skills` (array) - Skills identified as missing from CV
- `reasoning` (text) - LLM explanation of the match decision
- `job_id` (foreign key) - Reference to Job
- `validated` (boolean) - Whether LLM output passed schema validation

### PlatformSession

- `source` (string) - Job board identifier
- `encrypted_cookie_jar` (text) - Securely stored session cookies
- `csrf_token` (string) - CSRF token for session integrity
- `expires_at` (datetime) - Session expiration timestamp
- `last_synced_at` (datetime) - Last cookie sync timestamp
- `health_status` (enum) - healthy/expired/error state

### AutomationSettings

- `global_auto_apply_enabled` (boolean) - Master toggle for auto-apply functionality
- `daily_application_cap` (integer) - Maximum applications per day

### SourceSettings

- `source` (string) - Job board identifier
- `auto_apply_enabled` (boolean) - Per-source toggle for auto-apply

### Application

- `job_id` (foreign key) - Reference to Job
- `state` (enum) - application state machine: discovered → scored → tailored → reviewed → applied → responded
- `tailored_cv_reference` (string) - Reference to stored tailored CV file
- `cover_letter_reference` (string) - Reference to stored cover letter file
- `submitted_at` (datetime) - When application was submitted
- `response_status` (string) - Application response from employer

### CvProfile

- `structured_data` (text/json) - CV as structured JSON/YAML (source of truth for tailoring)

## Tech stack

The stack from project-plan.md, one line each on what it's for.

- **Laravel (PHP)** - Core API, orchestration, and job pipeline
- **Redis + Horizon** - Queue management for scraping, embedding, LLM calls, and PDF rendering
- **Postgres + pgvector** - Job and CV embeddings for similarity search
- **Chrome extension (Manifest V3)** - Cookie/session sync only with scoped API access
- **HTTP client (Laravel HTTP)** - Scraping with browser-like headers (no headless browser)
- **Anthropic/OpenAI API** - Scoring, CV tailoring, and cover letter generation with validated responses
- **Redis token bucket** - Per-source rate limiting for scraping
- **Docker Compose** - Local development stack orchestration
- **GitHub Actions** - CI/CD pipeline

## Monetization

Not monetized. This is a personal-use automation tool and a portfolio project, not a product — running it against someone else's LinkedIn/Indeed session isn't in scope, so there's no path to "other users" without rethinking the ToS and auth model entirely.

## UI/UX

Look, feel, and the main routes/screens.

- `/dashboard` - Job feed with filters by source and match score, settings panel with toggles, session health panel
- `/jobs/{id}` - Individual job view showing score breakdown, tailored CV/cover letter (editable before review), application state
- `/extensions/status` - Chrome extension popup: sync status per platform and effective auto-apply state (read-only)

## Deployment

Target host: Local development via Docker Compose; production deployment would require similar container orchestration.
App type: Web application with background workers.
Build/start commands: `docker-compose up` for full stack; `make dev` for Vite dev server; `make up` for Docker services.
Output directory: Public assets compiled via Vite.
Env vars: API keys for Anthropic/OpenAI, database credentials, session encryption secrets.
Database/storage needs: Postgres for relational data, Redis for caching and queues, object/storage for generated PDFs.
Workers/cron jobs: Redis Horizon for queue workers; scheduled jobs for session health checks and cookie sync.
Health path: `/health` endpoint for container health checks.
Domain notes: Local development via localhost; production would require custom domain.

> TODO if the deployment target is not decided yet.

## Open questions

> TODOs and contradictions found between the two plans. Resolve them in the plans, then re-run /overview. Delete this section when empty.

No contradictions found between project-plan.md and build-plan.md. The plans are consistent: both describe a personal job automation pipeline with scraping, AI scoring, CV tailoring, and gated auto-apply. The build plan provides implementation steps that align with the features listed in the project plan.
