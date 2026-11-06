ARG GO_BUILDER=registry.access.redhat.com/ubi9/go-toolset:1.26@sha256:c2bd0309bf78ae317024fdfc5602a31704e0dba9572f6d4b0bd4b681033dc965
ARG UBI_RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:4b79c93106c14ad1c234907f83441ff0e4f8d24e78426a36e159098e9f7e6fa5

FROM $UBI_RUNTIME AS dependency-builder

COPY tektoncd-pipeline/dependencies/tini dependencies/tini
WORKDIR /dependencies/tini
RUN microdnf update -y && microdnf install -y cmake gcc
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
RUN cmake . && make tini

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/tektoncd/pipeline
COPY tektoncd-pipeline/upstream .
COPY tektoncd-pipeline/.konflux/patches patches/
RUN set -e; for f in patches/*.patch; do echo "${f}"; [[ -f "${f}" ]] || continue; git apply "${f}"; done
COPY tektoncd-pipeline/head HEAD
ENV GOEXPERIMENT=strictfipsruntime
ENV GODEBUG="http2server=0"
RUN go build -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD)'" -mod=vendor -tags disable_gcp,strictfipsruntime -v -o /tmp/resolvers \
    ./cmd/resolvers

FROM $UBI_RUNTIME

ENV RESOLVERS=/usr/local/bin/resolvers \
    KO_APP=/ko-app \
    KO_DATA_PATH=/kodata

COPY --from=builder /tmp/resolvers /ko-app/resolvers
COPY tektoncd-pipeline/head ${KO_DATA_PATH}/HEAD
COPY --from=dependency-builder /dependencies/tini/tini /sbin/tini
RUN chmod 0755 /sbin/tini && chown root:root /sbin/tini


RUN microdnf update -y && microdnf install -y git && microdnf clean all
RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -r -u 65532 -g nonroot nonroot
USER 65532

ENTRYPOINT ["/sbin/tini", "--", "/ko-app/resolvers"]
