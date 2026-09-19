# Job Applier

A Laravel-based job application management system.

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Make (optional, for using the Makefile)

### Installation

1. Copy the environment file:
   ```bash
   cp .env.example .env
   ```

2. Start the application:
   ```bash
   make up
   ```

3. Install PHP dependencies:
   ```bash
   make install
   ```

4. Generate application key:
   ```bash
   make artisan key:generate
   ```

5. Run database migrations:
   ```bash
   make migrate
   ```

6. (Optional) Seed the database:
   ```bash
   make seed
   ```

The application will be available at http://localhost:8000

## Makefile Commands

See the [Makefile](Makefile) for available commands. Some useful ones:

- `make help` - Show all available commands
- `make up` - Start all services
- `make down` - Stop all services
- `make cli` - Open shell in app container
- `make artisan` - Run Laravel Artisan commands (e.g., `make artisan route:list`)
- `make migrate` - Run database migrations
- `make queue-work` - Start queue worker
- `make queue-listen` - Start queue listener
- `make test` - Run PHPUnit tests

## Queue Management

The application uses Laravel's queue system. To process jobs:

```bash
# Process jobs once and exit
make queue-work

# Keep listening for new jobs (long-running)
make queue-listen

# Restart queue workers
make queue-restart

# Retry failed jobs
make queue-retry all

# View failed jobs
make artisan queue:failed
```

## Environment

Make sure to update your `.env` file with appropriate values for:
- Database credentials
- Mail settings
- Queue connection
- Any third-party API keys

## Docker Services

- **app**: PHP application with Nginx
- **db**: MySQL 8.0 database
- **redis**: Redis cache and queue driver

## License

MIT