#!/usr/bin/env bash

VERSION=1.0

docker build -t keisuke6065/demo:ver${VERSION} .
docker run -itd -p 80:8080 --name demo${VERSION} keisuke6065/demo:ver${VERSION}
