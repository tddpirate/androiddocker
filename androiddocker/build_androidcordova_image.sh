#!/bin/bash
cd `dirname $0`
echo "Given that an androidstudio image exists,"
echo "build an image with Android Studio and Cordova."
DOCKERFILE=Dockerfile.cordova

# Validate the build context and directory tree
if [ ! -e $DOCKERFILE ] ; then
  echo $DOCKERFILE was not found
  exit 1
fi
CONTAINER_HOMEDIR=`dirname $PWD`/androidstudio
CONTAINER_PROJECTS=`dirname $PWD`/androidprojects
if [ ! -e $CONTAINER_HOMEDIR ] ; then
  echo "$CONTAINER_HOMEDIR does not exist"
  exit 1
fi
if [ ! -e $CONTAINER_PROJECTS ] ; then
  echo "$CONTAINER_PROJECTS does not exist"
  exit 1
fi
if [ ! -e $CONTAINER_HOMEDIR/home ] ; then
  echo "$CONTAINER_HOMEDIR does not have Android Studio installed in it, run first build_androidstudio_image.sh"
  exit 1
fi

# Ensure that we have a tddpirate/androidstudio image
docker images --format "{{.Repository}}" | grep -q tddpirate/androidstudio
STATUS=$?
if [ $STATUS != 0 ]; then
  echo "You need a tddpirate/androidstudio image and no such image exists."
  exit 1
fi

echo The following images exist:
docker images --format "{{.Repository}}:{{.Tag}}" | grep tddpirate/androidstudio
IMAGE_LF=`docker images --format "{{.Repository}}:{{.Tag}}" | grep tddpirate/androidstudio | tail -1`
IMAGE="${IMAGE_LF//[$'\n']}"
TAG="${IMAGE##*:}"

echo "Confirm the Android Studio image upon which you want to base the new image:"
read -ei "$IMAGE" ANDROID_STUDIO_IMAGE

# Actually build the image
echo "Enter a name for the new image:"
read -ei "tddpirate/androidcordova:${TAG}" NEW_IMAGE_NAME
echo "Select also a name for the container:"
read -ei "android-cordova" CONTAINER_NAME

echo DOCKERFILE=${DOCKERFILE}
echo NEW_IMAGE_NAME=${NEW_IMAGE_NAME}
echo ANDROID_STUDIO_IMAGE=${ANDROID_STUDIO_IMAGE}
echo "Starting to build the new image."

docker build -f $DOCKERFILE -t $NEW_IMAGE_NAME --build-arg ANDROID_STUDIO_IMAGE=${ANDROID_STUDIO_IMAGE} .

echo "Running the image ${NEW_IMAGE_NAME}, as container ${CONTAINER_NAME}"
docker run -ti \
           -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
           -v $CONTAINER_HOMEDIR:/AndroidStudio \
           -v $CONTAINER_PROJECTS:/projects \
           --privileged -v /dev/bus/usb:/dev/bus/usb \
           -e XAUTHORITY=/AndroidStudio/home/.docker.xauth \
           --name=$CONTAINER_NAME \
           $NEW_IMAGE_NAME

echo "To continue to use the container, restart it."
