FROM emscripten/emsdk

# setup environments
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Los_Angeles
RUN \
    apt update -y && \
    apt install -y tzdata gcc g++ gdb cmake make python3 wget tar

# build opencv into wasm
ARG VERSION
ENV EMSCRIPTEN="/emsdk/upstream/emscripten" \
    OPENCV_VERSION="${VERSION}" \
    OPENCV_SRC="/opencv/opencv-${VERSION}" \
    OPENCV_BUILD_WASM="/opencv/opencv-${VERSION}/build_wasm"
RUN \
    # download opencv source code
    mkdir /opencv && cd /opencv && \
    wget -O "opencv-${VERSION}.tar.gz" https://github.com/opencv/opencv/archive/refs/tags/${VERSION}.tar.gz && \
    tar -xzvf "opencv-${VERSION}.tar.gz" && rm "opencv-${VERSION}.tar.gz" && \
    wget -O "opencv_contrib-${VERSION}.tar.gz" https://github.com/opencv/opencv_contrib/archive/refs/tags/${VERSION}.tar.gz && \
    tar -xzvf "opencv_contrib-${VERSION}.tar.gz" && rm "opencv_contrib-${VERSION}.tar.gz" && \
    cd opencv-${VERSION} && mkdir build_wasm && \
    python3 ./platforms/js/build_js.py build_wasm --build_wasm --cmake_option="-DBUILD_PERF_TESTS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DWITH_CUDA:BOOL=OFF -DBUILD_DOCS:BOOL=ON -DOPENCV_ENABLE_NONFREE=ON -DOPENCV_EXTRA_MODULES_PATH=/opencv/opencv_contrib-${VERSION}/modules/"

ENTRYPOINT ["bash"]
