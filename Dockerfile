FROM emscripten/emsdk:3.1.55

# setup environments
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Los_Angeles
RUN \
    apt-get update -y && apt-get upgrade -y && \
    apt-get install -y \
    tzdata gcc g++ gdb cmake make python3 wget tar \
    ffmpeg libavcodec-dev libavdevice-dev libavfilter-dev \
    libavformat-dev libavutil-dev libpostproc-dev \
    libswresample-dev libswscale-dev libeigen3-dev libblas-dev liblapack-dev

COPY . /setup_tmp

# build opencv into wasm
ARG VERSION
ENV EMSCRIPTEN="/emsdk/upstream/emscripten" \
    OPENCV_VERSION="${VERSION}" \
    OPENCV_SRC="/opencv/opencv-${VERSION}" \
    OPENCV_BUILD="/opencv/opencv-${VERSION}/build" \
    OPENCV_BUILD_WASM="/opencv/opencv-${VERSION}/build_wasm"

# setup opencv source
RUN \
    # download opencv source code
    mkdir /opencv && cd /opencv && \
    wget -O "opencv-${VERSION}.tar.gz" https://github.com/opencv/opencv/archive/refs/tags/${VERSION}.tar.gz && \
    tar -xzvf "opencv-${VERSION}.tar.gz" && rm "opencv-${VERSION}.tar.gz" && \
    wget -O "opencv_contrib-${VERSION}.tar.gz" https://github.com/opencv/opencv_contrib/archive/refs/tags/${VERSION}.tar.gz && \
    tar -xzvf "opencv_contrib-${VERSION}.tar.gz" && rm "opencv_contrib-${VERSION}.tar.gz"

# build opencv
RUN cd "/opencv/opencv-${VERSION}" && mkdir build && \
    cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_PERF_TESTS:BOOL=OFF \
    -DBUILD_TESTS:BOOL=OFF -DBUILD_DOCS:BOOL=ON -DOPENCV_ENABLE_NONFREE=ON -DPARALLEL_ENABLE_PLUGINS=ON \
    -DOPENCV_EXTRA_MODULES_PATH=/opencv/opencv_contrib-${VERSION}/modules/ && \
    cmake --build build && cmake --install build

# build opencv js/wasm
RUN cd "/opencv/opencv-${VERSION}" && mkdir build_wasm && \
    python3 /setup_tmp/fix_emscripten_linker_flags.py "/opencv/opencv-${VERSION}/modules/js/CMakeLists.txt" && \
    python3 ./platforms/js/build_js.py build_wasm \
    --build_wasm --threads --enable_exception \
    --build_flags="-s WASM_MEM_MAX=2GB" \
    --cmake_option="-DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DBUILD_DOCS:BOOL=ON -DOPENCV_ENABLE_NONFREE=ON -DOPENCV_EXTRA_MODULES_PATH=/opencv/opencv_contrib-${VERSION}/modules/ -s WASM_MEM_MAX=2GB"

RUN rm -rf /setup_tmp

ENTRYPOINT ["bash"]
