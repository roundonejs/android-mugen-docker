FROM archlinux:base-devel-20230921.0.180222

# Environment variables
ENV SDK_VERSION "9477386_latest"
ENV ANDROID_SDK_ROOT /android-sdk
ENV NDK_PATH /android-ndk-r9d
ENV NDK_HOST_AWK /usr/bin/gawk
ENV KEYSTORE_NAME keystore_name
ENV KEYSTORE_PASSWORD keystore_password
ENV GAME_APK_NAME ""
ENV GAME_NAME ""

# Install operational system dependencies
RUN pacman -Syu --noconfirm && pacman -S jdk11-openjdk jdk17-openjdk unzip git imagemagick --noconfirm

# Install Android Command-line tools
RUN curl https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}.zip --output cmdline-tools.zip
RUN unzip cmdline-tools.zip
RUN mkdir -p /android-sdk/cmdline-tools
RUN mv cmdline-tools /android-sdk/cmdline-tools/latest
RUN rm cmdline-tools.zip

# Install Android SDK
WORKDIR /android-sdk/cmdline-tools/latest/bin
RUN archlinux-java set java-17-openjdk
RUN echo "y" | ./sdkmanager "build-tools;29.0.3" "patcher;v4" "platform-tools" "platforms;android-29" "tools"

# Install Android NDK r9
WORKDIR /
RUN curl https://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2 --output android-ndk-r9d-linux-x86_64.tar.bz2
RUN tar -xvf android-ndk-r9d-linux-x86_64.tar.bz2
RUN rm android-ndk-r9d-linux-x86_64.tar.bz2

# Prepare for build
RUN archlinux-java set java-11-openjdk

# Reduce build time in futher builds
COPY android-mugen /android-mugen
WORKDIR /android-mugen
RUN mkdir ./app/src/main/assets/mugen/
RUN touch ./app/src/main/assets/mugen/mugen.exe
RUN touch ./app/src/main/assets/mugen/CWSDPMI.EXE
RUN ./gradlew build
RUN rm -R app/src/main/assets/mugen/
RUN rm app/build/outputs/apk/debug/app-debug.apk
RUN rm app/build/outputs/apk/release/app-release-unsigned.apk

# Remove icons
RUN rm /android-mugen/app/src/main/res/drawable-hdpi/icon.png
RUN rm /android-mugen/app/src/main/res/drawable-ldpi/icon.png
RUN rm /android-mugen/app/src/main/res/drawable-mdpi/icon.png
RUN rm /android-mugen/app/src/main/res/drawable-xhdpi/icon.png

# Volumes
RUN mkdir /android-mugen/app/src/main/assets/mugen/
RUN mkdir /output
VOLUME /android-mugen/app/src/main/assets/mugen/
VOLUME /game_certificate.key
VOLUME /icon.png
VOLUME /output

# Run build
WORKDIR /android-mugen
COPY run.sh /
CMD ["bash", "/run.sh"]
