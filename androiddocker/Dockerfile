FROM n3ziniuka5/ubuntu-oracle-jdk:14.04-JDK7u80
MAINTAINER Omer Zak "w1@zak.co.il"
ADD 51-android.rules /etc/udev/rules.d
RUN chmod a+r /etc/udev/rules.d/51-android.rules && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
            lib32ncurses5-dev lib32stdc++6 unzip lib32z1 \
   libglib2.0-0 \
   libkrb5support0 \
   libk5crypto3 \
   libkeyutils1 \
   libkrb5-3 \
   libgssapi-krb5-2 \
   libxau6 \
   libxdmcp6 \
   libxcb1 \
   libx11-data \
   libx11-6 \
   libxext6 \
   libxml2 \
   libasound2-data \
   libasound2 \
   libasyncns0 \
   libatk1.0-data \
   libatk1.0-0 \
   libgtk2.0-common \
   fonts-dejavu-core \
   fontconfig-config \
   libfreetype6 \
   libfontconfig1 \
   libpixman-1-0 \
   libxcb-render0 \
   libxcb-shm0 \
   libxrender1 \
   libcairo2 \
   libavahi-common-data \
   libavahi-common3 \
   libavahi-client3 \
   libcups2 \
   libjpeg-turbo8 \
   libjpeg8 \
   libjasper1 \
   libjbig0 \
   libtiff5 \
   libgdk-pixbuf2.0-common \
   libgdk-pixbuf2.0-0 \
   libthai-data \
   libdatrie1 \
   libthai0 \
   fontconfig \
   libpango-1.0-0 \
   libgraphite2-3 \
   libharfbuzz0b \
   libpangoft2-1.0-0 \
   libpangocairo-1.0-0 \
   libxcomposite1 \
   libxfixes3 \
   libxcursor1 \
   libxdamage1 \
   libxi6 \
   libxinerama1 \
   libxrandr2 \
   shared-mime-info \
   libgtk2.0-0 \
   openssl \
   ca-certificates \
   libnspr4 \
   libnss3-nssdb \
   libnss3 \
   ca-certificates-java \
   tzdata-java \
   java-common \
   liblcms2-2 \
   libpcsclite1 \
   libogg0 \
   libflac8 \
   libvorbis0a \
   libvorbisenc2 \
   libsndfile1 \
   libwrap0 \
   libpulse0 \
   libsctp1 \
   libgif4 \
   x11-common \
   libxtst6 \
   libglapi-mesa \
   libx11-xcb1 \
   libxcb-dri2-0 \
   libxcb-dri3-0 \
   libxcb-glx0 \
   libxcb-present0 \
   libxcb-sync1 \
   libxshmfence1 \
   libxxf86vm1 \
   libgl1-mesa-glx \
   libatk-wrapper-java \
   libatk-wrapper-java-jni

ADD .docker.uids_gids /tmp
RUN . /tmp/.docker.uids_gids && addgroup --gid ${kvmgid} kvm && \
   ( test "x`egrep ^video /etc/group|cut -d':' -f3`" = "x${videogid}" ; RC=$? ; \
   if [ $RC -ne 0 ] ; then echo "Incompatible video gid, you will not be able to run emulator" ; exit 1 ; fi)

RUN apt-get install -y --no-install-recommends \
   qemu-kvm \
   libgl1-mesa-dri libgl1-mesa-dev \
   libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 \
   libelf1 libllvm3.4 libpciaccess0 libtxc-dxtn-s2tc0 && \
    dpkg --add-architecture i386 && apt-get update && \
    apt-get install -y --no-install-recommends libc6:i386 libncurses5:i386 libstdc++6:i386 && \
    echo do not do "rm -rf /var/lib/apt/lists/*" because we want to update once in a while

RUN . /tmp/.docker.uids_gids && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/AndroidStudio/home:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${gid}:" >> /etc/group && \
    adduser developer kvm && \
    adduser developer video && \
    chmod 0660 /etc/sudoers && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chmod 0440 /etc/sudoers

RUN sudo apt-get install -y --no-install-recommends \
      git

USER developer
ENV HOME=/AndroidStudio/home DISPLAY=:0 SHELL=/bin/bash
ENV ANDROID_HOME=$HOME/Android/Sdk
ENV PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

ENTRYPOINT $HOME/android-studio/bin/studio.sh