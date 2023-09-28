#!/bin/sh

set -e

rm -f /output/mugen.apk

./gradlew build

jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore /game_certificate.key -storepass $KEYSTORE_PASSWORD /android-mugen/app/build/outputs/apk/release/app-release-unsigned.apk $KEYSTORE_NAME

/android-sdk/build-tools/29.0.3/zipalign 4 /android-mugen/app/build/outputs/apk/release/app-release-unsigned.apk /output/mugen.apk
