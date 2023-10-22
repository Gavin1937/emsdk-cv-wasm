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
    wget https://github.com/opencv/opencv/archive/refs/tags/${VERSION}.tar.gz && \
    tar -xzvf ${VERSION}.tar.gz && rm ${VERSION}.tar.gz && \
    cd opencv-${VERSION} && mkdir build_wasm && \
    python3 ./platforms/js/build_js.py build_wasm --build_wasm

ENTRYPOINT ["bash"]
