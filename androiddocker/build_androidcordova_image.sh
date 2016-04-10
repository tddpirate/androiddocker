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
docker images --format "{{.Repository}}"tddpirate/androidstudio | grep -q tddpirate/androidstudio
STATUS=$?
if [ $STATUS != 0 ]; then
  echo "You need the tddpirate/androidstudio image and it does not exist"
  exit 1
fi

# Actually build the image
echo "Enter a name for the new image (do not forget to add a tag):"
read -ei "tddpirate/androidcordova" IMAGE_NAME
docker build -f $DOCKERFILE -t $IMAGE_NAME .

echo "Running the image, select a name for the container:"
read -ei "android-cordova" CONTAINER_NAME
docker run -ti \
           -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
           -v $CONTAINER_HOMEDIR:/AndroidStudio \
           -v $CONTAINER_PROJECTS:/projects \
           --privileged -v /dev/bus/usb:/dev/bus/usb \
           -e XAUTHORITY=/AndroidStudio/home/.docker.xauth \
           --name=$CONTAINER_NAME \
           $IMAGE_NAME

echo "To continue to use the container, restart it."
