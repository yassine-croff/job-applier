@echo off
title Job Applier Laravel Project

if "%~1"=="" (
    goto help
)

if /I "%~1"=="help" (
    goto :help
) else if /I "%~1"=="up" (
    goto :up
) else if /I "%~1"=="down" (
    goto :down
) else if /I "%~1"=="start" (
    goto :start
) else if /I "%~1"=="stop" (
    goto :stop
) else if /I "%~1"=="restart" (
    goto :restart
) else if /I "%~1"=="logs" (
    goto :logs
) else if /I "%~1"=="cli" (
    goto :cli
) else if /I "%~1"=="artisan" (
    shift
    goto :artisan
) else if /I "%~1"=="migrate" (
    goto :migrate
) else if /I "%~1"=="migrate-fresh" (
    goto :migrate-fresh
) else if /I "%~1"=="seed" (
    goto :seed
) else if /I "%~1"=="migrate-seed" (
    goto :migrate-seed
) else if /I "%~1"=="queue-work" (
    goto :queue-work
) else if /I "%~1"=="queue-listen" (
    goto :queue-listen
) else if /I "%~1"=="queue-restart" (
    goto :queue-restart
) else if /I "%~1"=="queue-retry" (
    shift
    goto :queue-retry
) else if /I "%~1"=="queue-flush" (
    goto :queue-flush
) else if /I "%~1"=="test" (
    goto :test
) else if /I "%~1"=="tinker" (
    goto :tinker
) else if /I "%~1"=="composer" (
    shift
    goto :composer
) else if /I "%~1"=="npm" (
    shift
    goto :npm
) else if /I "%~1"=="npm-run" (
    shift
    goto :npm-run
) else if /I "%~1"=="dev" (
    goto :dev
) else if /I "%~1"=="prod" (
    goto :prod
) else (
    echo Unknown command: %~1
    echo.
    goto help
)

:help
echo.
echo Job Applier Laravel Project - Batch File Commands
echo.
echo Installation:
echo   run.bat install         Install PHP and JS dependencies
echo.
echo Docker Compose:
echo   run.bat up              Start all services
echo   run.bat down            Stop and remove all services
echo   run.bat start           Start existing containers
echo   run.bat stop            Stop running containers
echo   run.bat restart         Restart all services
echo.
echo Application:
echo   run.bat logs            View application logs
echo   run.bat cli             Open shell in app container
echo   run.bat artisan [cmd]   Run Laravel Artisan command
echo.
echo Database:
echo   run.bat migrate         Run database migrations
echo   run.bat migrate-fresh   Drop all tables and re-run migrations
echo   run.bat seed            Run database seeders
echo   run.bat migrate-seed    Run migrations and seeders
echo.
echo Queues:
echo   run.bat queue-work      Start queue worker (processes jobs once)
echo   run.bat queue-listen    Start queue listener (long-running)
echo   run.bat queue-restart   Restart queue workers
echo   run.bat queue-retry [id] Retry failed jobs (use "all" for all)
echo   run.bat queue-flush     Flush (delete) failed jobs
echo.
echo Development:
echo   run.bat test            Run PHPUnit tests
echo   run.bat tinker          Laravel Tinker REPL
echo   run.bat composer [cmd]  Run Composer command
echo   run.bat npm [cmd]       Run NPM command
echo   run.bat npm-run [script] Run NPM script
echo   run.bat dev             Start Vite development server
echo   run.bat prod            Build for production
echo.
echo Examples:
echo   run.bat artisan route:list
echo   run.bat composer update
echo   run.bat npm run dev
echo   run.bat queue-retry all
echo.
goto :eof

:install
echo Installing dependencies...
docker-compose run --rm composer install
docker-compose run --rm npm install
goto :eof

:up
docker-compose up -d
goto :eof

:down
docker-compose down
goto :eof

:start
docker-compose start
goto :eof

:stop
docker-compose stop
goto :eof

:restart
docker-compose restart
goto :eof

:logs
docker-compose logs -f app
goto :eof

:cli
docker-compose exec app bash
goto :eof

:artisan
if "%~1"=="" (
    docker-compose exec app php artisan
) else (
    docker-compose exec app php artisan %*
)
goto :eof

:migrate
docker-compose exec app php artisan migrate
goto :eof

:migrate-fresh
docker-compose exec app php artisan migrate:fresh
goto :eof

:seed
docker-compose exec app php artisan db:seed
goto :eof

:migrate-seed
docker-compose exec app php artisan migrate --seed
goto :eof

:queue-work
docker-compose exec app php artisan queue:work --verbose
goto :eof

:queue-listen
docker-compose exec app php artisan queue:listen --verbose
goto :eof

:queue-restart
docker-compose exec app php artisan queue:restart
goto :eof

:queue-retry
if "%~1"=="" (
    docker-compose exec app php artisan queue:retry all
) else (
    docker-compose exec app php artisan queue:retry %*
)
goto :eof

:queue-flush
docker-compose exec app php artisan queue:flush
goto :eof

:test
docker-compose exec app php artisan test
goto :eof

:tinker
docker-compose exec app php artisan tinker
goto :eof

:composer
if "%~1"=="" (
    docker-compose run --rm composer
) else (
    docker-compose run --rm composer %*
)
goto :eof

:npm
if "%~1"=="" (
    docker-compose run --rm npm
) else (
    docker-compose run --rm npm %*
)
goto :eof

:npm-run
if "%~1"=="" (
    echo Error: Please specify an npm script to run
    echo Example: run.bat npm-run dev
) else (
    docker-compose run --rm npm run %*
)
goto :eof

:dev
docker-compose run --rm npm run dev
goto :eof

:prod
docker-compose run --rm npm run production
goto :eof