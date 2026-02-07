@echo off
echo MOODLE INSTALLER
echo.
echo Ensure the Docker container is RUNNING.
echo Press ENTER to continue
pause

echo.
echo Installing Game Plugin (Gamification)...
docker cp ./plugins/game moodle-docker-webserver-1:/var/www/html/mod/game

echo Installing Level Up XP Plugin (Gamification)...
docker cp ./plugins/xp moodle-docker-webserver-1:/var/www/html/blocks/xp

echo Installing Wavefront Plugin (Augmented Reality)...
docker cp ./plugins/wavefront moodle-docker-webserver-1:/var/www/html/mod/wavefront

echo Installing Boost Union Theme...
docker cp ./plugins/boost_union moodle-docker-webserver-1:/var/www/html/theme/boost_union

echo.
echo Fixing permissions...
docker exec -u 0 moodle-docker-webserver-1 chown -R www-data:www-data /var/www/html/mod
docker exec -u 0 moodle-docker-webserver-1 chown -R www-data:www-data /var/www/html/blocks
docker exec -u 0 moodle-docker-webserver-1 chown -R www-data:www-data /var/www/html/theme

echo.
echo Copy completed
echo.
echo Now follow these steps:
echo 1. Go to http://localhost:8000 and log in as admin;
echo 2. Click on "Upgrade Moodle database now" when prompted;
echo 3. Import the course from the .mbz file (see README).
pause
