# Coding Standards

> Your conventions. Edit these once to match your stack. The defaults below
> assume Laravel + PHP + Blade + Tailwind + Vite; change or trim anything that
> doesn't fit your project.
>
> Run `/onboard` after installing the Blueprint. It tunes this file to the real
> project stack, along with `AGENTS.md`, `CLAUDE.md` when present,
> `ai-interaction.md`, `.gitignore`, and README placement. Review the result
> before `/overview`.
## PHP

- Use PHP 8.2+ features (match expression, nullsafe operator, etc.)
- Enable strict types (`declare(strict_types=1);`) in all PHP files
- Prefer type declarations for function arguments and return types
- Use interfaces and abstraction where appropriate
- Follow PSR-12 coding standard
- Use Laravel's Eloquent ORM for database interactions
- Keep controllers thin; move business logic to service classes or actions
- Use form requests for validation of HTTP requests
- Avoid putting database queries in routes or controllers; use repositories or service classes
## Blade Templates

- Use Blade templating engine for server-rendered HTML
- Keep templates free of complex logic; use view composers or service classes for data preparation
- Use Blade components for reusable UI elements
- Leverage Blade directives (`@if`, `@else`, `@foreach`, `@forelse`, `@switch`) for control flow
- Avoid inline PHP in Blade templates; use Blade syntax instead
- Use layout extends and sections for consistent structure

## File Organization

- App code: `app/` directory (Controllers, Models, Services, etc.)
- Configuration: `config/` directory
- Database migrations: `database/migrations/`
- Database seeders: `database/seeders/`
- Public assets: `public/` directory (compiled assets)
- Resources: `resources/` directory (views, raw JS/CSS)
- Routes: `routes/` directory (web.php, console.php, api.php, etc.)
- Tests: `tests/` directory (Feature and Unit)

## Naming

- Classes: PascalCase (`UserController.php`)
- Interfaces: Prefix with `I` (e.g., `IUserService.php`) or use descriptive names without prefix (follow Laravel conventions)
- Methods: camelCase
- Constants: UPPER_SNAKE_CASE
- Blade files: kebab-case (`user-profile.blade.php`)
- Configuration files: snake_case (`app_config.php`)
- Routes: snake_case in route definitions, but controller methods camelCase

## Styling

- Tailwind CSS for styling (via Vite)
- Use Tailwind utility classes in Blade templates and components
- Configure Tailwind via `vite.config.js` and `tailwind.config.cjs` (if present)
- Extract repeated utility patterns into Blade components or template partials
- No inline styles in HTML; use Tailwind classes
- Dark mode: use Tailwind's dark mode variant (`dark:`)

## JavaScript/Vite

- Use ES6+ syntax (let/const, arrow functions, etc.)
- Keep JavaScript files in `resources/js/` and compile with Vite
- Use Vite for frontend asset bundling
- Prefer importing modules over global variables
- Use Laravel Mix? Actually we are using Vite directly via Laravel Vite Plugin
- For reactivity, consider using Alpine.js or Vue.js if needed (but check project setup)
## Database

- Use Laravel's Eloquent ORM for all database operations
- Use migrations for schema changes (`php artisan migrate`)
- Use seeders for test data (`php artisan db:seed`)
- Run `php artisan migrate:status` to verify migrations are in sync
- Production deployments must run migrations before starting the app
- Use database transactions for multiple related operations
- Use Eloquent relationships (hasMany, belongsTo, etc.) for data modeling

## Data Fetching and API

- For server-rendered pages, fetch data in controllers or view composers and pass to Blade views
- For API endpoints, use Laravel's routing and controller methods to return JSON responses
- Validate all incoming data with Form Requests or Validator facade
- Use Laravel's authorization gates and policies for access control
- Scope user-owned queries by the authenticated user (using `auth()->id()` or `Auth::user()`); never trust client-supplied user IDs
- Use API resources to transform Eloquent models for JSON responses

## Error Handling

- Use try/catch for exceptional cases where recovery is possible
- Laravel's exception handler will catch uncaught exceptions; customize via `App\Exceptions\Handler`
- Return appropriate HTTP status codes (400 for client errors, 500 for server errors)
- For API endpoints, return JSON error responses with message and possibly validation errors
- In Blade views, check for session flash errors or validation errors from `$errors` variable
- Use Laravel's logging facilities (`Log` facade) for logging errors and warnings

## Testing

We have PHPUnit as the test runner (see `make test` command in `AGENTS.md`).
- Write unit tests for isolated logic (helpers, service classes, etc.)
- Write feature tests for HTTP endpoints and application flows
- Use Laravel's testing helpers (`actingAs`, `assertDatabaseHas`, etc.)
- Mock external dependencies (HTTP calls, third-party services) using facades or Mockery
- Tests live in `tests/Feature` and `tests/Unit` directories
- Run tests via `make test` (which executes `docker-compose exec app php artisan test`)
- The test command is the verification gate for logic-bearing steps
## Browser Verification

For UI and integration behavior, prefer real browser evidence over reading the code and assuming it works.

- Browser automation is separately opt-in through `/tests browser`. That setup
  reuses a compatible runner or prefers Playwright for supported projects, then
  documents the exact command as `Browser tests` in `AGENTS.md`.
- When `Browser tests` is declared, add focused coverage for stable behavioral
  done-whens when it is proportionate, and run the documented command during
  `/check`. Do not assume it proves visual fidelity, real authenticated-profile
  behavior, browser chrome, or another claim the test does not observe.
- If no Browser tests command is declared, do not add a runner silently in the
  middle of an unrelated feature. Use the available dev server, browser
  screenshots, build output, API output, or manual evidence instead.
- Browser tests are not part of the default Verify command or CI unless the user
  separately chooses that slower gate.
- Browser evidence is especially important for flows that click, type, submit,
  navigate, download files, render complex layouts, or depend on client-side
  state.

## Code Quality

- No commented-out code unless specified
- No unused imports or variables
- Keep functions under 50 lines when possible
- Keep classes under 200 lines when possible (single responsibility principle)

## Comments

Write code that explains itself; comment only what the code cannot say.
Over-commenting is a common AI tell, so resist it.

- Comment the **why**, not the **what**. Delete any comment that restates the code.
- No banner/header blocks, section dividers, or step-by-step narration of obvious
  code. A file does not need a comment announcing each region.
- A comment earns its place only when it captures something the code can't: a
  non-obvious decision, a gotcha or workaround, why a value is what it is, or a
  link to a spec or issue.
- Prefer self-documenting names and small functions over explanatory comments.
- Keep doc comments minimal: a one-line purpose on an exported type or function is
  plenty; don't write PHPDot that just repeats the signature.
- When in doubt, leave the comment out.

## Writing

- No em dashes (U+2014) in generated content: docs, comments, commit messages,
  READMEs, specs. They read as AI-generated.
- Use a hyphen for `term - description` separators; rephrase prose with commas,
  parentheses, or a colon. Avoid en dashes and the ellipsis character too.
