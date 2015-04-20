#!/bin/sh

#  opencore_amr.sh
#  
#
#  Created by cxjwin on 15-4-20.
#

# 打开调试回响模式,并配置环境
set -xe

DEVELOPER=`xcode-select -print-path`
DEST=${HOME}/Desktop/opencore_amr_ios

ARCHS="i386 x86_64 armv7 armv7s arm64"
LIBS="libopencore-amrnb.a libopencore-amrwb.a"  

# Note that AMR-NB is for narrow band http://en.wikipedia.org/wiki/Adaptive_Multi-Rate_audio_codec
# for AMR-WB encoding, refer to http://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/
# or AMR Codecs as Shared Libraries http://www.penguin.cz/~utx/amr

for arch in $ARCHS;
do
    mkdir -p $DEST/$arch
done

for arch in $ARCHS; 
do  
    make clean
    IOSMV="-miphoneos-version-min=5.0"
    case $arch in
    arm*)  
        echo "Building opencore-amr for iPhoneOS $arch ****************"
        if [ $arch == "arm64" ]
        then
            IOSMV="-miphoneos-version-min=7.0"
        fi
        PATH=`xcodebuild -version -sdk iphoneos PlatformPath`"/Developer/usr/bin:$PATH" \
        SDK=`xcodebuild -version -sdk iphoneos Path` \
        CXX="xcrun --sdk iphoneos clang++ -arch $arch $IOSMV --sysroot=$SDK -isystem $SDK/usr/include" \
        LDFLAGS="-Wl,-syslibroot,$SDK" \
        ./configure \
        --host=arm-apple-darwin \
        --prefix=$DEST/$arch \
        --disable-shared
        ;;
    *)
        echo "Building opencore-amr for iPhoneSimulator $arch *****************"
        PATH=`xcodebuild -version -sdk iphonesimulator PlatformPath`"/Developer/usr/bin:$PATH" \
        CXX="xcrun --sdk iphonesimulator clang++ -arch $arch $IOSMV" \
        ./configure \
        --prefix=$DEST/$arch \
        --disable-shared
        ;;
    esac
    make -j
    make install
done

make clean

echo "Merge into universal binary."

for i in $LIBS;
do
    input=""
    for arch in $ARCHS; do
        input="$input $DEST/$arch/lib/$i"
    done
    lipo -create $input -output $DEST/$i
done 