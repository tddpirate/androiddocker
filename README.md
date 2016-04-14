# androiddocker
Android Studio in Docker container

Last time the repository was tested was in Debian Jessie with Docker version 1.11.0, build 4dc5990, installed from https://apt.dockerproject.org/repo.

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
* When you exit the Android Studio, the container stops execution.
* You can restart the container with `androiddocker/start_androidstudio.sh`

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
The script for building the tddpirate/androidcordova image currently expects the tddpirate/androidstudio image to have the tag 1.3. It will be fixed in the future if there is enough demand for the fix.

## Acknowledgements
Thanks to [@opyate](https://github.com/opyate) for his work on testing the scripts and giving feedback.