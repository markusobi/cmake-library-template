#!/usr/bin/env bash

set -e

rm -rf build
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=./install -DCMAKE_BUILD_TYPE=Debug
cmake --build . --config Debug --target install
