# androiddocker
Android Studio in a Docker container

Last time the repository was tested was in Debian Jessie with Docker version 17.05.0-ce, build 89658be, installed from https://apt.dockerproject.org/repo.

## Version 0.3 updates
1. The image is based upon Ubuntu 18.04 instead of Ubuntu 14.04.
2. Android Studio is now started from a script which optionally keeps the Docker container running after closing Android Studio when it is necessary to exit Android Studio for upgrading it.
3. The Cordova support is currently broken. I will fix it when I have the time and/or need for it.

## How to keep the Docker container running for upgrading Android Studio
1. `docker exec -it android-studio /bin/bash`
2. Outside of the container: `touch androidprojects/upgrade` (or alternatively `touch /projects/upgrade` inside the container).
3. Exit Android Studio.
4. Run the Android Studio upgrade script.
5. `ps ax` and find the PID of the process running `tail -f /dev/null`
6. `kill $PID` to kill the above process. This will cause the container to exit.
7. Next time you restart the container, you'll run the new version of Android Studio.

## Two Docker Images

The scripts in the repository now build two Docker images. One is for running Android Studio, and the other - for running Android Cordova builds.

## Installation
1. Clone or unzip the repository into your computer.
2. Download Android Studio for Linux from http://developer.android.com/sdk/index.html and save it somewhere.
3. `cd androiddocker/androiddocker`
4. `./build_androidstudio_image.sh yourzipfilesdirectory/android-studio-ide-*-linux.zip`; when asked for image name, enter tddpirate/androidstudio:1.3 if you want to build also the Android Cordova image.
5. The build_androidstudio_image.sh script auto-detects your uid/gid and the gids of `video` and `kvm` in your host system. You have the option of selecting different uid/gid for the developer.
6. When the image build completes, a container (whose default name is android-studio) is started from it and it starts the Android Studio environment.

## After installation
* Ensure that the libvirtd daemon is running, for example by using `sudo systemctl enable libvirtd`
* When you exit the Android Studio, the container stops execution.
* You can restart the container with `androiddocker/start_androidstudio.sh`
* Ensure that you have the rules in ./51-android.rules also defined also in your host system's /etc/udev/rules.d - you may accomplish this by `sudo cat ./51-android.rules >> /etc/udev/rules.d/51-android.rules`

## Building the Android Cordova container
If you want to build the Android Cordova container:

1. Exit the Android Studio, closing the android-studio container.
2. `cd androiddocker/androiddocker` if you are not already at the correct directory.
3. `./build_androidcordova_image.sh`
4. When the image build completes, a container (whose default name is android-cordova) is started from it and provides you with a command line where you run the various `cordova` commands.

You can restart the container with `./start_androidcordova.sh`

## Design considrations
* The containers created from the image, built from the scripts in this repository, are meant to run only on the same machine on which the image was built. This is contrary to the general Docker philosophy. 
* The image was designed to access the Android Studio and your project files from mounted host system directories, rather than keep them inside it. This way, you can upgrade the Android Studio without having to freeze the image, and use your favorite editor to edit your project files from the host system.

## To be fixed in the future
1. The script for building the tddpirate/androidcordova image currently expects the tddpirate/androidstudio image to have the tag 1.3. It will be fixed in the future if there is enough demand for the fix.
2. After exiting the android-cordova container, you need to manually stop it with `docker stop android-cordova`.

## Acknowledgements
Thanks to [@opyate](https://github.com/opyate) for his work on testing the scripts and giving feedback.
