#!/bin/bash
cd `dirname $0`

# Process command line arguments
if [ -z $1 ] ; then
  CONTAINER=android-cordova
  echo "Container name not specified, defaulting to $CONTAINER"
else
  CONTAINER=$1
  echo "Will restart container $CONTAINER"
fi

# Validate directory tree
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

# First, verify that the container exists and is not running
RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

if [ $? -eq 1 ]; then
  echo "UNKNOWN - $CONTAINER does not exist."
  exit 1
fi

if [ "$RUNNING" != "false" ]; then
  echo "$CONTAINER is already running."
  exit 0
fi

# The container exists and is not running.
docker restart $CONTAINER
echo "The container $CONTAINER has been restarted"
docker exec -it $CONTAINER /bin/bash
# End of start_androidcordova.sh
