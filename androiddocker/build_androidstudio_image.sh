#!/bin/bash
cd `dirname $0`
# Validate 1st argument - should be a zip file consisting of Android Studio files.
if [ -z $1 ] ; then
  echo "Missing android-studio-ide-*-linux.zip argument"
  exit 1
fi
if [[ "`basename $1`" != android-studio-ide-*-linux.zip ]] ; then
  echo "The file $1 does not seem to be an Android Studio installation zip"
  exit 1
fi
if [ ! -e $1 ] ; then
  echo "The file $1 does not exist"
  exit 1
fi

# Validate the build context and directory tree
if [ ! -e Dockerfile ] ; then
  echo Dockerfile was not found
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

# Prepare the home directory for the container
if [ -e $CONTAINER_HOMEDIR/home ] ; then
  echo "To rebuild the contents of $CONTAINER_HOMEDIR/home? [YES/no]"
  read YESNO
  if [ "x$YESNO" == "xYES" ] ; then
    echo "Need to delete all contents of $CONTAINER_HOMEDIR/home"
    echo "Enter yes in capital letters to confirm:"
    read YESNO
    if [ "x$YESNO" != "xYES" ] ; then
      echo "Cancelled"
      exit 1
    fi
    rm -rf $CONTAINER_HOMEDIR/home
  fi
fi
if [ ! -e $CONTAINER_HOMEDIR/home ] ; then
  echo "Will build the contents of $CONTAINER_HOMEDIR/home"
  mkdir -p $CONTAINER_HOMEDIR/home
  unzip -d $CONTAINER_HOMEDIR/home $1
fi

XAUTH=$CONTAINER_HOMEDIR/home/.docker.xauth
echo "Building $XAUTH"
touch $XAUTH
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

# Select uid/gid of developer, kvm and video
DEV=`whoami`
DEV_UID=`egrep ^$DEV /etc/passwd|cut -d':' -f3`
DEV_GID=`egrep ^$DEV /etc/passwd|cut -d':' -f4`
KVM_GID=`egrep ^kvm /etc/group|cut -d':' -f3`
VIDEO_GID=`egrep ^video /etc/group|cut -d':' -f3`
if [ "x$KVM_GID" == "x" ] ; then
  echo "You do not have kvm group in your system, install qemu-kvm or equivalent"
  echo "Cancelled"
  exit 1
fi
if [ "x$VIDEO_GID" == "x" ] ; then
  echo "You do not have video group in your system, you will not be able to run emulator in Android Studio"
  echo "Cancelled"
  exit 1
fi

echo "In your host system, the gids of the video,kvm groups are respectively $VIDEO_GID,$KVM_GID"
echo "Your username is `whoami` with uid=$DEV_UID and gid=$DEV_GID"
echo "Do you want to change uid,gid? [YES/no]"
read YESNO
if [ "x$YESNO" == "xYES" ] ; then
  echo "Enter desired developer uid: "
  read DEV_UID
  echo "Enter desired developer gid: "
  read DEV_GID
fi
UIDS_GIDS_SCRIPT=./.docker.uids_gids
echo "export uid=$DEV_UID gid=$DEV_GID videogid=$VIDEO_GID kvmgid=$KVM_GID" > $UIDS_GIDS_SCRIPT

# Actually build the image
echo "Enter a name for the image:"
read -ei "tddpirate/androidstudio" IMAGE_NAME
docker build -t $IMAGE_NAME .

echo "Running the image, select a name for the container:"
read -ei "android-studio" CONTAINER_NAME
docker run -ti \
           -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
           -v $CONTAINER_HOMEDIR:/AndroidStudio \
           -v $CONTAINER_PROJECTS:/projects \
           --privileged -v /dev/bus/usb:/dev/bus/usb \
           -e XAUTHORITY=/AndroidStudio/home/.docker.xauth \
           --name=$CONTAINER_NAME \
           $IMAGE_NAME

echo "To continue to use the container, restart it."
