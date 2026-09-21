# Fix: PHP tempnam() failing due to incorrect temporary directory configuration
**Type:** Fix
**Status:** verified
**Branch:** fix/tempnam-sys-temp-dir

## The problem
PHP's tempnam() function was failing with the notice "tempnam(): file created in the system's temporary directory" and returning false when trying to create temporary files in the configured temporary directory (/tmp/php). This was caused by:
1. A dual filesystem object issue where the /tmp/php path appeared as two different filesystem objects (inode 418461 from PHP-FPM perspective vs inode 418469 from host perspective)
2. PHP-FPM not having write permissions to its view of the /tmp/php directory despite the directory appearing readable and writable from the host perspective
3. The sys_temp_dir setting being restricted to PHP_INI_SYSTEM, preventing runtime changes via ini_set()

## The fix
Changed the PHP temporary directory configuration from /tmp/php to /tmp by updating the custom php.ini file:
- Set sys_temp_dir = "/tmp"
- Set upload_tmp_dir = "/tmp"
This leverages the system's default temporary directory which we verified works correctly for tempnam() operations from both CLI and PHP-FPM perspectives.

## Build steps
- Updated php/php.ini to set sys_temp_dir and upload_tmp_dir to /tmp instead of /tmp/php
- Restarted the app container to apply the PHP configuration changes
- Verified that tempnam() now works correctly through web requests
- Confirmed the Laravel application homepage loads correctly (HTTP 200)

## Verify
- Access http://localhost:8000/ and confirm the Laravel homepage loads (returns 200)
- Create and access a test script that calls tempnam() to verify it succeeds without notices
- Test that file upload functionality works correctly with the new temporary directory
- Run any existing test suite to ensure no regressions