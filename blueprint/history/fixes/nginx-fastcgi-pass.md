# Fix: Nginx fastcgi_pass incorrectly pointing to app service instead of localhost
**Type:** Fix
**Status:** verified
**Branch:** fix/nginx-fastcgi-pass
**Fixes:** 

## The problem
The nginx configuration was incorrectly set to `fastcgi_pass app:9000;` which tries to connect to a service named 'app' on port 9000. However, the nginx and php-fpm are running in the same container, so the connection should be to `127.0.0.1:9000`. This caused PHP files to not be processed, resulting in 404 errors or source code being displayed.

## The fix
Changed the fastcgi_pass directive in nginx.conf from `app:9000;` to `127.0.0.1:9000;`. Also updated the docker-compose.yml to mount the custom nginx.conf over the default site configuration to ensure our nginx configuration is used.

## Build steps
- Update nginx.conf to set fastcgi_pass to 127.0.0.1:9000.
- Update docker-compose.yml to add a volume mount for ./nginx.conf:/etc/nginx/sites-enabled/default:ro.
- Restart the containers to apply the changes.
- Verify that the application is accessible and PHP files are executed correctly.
- Run the test suite to ensure no regressions.

## Verify
- Access http://localhost:8000/ and confirm the Laravel homepage loads.
- Access http://localhost:8000/index.php directly and confirm it returns the Laravel homepage (not source code or 404).
- Access static files like test.html and favicon.ico to ensure they still work.
- Run the PHPUnit test suite and confirm all tests pass.