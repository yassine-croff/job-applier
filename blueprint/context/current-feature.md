# Feature: Job schema + adapter interface

**From build-plan:** feature 1
**Build attempt:** 1
**Status:** verified

## Goal
Define the core Job model and JobSourceAdapter interface to enable normalized job storage and deduplication across multiple job sources, forming the foundation of the job scraping pipeline.

## Design reference
Not applicable (no visual or replication work required)

## In scope
- Job model with fields: source, title, company, description, requirements, url, salary, dedup_hash, discovered_at
- Job migration to create the jobs table with appropriate fields and indexes
- JobSourceAdapter interface defining the contract for job scrapers
- Deduplication mechanism using the dedup_hash field based on company+title+description
- Basic validation rules for Job model fields
- Relationship to other entities (JobScore, Application, etc. defined in data model)

## Out of scope
- Specific job scraper implementations (these will be built in later features)
- Advanced deduplication algorithms beyond hash-based matching
- Job search/filtering capabilities (to be implemented in dashboard feature)
- API endpoints for job management (to be implemented as needed)
- Worker processing of jobs (handled by queue system)
- Data retention/purging policies

## Build loop
feature/1: Each build cycle implements a complete vertical slice of the Job schema and adapter interface, ending when the Job model can be persisted, retrieved, and used for basic deduplication checks.

## Build steps
- [ ] Create Job migration with schema matching data model specification
- [ ] Create Job model with fillable fields, casts, and basic validation
- [ ] Define JobSourceAdapter interface with methods for scraping and normalizing jobs
- [ ] Implement dedup_hash generation logic based on company+title+description
- [ ] Create factory for Job model testing
- [ ] Write unit tests for Job model validation and dedup_hash generation
- [ ] Verify migration can be rolled back and reapplied without data loss

## Files / areas
- laravel/database/migrations/ - Job table migration
- laravel/app/Models/ - Job model (App\Models\Job)
- laravel/app/Contracts/ - JobSourceAdapter interface (App\Contracts\JobSourceAdapter)
- laravel/database/factories/ - Job factory
- tests/Feature/ - Job model tests
- tests/Unit/ - Job model unit tests

## Data / contracts
**Job model fields:**
- source: string (required) - Job board identifier (e.g., 'linkedin', 'indeed')
- title: string (required) - Job position title
- company: string (required) - Employer name
- description: text (nullable) - Full job description
- requirements: text (nullable) - Job requirements and qualifications
- url: string (required, unique) - Original job posting URL
- salary: string (nullable) - Compensation information
- dedup_hash: string (required, unique) - SHA256 hash of company+title+description for deduplication
- discovered_at: timestamp (required) - When job was first scraped

**JobSourceAdapter interface:**
- scrape(): Collection<Job> - Scrape jobs from source and return normalized Job instances
- getSource(): string - Return the source identifier for this adapter

## Notes for the AI
- The dedup_hash should be generated automatically when creating/updating a Job instance
- Use Laravel's model events (creating/updating) to auto-generate dedup_hash if not present
- Ensure proper indexing on dedup_hash for fast lookups
- Consider using string::uuid or similar for dedup_hash if hash collisions become a concern
- The JobSourceAdapter should be implemented by concrete scraper classes in later features
- Follow Laravel naming conventions and PSR-2 coding standards

## Open questions
- Should dedup_hash be SHA256 or another hashing algorithm? (Trade-off: collision resistance vs storage)
- Should discovered_at default to current timestamp or be explicitly set by scrapers?
- Should the Job model have soft deletes implemented?