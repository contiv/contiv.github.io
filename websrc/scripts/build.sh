#!/bin/bash

set -euo pipefail

docker run --rm \
       -u $(id -u):$(id -g) \
       -v "$(dirname $(pwd))":/sources \
       contiv.github.io_build \
       bash -l -c "middleman build"

make deploy
