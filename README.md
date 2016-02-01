# androiddocker
Android Studio in Docker container

The repository was tested in Debian Jessie with Docker version 1.9.1, build a34a1d5 installed from https://apt.dockerproject.org/repo.

1. Clone or unzip the repository into your computer.
2. Download Android Studio for Linux from http://developer.android.com/sdk/index.html and save it somewhere.
3. cd androiddocker
4. ./build_androidstudio_image.sh yourzipfilesdirectory/android-studio-ide-*-linux.zip

When the image build completes, a container is started from it and it starts the Android Studio environment.
When you exit the Android Studio, the container stops execution.
You can restart the container with androiddocker/start_androidstudio.sh

If the Android Studio does not work properly, check the gid of the kvm group on your PC. The Dockerfile assumes that it is 142.
Check also the gid of the video group on your PC and inside the container. The Dockerfile assumes that they are the same.
