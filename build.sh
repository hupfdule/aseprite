#!/bin/sh

echo "> Saving current build"
cp -rp build build.$(date -I)

echo "> Updating submodules"
git submodule update --init --recursive

echo "> Building Skia"
cd deps
cd depot_tools
git pull
export PATH="${PWD}/:${PATH}"
cd ..
cd skia
git pull
python tools/git-sync-deps
gn gen out/Release --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false                                       skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false                            skia_use_system_libwebp=false skia_use_system_zlib=false"
ninja -C out/Release skia
cd ..
cd ..

cd build
echo "> Generating ninja file"
cmake \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DLAF_OS_BACKEND=skia \
-DSKIA_DIR=../deps/skia \
-DSKIA_OUT_DIR=../deps/skia/out/Release \
-G Ninja \
..


echo "> Building with ninja"
ninja aseprite
