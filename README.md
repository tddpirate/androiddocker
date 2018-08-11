# androiddocker - run Android Studio inside a Docker container

## When and why to install and run Android Studio inside a Docker container?
1. The Linux version of Android Studio is tested by Google on Ubuntu 14.04 LTS.  
To be on the safe side, you'll want to run it on Ubuntu as well, even if you do the rest of your work using a different Linux distribution.  
Given this, I have good experience running Android Studio on Ubuntu 18.04.
2. Android Studio also requires a GNOME or KDE desktop, and you may want to use a more lightweight desktop for other work.
3. You may need different versions of JDK or other packages for your Android Studio work.

## Introduction
The scripts in the repository build two Docker images. One is for running Android Studio, and the other - for running Android Cordova builds.

In the following description, `yourdir` is where you install `androiddocker`.  
Once you have installed androiddocker in your system, `yourdir` has three subdirectories as follows.
* `yourdir/androiddocker/androiddocker` - files for building the Docker images and containers as well as running them and performing various operations. This subdirectory is not visible from inside the containers.
* `yourdir/androiddocker/androidstudio` - is where the Android Studio files are located. This subdirectory is visible from inside the containers as `/AndroidStudio`.
* `yourdir/androiddocker/androidprojects` - is for your projects. This subdirectory is visible from inside the containers as `/projects`.  
You need to avoid soft links to files outside of `yourdir/androiddocker/androidprojects` because it would make those files inaccessible from inside the containers.  
You may want to have a separate sub-subdirectory for each project.

### Design considrations
* The containers are meant to run only on the same machine on which the image was built. This is in contrast to the general Docker philosophy.
* The containers are meant to access Android Studio and your project files from mounted host system directories. This design allows you to upgrade Android Studio without having to freeze images, as well as letting you use your favorite text editor to edit your project files from outside of the containers. You also won't lose data if you have to rebuild containers.

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
If necessary, edit the file `yourdir/androiddocker/androiddocker/51-android.rules` and add rules covering your devices (`lsusb` can be used to find your devices' vendor ID and product ID).  
Ensure that you have the rules in `yourdir/androiddocker/androiddocker/51-android.rules` defined also in a file in your host system's `/etc/udev/rules.d`. You may accomplish this by `sudo cat yourdir/androiddocker/androiddocker/51-android.rules >> /etc/udev/rules.d/51-android.rules`.

### Actual installation
1. Clone or unzip this repository (tddpirate/androiddocker) into a directory in your computer. This directory is referred to as `yourdir`.
2. Download Android Studio for Linux from http://developer.android.com/sdk/index.html and save it in another directory (referred to as `asdownload` below).
3. `cd yourdir/androiddocker/androiddocker`
4. `./build_androidstudio_image.sh asdownload/android-studio-ide-*-linux.zip`
5. If this is not the first time you are installing, you will be asked if you want to rebuild the contents of `yourdir/androiddocker/androidstudio/home` which contains the Android Studio files. Usually you'll not want to rebuild the subdirectory's contents, so enter `no` and hit ENTER.
6. The script auto-detects your user's uid and gid in the host system, and also the gids of the special users `video` and `kvm`. By default, the user in the container (`developer`) is given your uid and gid, but you have the option of selecting different uid and/or gid for `developer` inside the container.  
Therefore, the next question is whether you want to use different uid/gid for the user in the container.  
Enter `no` and hit ENTER.
7. When asked for image name, accept the default (`tddpirate/androidstudio:1.4`) by hitting ENTER.
8. Your computer will need few minutes to build the image.
9. When image building is completed, you'll see the message `Successfully tagged tddpirate/androidstudio:1.4`.
10. You'll be prompted for a container name. Accept the default (`android-studio`) by hitting ENTER.
11. Few moments later, Android Studio will start. Configure it to your taste and start working.

### After installation
* When you exit the Android Studio, the corresponding container stops execution.
* You can restart the container using: `yourdir/androiddocker/androiddocker/start_androidstudio.sh`. You may want to define a short alias for this command.

### Building the Android Cordova container
If you want to build the Android Cordova container:

1. Exit the Android Studio, closing the android-studio container.
2. `cd yourdir/androiddocker/androiddocker` if you are not already at the correct directory.
3. `./build_androidcordova_image.sh`
4. A list of existing Android Studio images is shown (normally, there will be only one image) followed by request to confirm usage of the selected image. Hit ENTER.
5. You will be asked to select a name for the new image (Android Cordova). Accept the default by hitting ENTER.
6. The image build process will last for several seconds.
7. After it ends, you'll be prompted for a container name. Accept the default of `android-cordova` by hitting ENTER.
8. The container is started, providing you with a command line where you run the various `cordova` commands.
9. Create your Cordova projects in subdirectories of `/projects` (corresponding to `yourdir/androiddocker/androidprojects` outside the container).

If the container was stopped, you can restart it by means of `yourdir/androiddocker/androiddocker/start_androidcordova.sh`.

## Maintenance

### How to keep the Docker container running for upgrading Android Studio
Normally, the Android Studio container stops running when you exit Android Studio. This behavior is problematic when upgrading Android Studio and the upgrade process requires it to close.

Therefore, the Android Studio container supports the following procedure to keep the container running as necessary to finish Android Studio upgrade.

1. `docker exec -it android-studio /bin/bash`
2. Outside of the container: `touch yourdir/androiddocker/androidprojects/upgrade` (or alternatively `touch /projects/upgrade` inside the container).
3. Exit Android Studio.
4. Start the Android Studio upgrade process.
5. Once the upgrade process ends, execute the command `ps ax` and find the PID of the process running `tail -f /dev/null`
6. `kill $PID` to kill the above process. This will cause the container to exit.
7. Next time you restart the container, you'll run the new version of Android Studio.

## Project and Release Notes

### The project was tested in the following environments:
1. Debian Stretch with Docker version 17.05.0-ce, build 89658be, installed from https://apt.dockerproject.org/repo.

### The following need to be fixed in the future:
1. After exiting the android-cordova container, you need to manually stop it with `docker stop android-cordova`.
2. Installation instructions for systems running a Linux distribution not based upon Debian.
3. Installation instructions for systems without systemd.

### Version 0.4.1 updates
1. Documentation was revised.
2. A script file was modified to simplify instructions to run it.

### Version 0.4 updates
1. Support for running the Android Emulator in hardware accelerated speeds.
2. The dockerfile for building the Android Cordova development environment now follows the actual tag of the Android Studio image.

### Version 0.3 updates
1. The image is based upon Ubuntu 18.04 instead of Ubuntu 14.04.
2. Android Studio is now started from a script which optionally keeps the Docker container running after closing Android Studio when it is necessary to exit Android Studio for upgrading it.
3. The Cordova support is currently broken. I will fix it when I have the time and/or need for it.

## Acknowledgements
Thanks to [@opyate](https://github.com/opyate) for his work on testing the scripts and giving feedback.
Thanks to all those who gave stars (12 at the time of writing) to this repository in GitHub. You gave me the encouragement to polish the project description and installation instructions.
