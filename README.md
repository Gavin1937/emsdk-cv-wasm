# emsdk-cv-wasm

A Docker image build on top of [emscripten/emsdk](https://hub.docker.com/r/emscripten/emsdk) image.

This image also contains pre-build opencv (with contrib & enable nonfree) wasm binaries, the build process is following [this guild from opencv](https://docs.opencv.org/3.4/d4/da1/tutorial_js_setup.html).

The purpose of this project is to provide a "ready to use" Docker image for other projects.

[Checkout in docker hub](https://hub.docker.com/repository/docker/gavin1937/emsdk-cv-wasm/general)

# Building

build with command

```sh
docker build -t gavin1937/emsdk-cv-wasm:4.8.0 --build-arg="VERSION=4.8.0" .
```

* Note that, you need to supply the right version of opencv in both `tag` and `build-arg`
* file `opencv-version-idx.txt` contains all the opencv versions that we build

# Usage

* Environment Variables
  * `EMSCRIPTEN`: emscripten upstream directory
  * `OPENCV_VERSION`: opencv version
  * `OPENCV_SRC`: opencv source code directory
  * `OPENCV_BUILD_WASM`: opencv build_wasm directory

Use inside your Dockerfile

```dockerfile
FROM gavin1937/emsdk-cv-wasm:4.8.0

WORKDIR /src
COPY . .

# build your wasm
RUN ...
```
