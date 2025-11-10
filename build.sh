#!/bin/bash

set -e
set -u

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo "Reconfiguring existing packages..."
[ $is_x86 -ne 1 ] && echo "Not using yasm or nasm on non-x86 platform..."

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo "#### FFmpeg static build ####"

#this is our working directory
cd $BUILD_DIR

[ $is_x86 -eq 1 ] && download \
  "yasm-1.3.0.tar.gz" \
  "" \
  "fc9e586751ff789b34b1f21d572d96af" \
  "http://www.tortall.net/projects/yasm/releases/"

[ $is_x86 -eq 1 ] && download \
  "nasm-2.15.05.tar.bz2" \
  "" \
  "b8985eddf3a6b08fc246c14f5889147c" \
  "https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/"

download \
  "OpenSSL_1_0_2o.tar.gz" \
  "" \
  "5b5c050f83feaa0c784070637fac3af4" \
  "https://github.com/openssl/openssl/archive/"

download \
  "v1.2.11.tar.gz" \
  "zlib-1.2.11.tar.gz" \
  "0095d2d2d1f3442ce1318336637b695f" \
  "https://github.com/madler/zlib/archive/"

download \
  "v1.5.3.tar.gz" \
  "" \
  "df8213a3669dd846ddaad0fa1e9f417b" \
  "https://github.com/Haivision/srt/archive/refs/tags/"

download \
  "x264-0480cb05fa188d37ae87e8f4fd8f1aea3711f7ee.tar.gz" \
  "" \
  "nil" \
  "https://code.videolan.org/videolan/x264/-/archive/0480cb05fa188d37ae87e8f4fd8f1aea3711f7ee/"

download \
  "x265_3.4.tar.gz" \
  "" \
  "e37b91c1c114f8815a3f46f039fe79b5" \
  "http://download.openpkg.org/components/cache/x265/"

download \
  "v0.1.6.tar.gz" \
  "fdk-aac.tar.gz" \
  "223d5f579d29fb0d019a775da4e0e061" \
  "https://github.com/mstorsjo/fdk-aac/archive"

# libass dependency
download \
  "harfbuzz-1.4.6.tar.bz2" \
  "" \
  "e246c08a3bac98e31e731b2a1bf97edf" \
  "https://www.freedesktop.org/software/harfbuzz/release/"

download \
  "fribidi-1.0.2.tar.bz2" \
  "" \
  "bd2eb2f3a01ba11a541153f505005a7b" \
  "https://github.com/fribidi/fribidi/releases/download/v1.0.2/"

download \
  "0.13.6.tar.gz" \
  "libass-0.13.6.tar.gz" \
  "nil" \
  "https://github.com/libass/libass/archive/"

download \
  "59a722d49e9f2bea65917dcdd17b94c710a02f0c.tar.gz" \
  "" \
  "37fce5d82b8eda298b199cf46035da9e" \
  "https://github.com/zlargon/lame/archive/"

download \
  "opus-1.1.2.tar.gz" \
  "" \
  "1f08a661bc72930187893a07f3741a91" \
  "https://github.com/xiph/opus/releases/download/v1.1.2"

download \
  "v1.6.1.tar.gz" \
  "vpx-1.6.1.tar.gz" \
  "b0925c8266e2859311860db5d76d1671" \
  "https://github.com/webmproject/libvpx/archive"

download \
  "rtmpdump-2.3.tgz" \
  "" \
  "eb961f31cd55f0acf5aad1a7b900ef59" \
  "https://rtmpdump.mplayerhq.hu/download/"

download \
  "70ff919c5cda05d420267bd7cd6f55658e9c3ca2.tar.gz" \
  "" \
  "9c72173b1c9135606c2ebe54e67620b7" \
  "https://github.com/rust-media/soxr/archive/"

download \
  "4bd81e3cdd778e2e0edc591f14bba158ec40cfa1.tar.gz" \
  "vid.stab-4bd81e3cdd778e2e0edc591f14bba158ec40cfa1.tar.gz" \
  "nil" \
  "https://github.com/georgmartius/vid.stab/archive/"

download \
  "release-2.7.4.tar.gz" \
  "zimg-release-2.7.4.tar.gz" \
  "1757dcc11590ef3b5a56c701fd286345" \
  "https://github.com/sekrit-twc/zimg/archive/"

# download \
#   "v2.1.2.tar.gz" \
#   "openjpeg-2.1.2.tar.gz" \
#   "40a7bfdcc66280b3c1402a0eb1a27624" \
#   "https://github.com/uclouvain/openjpeg/archive/"

download \
  "v0.6.1.tar.gz" \
  "libwebp-0.6.1.tar.gz" \
  "1c3099cd2656d0d80d3550ee29fc0f28" \
  "https://github.com/webmproject/libwebp/archive/"

download \
  "v1.3.6.tar.gz" \
  "vorbis-1.3.6.tar.gz" \
  "03e967efb961f65a313459c5d0f4cbfb" \
  "https://github.com/xiph/vorbis/archive/"

