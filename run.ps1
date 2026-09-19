# Job Applier Laravel Project - PowerShell Script

function Show-Help {
    Write-Host "`nJob Applier Laravel Project - PowerShell Commands`n" -ForegroundColor Green
    Write-Host "Installation:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 install         Install PHP and JS dependencies`n" -ForegroundColor Cyan

    Write-Host "Docker Compose:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 up              Start all services" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 down            Stop and remove all services" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 start           Start existing containers" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 stop            Stop running containers" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 restart         Restart all services" -ForegroundColor Cyan "`n"

    Write-Host "Application:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 logs            View application logs" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 cli             Open shell in app container" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 artisan [cmd]   Run Laravel Artisan command" -ForegroundColor Cyan "`n"

    Write-Host "Database:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 migrate         Run database migrations" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 migrate-fresh   Drop all tables and re-run migrations" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 seed            Run database seeders" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 migrate-seed    Run migrations and seeders" -ForegroundColor Cyan "`n"

    Write-Host "Queues:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 queue-work      Start queue worker (processes jobs once)" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 queue-listen    Start queue listener (long-running)" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 queue-restart   Restart queue workers" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 queue-retry [id] Retry failed jobs (use 'all' for all)" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 queue-flush     Flush (delete) failed jobs" -ForegroundColor Cyan "`n"

    Write-Host "Development:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 test            Run PHPUnit tests" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 tinker          Laravel Tinker REPL" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 composer [cmd]  Run Composer command" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 npm [cmd]       Run NPM command" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 npm-run [script] Run NPM script" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 dev             Start Vite development server" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 prod            Build for production" -ForegroundColor Cyan "`n"

    Write-Host "Examples:" -ForegroundColor Green
    Write-Host "  .\run.ps1 artisan route:list" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 composer update" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 npm run dev" -ForegroundColor Cyan
    Write-Host "  .\run.ps1 queue-retry all" -ForegroundColor Cyan
}

if ($args.Count -eq 0) {
    Show-Help
    exit 0
}

$command = $args[0].ToLower()

switch ($command) {
    "help" { Show-Help; break }
    "up" { & docker-compose up -d; break }
    "down" { & docker-compose down; break }
    "start" { & docker-compose start; break }
    "stop" { & docker-compose stop; break }
    "restart" { & docker-compose restart; break }
    "logs" { & docker-compose logs -f app; break }
    "cli" { & docker-compose exec app bash; break }
    "migrate" { & docker-compose exec app php artisan migrate; break }
    "migrate-fresh" { & docker-compose exec app php artisan migrate:fresh; break }
    "seed" { & docker-compose exec app php artisan db:seed; break }
    "migrate-seed" { & docker-compose exec app php artisan migrate --seed; break }
    "queue-work" { & docker-compose exec app php artisan queue:work --verbose; break }
    "queue-listen" { & docker-compose exec app php artisan queue:listen --verbose; break }
    "queue-restart" { & docker-compose exec app php artisan queue:restart; break }
    "queue-flush" { & docker-compose exec app php artisan queue:flush; break }
    "test" { & docker-compose exec app php artisan test; break }
    "tinker" { & docker-compose exec app php artisan tinker; break }
    "dev" { & docker-compose run --rm npm run dev; break }
    "prod" { & docker-compose run --rm npm run production; break }
    default {
        # Handle commands with arguments
        if ($command.StartsWith("artisan")) {
            $artisanArgs = $args[0].Substring("artisan".Length).Trim()
            if ($artisanArgs) {
                & docker-compose exec app php artisan $artisanArgs
            } else {
                & docker-compose exec app php artisan
            }
        } elseif ($command.StartsWith("composer")) {
            $composerArgs = $args[0].Substring("composer".Length).Trim()
            if ($composerArgs) {
                & docker-compose run --rm composer $composerArgs
            } else {
                & docker-compose run --rm composer
            }
        } elseif ($command.StartsWith("npm")) {
            if ($command.Equals("npm")) {
                & docker-compose run --rm npm
            } elseif ($command.StartsWith("npm-run")) {
                $script = $args[0].Substring("npm-run".Length).Trim()
                if ($script) {
                    & docker-compose run --rm npm run $script
                } else {
                    Write-Error "Please specify an npm script to run"
                    Write-Error "Example: .\run.ps1 npm-run dev"
                }
            } else {
                $npmArgs = $args[0].Substring("npm".Length).Trim()
                & docker-compose run --rm npm $npmArgs
            }
        } elseif ($command.StartsWith("queue-retry")) {
            $ids = $args[0].Substring("queue-retry".Length).Trim()
            if ($ids) {
                & docker-compose exec app php artisan queue:retry $ids
            } else {
                & docker-compose exec app php artisan queue:retry all
            }
        } else {
            Show-Help
        }
        break
    }
}