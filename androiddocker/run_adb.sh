#!/bin/bash
# Execute adb inside the Android Studio container.
# Parameters:
#  $1 - container name (typically 'android-studio')
#  $2 and later - parameters for adb (typically, $2 is 'shell')

show_help() {
  echo "$0 -c container_name -v -h? [adb_command] [adb_command_arguments]"
  echo "   -c container name, default: android-studio"
  echo "   -v verbose"
  echo "   -h? this help message"
}

cd `dirname $0`

OPTIND=1
CONTAINER=android-studio
VERBOSE=0

while getopts "h?vc:" opt ; do
  case "$opt" in
  h|\?)
    show_help
    exit 0
    ;;
  v)
    VERBOSE=1
    ;;
  c)
    CONTAINER=$OPTARG
    ;;
  esac
done

shift $((OPTIND-1))
[ "$1" = "--" ] && shift

# Default ADB command
if [ -z $1 ] ; then
  CMD=shell
else
  CMD=$1
  shift 1
fi

[ $VERBOSE != "0" ] && echo "Inside container $CONTAINER, will run adb $CMD $@"

# Verify that the container exists and is running
RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

if [ $? -eq 1 ]; then
  echo "UNKNOWN - $CONTAINER does not exist."
  exit 1
fi

if [ "$RUNNING" == "false" ]; then
  echo "$CONTAINER is not running, starting it."
  ./start_androidstudio.sh $CONTAINER
else
  [ $VERBOSE != "0" ] && echo "$CONTAINER is running, executing inside it."
fi

docker exec -it $CONTAINER /AndroidStudio/home/Android/Sdk/platform-tools/adb $CMD $@
