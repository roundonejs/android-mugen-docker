#!/bin/sh

set -e

rm -f /output/mugen.apk

# Change APK name
sed -i "s|com\.fishstix\.dosboxfree|$GAME_APK_NAME|g" /android-mugen/app/build.gradle
sed -i "s|FreeBox|$GAME_NAME|g" /android-mugen/app/src/main/res/values/strings.xml

# Convert icons
convert /icon.png -resize 72x72 /android-mugen/app/src/main/res/drawable-hdpi/icon.png
convert /icon.png -resize 36x36 /android-mugen/app/src/main/res/drawable-ldpi/icon.png
convert /icon.png -resize 48x48 /android-mugen/app/src/main/res/drawable-mdpi/icon.png
convert /icon.png -resize 96x96 /android-mugen/app/src/main/res/drawable-xhdpi/icon.png

./gradlew build

jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore /game_certificate.key -storepass $KEYSTORE_PASSWORD /android-mugen/app/build/outputs/apk/release/app-release-unsigned.apk $KEYSTORE_NAME

/android-sdk/build-tools/29.0.3/zipalign 4 /android-mugen/app/build/outputs/apk/release/app-release-unsigned.apk /output/mugen.apk
