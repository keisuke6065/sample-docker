#!/usr/bin/env bash

VERSION=1.0

docker build -t keisuke6065/demo:ver${VERSION} .
docker push keisuke6065/demo:ver${VERSION}