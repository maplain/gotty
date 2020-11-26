# Copyright (c) 2020 PalPark developers. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
# Build the manager binary
FROM golang:1.13 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY .git .git
COPY server/ server/
COPY webtty/ webtty/
COPY backend/ backend/
COPY pkg/ pkg/
COPY utils/ utils/
COPY Makefile Makefile

# Build
Run make gotty

# FROM gcr.io/distroless/static:nonroot
FROM ubuntu:18.04
WORKDIR /
COPY --from=builder /workspace/bin/gotty .

RUN apt-get update && apt-get remove docker docker-engine docker.io && \
 apt install -y docker.io && \
 docker --version

CMD ["sh", "-c", "/gotty -w docker run --rm -it -e ASCIICAST_URL=${ASCIICAST_URL} maplain/asciinema-player:0.1"]
