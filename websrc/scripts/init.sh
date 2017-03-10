#!/bin/bash

set -euo pipefail

image_name="contiv.github.io_build"

if [[ "$(docker images -q $image_name 2>/dev/null)" == "" ]]; then
    echo "Docker image does not exist, building it..."
    docker build -t $image_name  -f ../Dockerfile ..
else
    echo "Using existing Docker image..."
fi
