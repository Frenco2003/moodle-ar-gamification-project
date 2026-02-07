# Guide for Installing a Moodle-Docker Environment and Cloning a Pilot Course

This was created for the Complex System Design course of University of Camerino.

The project name is: _"Extension of the Moodle Platform with Innovative Plugins \& Teaching Templates"_.

## Moodle-Docker Installation

> [!NOTE]
> This part outlines how to deploy a local Moodle installation using Docker. By following these steps, educators can quickly set up a fully functional Moodle site in their own environment.

[Official Documentation](https://moodledev.io/general/development/gettingstarted)

> [!TIP]
> The following commands are not scripts; they must be copied and executed one by one.
> If you see a backslash at the end of a command, it represents a line break, and the following line should be treated as a continuation of the current command.

### 1. Install Prerequisites

```sh
git -v
docker -v
docker-compose  -v
```

### 2. Create Working Directory

```sh
mkdir moodle-dev
cd moodle-dev
```

### 3. Clone the Moodle-Docker Repository

```sh
git clone https://github.com/moodlehq/moodle-docker
cd moodle-docker
```

### 4. Set Environment Variables

```sh
export MOODLE_DOCKER_WWWROOT=./moodle
export MOODLE_DOCKER_DB=pgsql
export MOODLE_DOCKER_PHP_VERSION=8.2
```

### 5. Download Moodle into the Directory Defined by MOODLE_DOCKER_WWWROOT

```sh
git clone -b MOODLE_405_STABLE https://github.com/moodle/moodle ./moodle
```

### 6. Copy the Docker Configuration File into the Moodle Folder

```sh
cp config.docker-template.php moodle
cd moodle
mv config.docker-template.php config.php
cd ..
```

### 7. Start the Docker Container

```sh
bin/moodle-docker-compose up -d
```

### 8. Wait for the Database to Become Ready

```sh
bin/moodle-docker-wait-for-db
```

### 9. Install Moodle using the CLI

```sh
bin/moodle-docker-compose exec webserver php admin/cli/install_database.php \
--agree-license \
--fullname="Docker Moodle" \
--shortname="docker_moodle" \
--summary="Docker Moodle site" \
--adminpass="test" \
--adminemail="admin@example.com"
```

## Cloning the Pilot Course

> [!NOTE]
> We have also developed a pilot course to serve as a starting point for educators. It includes pre-configured plugins designed to enhance gamification and support augmented reality implementations.

### 1. System prerequisites

Before starting the installation, ensure the host machine meets the following requirements:
+ **Docker**: Installed and running;
+ **Moodle-Docker Repository**: Downloaded and ready for use (standard course configuration);
+ **Internet Connection**: Active (required to download initial Docker images and for AR tunneling);
+ **Mobile Browser**: a mobile browser with WebXR support installed on the test device.

### 2. Starting the Moodle Environment

If the Moodle environment is not yet active, start it via the terminal from the Moodle-Docker project folder or with Docker Desktop:

```sh
docker-compose up -d
```

Wait for the moodle-docker-webserver-1 container to be fully operational. To verify it just open the [localhost page](http://localhost:8000) on your browser. If the Moodle installation or login page appears, proceed.

### 3. Automatic Plugins Installation

This package includes a script that automatically injects the necessary plugins (mod_game, block_xp, theme_boost_union, mod_wavefront) into the Docker container:
1. Open the extracted folder **Deliverable_Group_MoodleAR-Gamification**.
1. Run the installation script:
    + **Windows**: double-click on install_windows.bat
    + **Linux/Mac**: open the terminal in the folder, make the script executable with `chmod +x install_linux.sh`, and run it `./install_linux.sh`
1. Wait for the message "Copy completed".

**Database Update**:
1. Go to http://localhost:8000 and log in as admin;
2. Moodle will detect the new plugins, so click on "Upgrade Moodle database now";
3. Click "Continue" until you reach the Dashboard.

### 4. Course Content Import

The installed plugins are "empty shells." To load the lessons, 3D models, and configured quizzes, you must restore the included backup:
1. In Moodle, navigate to: Site administration > Courses > Restore course;
2. In the file upload area, drag and drop the file backup_example_course.mbz located in the content folder of this package;
3. Click Restore;
4. Scroll down and click Continue;
5. In the "Restore into this course" section, select "Restore as a new course" and click Continue;
6. Proceed by clicking Next until the end, then click Perform restore;
> [!IMPORTANT]
> If the restore status remains stuck on "In progress" (because the system timer is paused), force it by running this command in your terminal:
> ```sh
> docker exec -u 0 moodle-docker-webserver-1 php admin/cli/cron.php
> ```
> If this doesn't work go to Site administration > Server > Tasks > Ad hoc tasks and there should be a line like Asynchronous restore, click on "Run now" or "Run All". Once the command finishes, reload the Moodle page to see the course.

### 5. Graphical Configuration with Theme

The course backup does not overwrite the global site theme. To activate the correct interface:
1. Go to: Site administration > Appearance > Themes > Theme selector;
2. Click Change theme next to "Default";
3. Select Boost Union.

### 6. Augmented Reality Activation

To view 3D models in AR from a mobile phone, Moodle must be accessible via public HTTPS. We will use the open-source tool [Zrok](https://zrok.io).

1. **Starting the Tunnel**
    1. Download Zrok from the [official page](https://netfoundry.io/docs/zrok/guides/install)
    1. Start the application tunnel `zrok share public localhost:8000 --headless`
    1. Copy the generated link (e.g., https://xyz-123.share.zrok.io).
    1. Do not close the terminal!
   
1. **Editing the config.php File**
    1. Open the config.php file located in the main Moodle folder.
    1. Replace the Web address configuration ($CFG->wwwroot) with the following code block
        ```php
        // ====================================================
        // ZROK CONFIGURATION (AR MOBILE SETUP)
        // ====================================================
        // 1. SILENCE ERRORS (For a clean demo)
        error_reporting(0);
        @ini_set('display_errors', '0');
        // 2. PASTE THE LINK GENERATED BY ZROK BELOW
        // Warning: No space before https and no trailing slash
        $CFG->wwwroot = 'https://PASTE_LINK_COPIED_FROM_TERMINAL_HERE';
        // 3. PROXY SETTINGS
        $CFG->reverseproxy = false; // Keep false to avoid Zrok errors
        $CFG->sslproxy = true; // Mandatory for HTTPS
        $_SERVER['HTTPS'] = 'on'; // Force SSL recognition
        // 4. DISABLE DEBUGGING
        $CFG->debug = 0;
        $CFG->debugdisplay = false;
        // ====================================================
        ```
    1. Save the file
    1. To apply the changes, restart the web container from another terminal
        ```sh
        docker restart moodle-docker-webserver-1
        ```

### 7. Final Test: How to Use the Demo

Everything is now ready. Here is how to test the functionalities:
1. **PC Access**, open the tunneled Zrok link in your PC browser and log in;
1. **Mobile Access**, open the same link on your smartphone using an WebXR supporting browser;
1. **AR Test (Module 1)**;
    + Open the "Immersive Learning" course.
    + Go to Module 1 and open the "Structural Framework" (Skeleton) activity.
    + On PC: Rotate and zoom the model with your mouse.
    + On Mobile: Tap the "View in AR" icon in the bottom right corner to project the skeleton into your room.
1. **Gamification Test (Module 2)**;
    + Open the "AI Millionaire Challenge" activity.
    + Answer a few questions.
    + Verify that the "Level Up XP" side block awards experience points if you get them correctly.
