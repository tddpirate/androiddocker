#!/bin/bash
########################################################################
# Sometimes you have to exit Android Studio to complete its upgrade.
# In such a case, you want the container to keep running and perform
# 'docker exec' to run a shell inside it.
#
# To accomplish this, touch the file 'upgrade' in your
# $CONTAINER_PROJECTS directory.
########################################################################
echo To keep container running after closing Android Studio for
echo upgrading it, perform: 'touch androidprojects/upgrade'
echo before closing Android Studio.
ANDROID_EMULATOR_USE_SYSTEM_LIBS=1 /AndroidStudio/home/android-studio/bin/studio.sh
if [ -e projects/upgrade ] ; then
  # The user wishes to upgrade Android Studio outside of it.
  rm projects/upgrade
  tail -f /dev/null
fi
# End of run_studio.sh
