#!/bin/bash

set -euo pipefail

docker run --rm \
       -p 4567:4567 \
       -u $(id -u):$(id -g) \
       -v "$(dirname $(pwd))":/sources \
       contiv.github.io_build \
       bash -l -c "middleman server"
