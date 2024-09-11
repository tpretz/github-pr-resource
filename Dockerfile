FROM golang:1.14 as builder
ADD . /go/src/github.com/tpretz/github-pr-resource
WORKDIR /go/src/github.com/tpretz/github-pr-resource
RUN sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d v3.33.0
RUN ./bin/task build

FROM alpine:3.11 as resource
COPY --from=builder /go/src/github.com/tpretz/github-pr-resource/build /opt/resource
RUN apk add --update --no-cache \
    git \
    git-lfs \
    openssh \
    && chmod +x /opt/resource/*
COPY scripts/askpass.sh /usr/local/bin/askpass.sh
ADD scripts/install_git_crypt.sh install_git_crypt.sh
RUN ./install_git_crypt.sh && rm ./install_git_crypt.sh

FROM resource
LABEL MAINTAINER=telia-oss
