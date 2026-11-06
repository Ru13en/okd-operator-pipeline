ARG GO_BUILDER=registry.access.redhat.com/ubi9/go-toolset:1.26@sha256:c2bd0309bf78ae317024fdfc5602a31704e0dba9572f6d4b0bd4b681033dc965
ARG UBI_RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:4b79c93106c14ad1c234907f83441ff0e4f8d24e78426a36e159098e9f7e6fa5

FROM $GO_BUILDER AS builder

ARG REMOTE_SOURCE=/go/src/github.com/tektoncd/cli

WORKDIR $REMOTE_SOURCE

COPY tektoncd-cli/upstream .
COPY tektoncd-cli/.konflux/patches patches/
RUN set -e; for f in patches/*.patch; do echo "${f}"; [[ -f "${f}" ]] || continue; git apply "${f}"; done

COPY tektoncd-cli/head HEAD
ENV GODEBUG="http2server=0"
ENV GOEXPERIMENT=strictfipsruntime
RUN TKN_VERSION=$(cat VERSION); \
    go build -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD)' -X github.com/tektoncd/cli/pkg/cmd/version.clientVersion=${TKN_VERSION}" \
      -mod=vendor -tags disable_gcp,strictfipsruntime -v \
      -o /tmp/tkn ./cmd/tkn

COPY tektoncd-cli/sources/pac $REMOTE_SOURCE/pac
RUN cd $REMOTE_SOURCE/pac && \
    go build -tags strictfipsruntime -mod=vendor -o /tmp/tkn-pac ./cmd/tkn-pac

FROM $UBI_RUNTIME

COPY --from=builder /tmp/tkn /usr/bin
COPY --from=builder /tmp/tkn-pac /usr/bin

RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -r -u 65532 -g nonroot nonroot
USER 65532
