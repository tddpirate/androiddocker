# androiddocker
Android Studio in a Docker container

Last time the repository was tested was in Debian Stretch with Docker version 17.05.0-ce, build 89658be, installed from https://apt.dockerproject.org/repo.

## Introduction
The scripts in the repository build two Docker images. One is for running Android Studio, and the other - for running Android Cordova builds.

### Design considrations
* The containers created from the images, built from the scripts in this repository, are meant to run only on the same machine on which the image was built. This is contrary to the general Docker philosophy. 
* The images were designed to access Android Studio and your project files from mounted host system directories, rather than keep them inside it. This way, you can upgrade the Android Studio without having to freeze the image, and use your favorite editor to edit your project files from the host system.

### To be fixed in the future
1. After exiting the android-cordova container, you need to manually stop it with `docker stop android-cordova`.

## Installation

### Prepare for installation
In order for the Android Emulator in Android Studio to run at hardware accelerated speeds, you need to ensure that your system has libvirt packages installed and that libvirtd daemon is running.

1. In Debian based systems, install using:
```
sudo apt-get install qemu-kvm libvirt-daemon-system bridge-utils
sudo adduser `id -un` libvirt
sudo adduser `id -un` libvirt-qemu
sudo adduser `id -un` kvm
```
2. Verify that libvirt is working: `virsh -c qemu:///system list`
3. Ensure that the libvirtd daemon is running: `systemctl status libvirtd`.  
  If it is not running, enable it: `sudo systemctl enable libvirtd`.
4. The following is not related to Android Emulator but will allow Android Studio to work with real devices connected to your computer via USB.  
  Ensure that you have the rules in `./51-android.rules` defined also in your host system's `/etc/udev/rules.d`.  
  You may accomplish this by `sudo cat ./51-android.rules >> /etc/udev/rules.d/51-android.rules`

TODO:
* Instructions for non-Debian systems.
* Instructions for non-systemd systems.

### Actual installation
1. Clone or unzip this repository (tddpirate/androiddocker) into your computer.
2. Download Android Studio for Linux from http://developer.android.com/sdk/index.html and save it somewhere.
3. `cd androiddocker/androiddocker`
4. `./build_androidstudio_image.sh yourzipfilesdirectory/android-studio-ide-*-linux.zip`; when asked for image name, enter tddpirate/androidstudio:1.3 if you want to build also the Android Cordova image.
5. The build_androidstudio_image.sh script auto-detects your uid/gid and the gids of `video` and `kvm` in your host system. You have the option of selecting different uid/gid for the developer.
6. When the image build completes, a container (whose default name is android-studio) is started from it and it starts the Android Studio environment.

### After installation
* When you exit the Android Studio, the container stops execution.
* You can restart the container using: `androiddocker/start_androidstudio.sh`

### Building the Android Cordova container
If you want to build the Android Cordova container:

1. Exit the Android Studio, closing the android-studio container.
2. `cd androiddocker/androiddocker` if you are not already at the correct directory.
3. `./build_androidcordova_image.sh`
4. A list of existing Android Studio images is shown (normally, there will be only one image) followed by request to confirm usage of the selected image. Hit ENTER.
5. You will be asked to select a name for the new image (Android Cordova). Accept the default by hitting ENTER.
6. The image build process will last for several seconds.
7. After it ends, you'll be prompted for a container name. Accept the default of android-cordova by hitting ENTER.
8. The container is started, providing you with a command line where you run the various `cordova` commands.
9. Create your Cordova projects in subdirectories of `/projects` inside the container.

You can restart the container with `androiddocker/start_androidcordova.sh`

## Maintenance

### How to keep the Docker container running for upgrading Android Studio
Normally, the Android Studio container stops running when you exit Android Studio. This behavior is problematic when upgrading Android Studio and the upgrade process requires it to close.

Therefore, the Android Studio container supports the following procedure to keep the container running as necessary to finish Android Studio upgrade.

1. `docker exec -it android-studio /bin/bash`
2. Outside of the container: `touch androiddocker/androidprojects/upgrade` (or alternatively `touch /projects/upgrade` inside the container).
3. Exit Android Studio.
4. Run the Android Studio upgrade script.
5. `ps ax` and find the PID of the process running `tail -f /dev/null`
6. `kill $PID` to kill the above process. This will cause the container to exit.
7. Next time you restart the container, you'll run the new version of Android Studio.

## Release Notes

### Version 0.4 updates
1. Support for running the Android Emulator in hardware accelerated speeds.
2. The dockerfile for building the Android Cordova development environment now follows the actual tag of the Android Studio image.

### Version 0.3 updates
1. The image is based upon Ubuntu 18.04 instead of Ubuntu 14.04.
2. Android Studio is now started from a script which optionally keeps the Docker container running after closing Android Studio when it is necessary to exit Android Studio for upgrading it.
3. The Cordova support is currently broken. I will fix it when I have the time and/or need for it.

## Acknowledgements
Thanks to [@opyate](https://github.com/opyate) for his work on testing the scripts and giving feedback.