download \
  "v1.3.3.tar.gz" \
  "ogg-1.3.3.tar.gz" \
  "b8da1fe5ed84964834d40855ba7b93c2" \
  "https://github.com/xiph/ogg/archive/"

download \
  "Speex-1.2.0.tar.gz" \
  "Speex-1.2.0.tar.gz" \
  "4bec86331abef56129f9d1c994823f03" \
  "https://github.com/xiph/speex/archive/"

download \
  "n7.1.1.tar.gz" \
  "ffmpeg7.1.1.tar.gz" \
  "5f8157e206bc430cbed92fb62144f30b" \
  "https://github.com/FFmpeg/FFmpeg/archive"

download \
  "SDL2-2.0.22.tar.gz" \
  "SDL2-2.0.22.tar.gz" \
  "40aedb499cb2b6f106d909d9d97f869a" \
  "https://github.com/libsdl-org/SDL/releases/download/release-2.0.22"

[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

if [ $is_x86 -eq 1 ]; then
    echo "*** Building yasm ***"
    cd $BUILD_DIR/yasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

if [ $is_x86 -eq 1 ]; then
    echo "*** Building nasm ***"
    cd $BUILD_DIR/nasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR
    make -j $jval
    make install
fi

echo "*** Building OpenSSL ***"
cd $BUILD_DIR/openssl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  PATH="$BIN_DIR:$PATH" ./config --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building zlib ***"
cd $BUILD_DIR/zlib*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building x264 ***"
cd $BUILD_DIR/x264*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --disable-shared --disable-opencl --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building x265 ***"
cd $BUILD_DIR/x265*
cd build/linux
[ $rebuild -eq 1 ] && find . -mindepth 1 ! -name 'make-Makefiles.bash' -and ! -name 'multilib.sh' -exec rm -r {} +
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DENABLE_SHARED:BOOL=OFF -DSTATIC_LINK_CRT:BOOL=ON -DENABLE_CLI:BOOL=OFF ../../source
sed -i 's/-lgcc_s/-lgcc_eh/g' x265.pc
make -j $jval
make install

echo "*** Building fdk-aac ***"
cd $BUILD_DIR/fdk-aac*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
autoreconf -fiv
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building harfbuzz ***"
cd $BUILD_DIR/harfbuzz-*
rm config.guess config.sub
curl -fsSL "https://gitweb.git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -o config.guess
curl -fsSL "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -o config.sub
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static
make -j $jval
make install

echo "*** Building fribidi ***"
cd $BUILD_DIR/fribidi-*
rm config.guess config.sub
curl -fsSL "https://gitweb.git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -o config.guess
curl -fsSL "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -o config.sub
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs
make -j $jval
make install

echo "*** Building libass ***"
cd $BUILD_DIR/libass-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building mp3lame ***"
cd $BUILD_DIR/lame*
rm config.guess config.sub
curl -fsSL "https://gitweb.git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -o config.guess
curl -fsSL "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -o config.sub
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --enable-nasm --disable-shared $lame_build_target
make
make install

echo "*** Building opus ***"
cd $BUILD_DIR/opus*
rm config.guess config.sub
curl -fsSL "https://gitweb.git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -o config.guess
curl -fsSL "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -o config.sub
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared
make
make install

echo "*** Building libvpx ***"
cd $BUILD_DIR/libvpx*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-examples --disable-unit-tests --enable-pic
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building librtmp ***"
cd $BUILD_DIR/rtmpdump-*
cd librtmp
[ $rebuild -eq 1 ] && make distclean || true

# there's no configure, we have to edit Makefile directly
if [ "$platform" = "linux" ]; then
  sed -i "/INC=.*/d" ./Makefile # Remove INC if present from previous run.
  sed -i "s/prefix=.*/prefix=${TARGET_DIR_SED}\nINC=-I\$(prefix)\/include/" ./Makefile
  sed -i "s/SHARED=.*/SHARED=no/" ./Makefile
elif [ "$platform" = "darwin" ]; then
  sed -i "s/prefix=./prefix=${TARGET_DIR_SED}/" ./Makefile
fi
make install_base

echo "*** Building libsoxr ***"
cd $BUILD_DIR/soxr-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DWITH_OPENMP:bool=off -DBUILD_TESTS:bool=off
make -j $jval
make install

echo "*** Building libvidstab ***"
cd $BUILD_DIR/vid.stab-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  sed -i "s/vidstab \${SOURCES}/vidstab STATIC \${SOURCES}/" ./CMakeLists.txt
elif [ "$platform" = "darwin" ]; then
  sed -i "s/vidstab \${SOURCES}/vidstab STATIC \${SOURCES}/" ./CMakeLists.txt
fi
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR"
make -j $jval
make install

# echo "*** Building openjpeg ***"
# cd $BUILD_DIR/openjpeg-*
# [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
# PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off
# make -j $jval
# make install

echo "*** Building zimg ***"
cd $BUILD_DIR/zimg-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --enable-static  --prefix=$TARGET_DIR --disable-shared
sed -i 's/size_t/std::size_t/g' src/zimg/colorspace/matrix3.cpp
make -j $jval
make install

echo "*** Building libwebp ***"
cd $BUILD_DIR/libwebp*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libvorbis ***"
cd $BUILD_DIR/vorbis*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libogg ***"
cd $BUILD_DIR/ogg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libspeex ***"
cd $BUILD_DIR/speex*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building libsdl ***"
cd $BUILD_DIR/SDL*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared
make -j $jval
make install

echo "*** Building RIST ***"
cd $BUILD_DIR
rm -rf librist
git clone https://code.videolan.org/rist/librist.git
cd $BUILD_DIR/librist*
git checkout v0.2.10
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p build
cd build
meson --default-library=static .. --prefix=$TARGET_DIR --bindir="../bin/" --libdir="$TARGET_DIR/lib"
ninja
ninja install

echo "*** Building SRT ***"
cd $BUILD_DIR/srt*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
mkdir -p build
cd build
cmake -DENABLE_APPS=OFF -DCMAKE_INSTALL_PREFIX=$TARGET_DIR -DENABLE_C_DEPS=ON -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DOPENSSL_USE_STATIC_LIBS=ON ..
sed -i 's/-lgcc_s/-lgcc_eh/g' haisrt.pc
sed -i 's/-lgcc_s/-lgcc_eh/g' srt.pc
make
make install

# FFMpeg
echo "*** Building FFmpeg ***"
cd $BUILD_DIR/FFmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true

if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="$TARGET_DIR/lib/pkgconfig" ./configure \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-libs="-lpthread -lm -lz" \
    --extra-ldexeflags="-static" \
    --bindir="$BIN_DIR" \
    --enable-encoder=h264_vaapi,hevc_vaapi,av1_vaapi \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-static \
    --enable-avcodec \
    --enable-avutil \
    --enable-bsfs \
    --enable-swscale \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libtheora \
    --enable-libvidstab \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-librist \
    --enable-libsrt \
    --enable-nonfree \
    --enable-openssl \
    --enable-runtime-cpudetect \
    --enable-vaapi \
    --enable-version3
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="${TARGET_DIR}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Cellar/openssl/1.0.2o_1/lib/pkgconfig" ./configure \
    --cc=/usr/bin/clang \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-ldexeflags="-Bstatic" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-static \
    --enable-avcodec \
    --enable-avutil \
    --enable-bsfs \
    --enable-swscale \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl \
    --enable-librist \
    --enable-libsrt
fi

PATH="$BIN_DIR:$PATH" make -j $jval
make install

# Build cbs
# See https://github.com/AOSC-Dev/aosc-os-abbs/blob/stable/app-multimedia/ffmpeg/02-static-libs-sunshine/build
echo "*** Building cbs ***"
CBS_SOURCE=(
    "libavcodec/cbs.o"
    "libavcodec/cbs_h2645.o"
    "libavcodec/cbs_av1.o"
    "libavcodec/cbs_vp8.o"
    "libavcodec/cbs_vp9.o"
    "libavcodec/cbs_mpeg2.o"
    "libavcodec/cbs_jpeg.o"
    "libavcodec/cbs_sei.o"
    "libavcodec/h264_levels.o"
    "libavcodec/h2645_parse.o"
    "libavcodec/vp8data.o"
    "libavcodec/refstruct.o"
    "libavutil/intmath.o"
)

ar -crv "libcbs.a" "${CBS_SOURCE[@]}"

echo "*** Installing headers and static libs for cbs***"
install -Dvm644 libcbs.a -t "$TARGET_DIR"/lib/
install -Dvm644 libavcodec/cbs.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/cbs_h264.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/cbs_sei.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/cbs_h265.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/cbs_h2645.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/h2645_parse.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/get_bits.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/mathops.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/h264_levels.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavutil/attributes_internal.h -t "$TARGET_DIR"/include/libavutil/
install -Dvm644 libavutil/intmath.h -t "$TARGET_DIR"/include/libavutil/
install -Dvm644 config.h -t "$TARGET_DIR"/include/
# mathops incl. x86/arm/mips/ppc
install -Dvm644 libavcodec/x86/mathops.h -t "$TARGET_DIR"/include/libavcodec/x86/
install -Dvm644 libavcodec/arm/mathops.h -t "$TARGET_DIR"/include/libavcodec/arm/
install -Dvm644 libavcodec/mips/mathops.h -t "$TARGET_DIR"/include/libavcodec/mips/
install -Dvm644 libavcodec/ppc/mathops.h -t "$TARGET_DIR"/include/libavcodec/ppc/
# avutil's asm.h only x86
install -Dvm644 libavutil/x86/asm.h -t "$TARGET_DIR"/include/libavutil/x86/
install -Dvm644 libavcodec/vlc.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/sei.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/h264.h -t "$TARGET_DIR"/include/libavcodec/
install -Dvm644 libavcodec/hevc/hevc.h -t "${PKGDIR}"/usr/include/libavcodec/hevc/

# Clean
make distclean
hash -r
