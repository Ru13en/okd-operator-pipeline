ARG GO_BUILDER=registry.access.redhat.com/ubi9/go-toolset:1.26@sha256:c2bd0309bf78ae317024fdfc5602a31704e0dba9572f6d4b0bd4b681033dc965
ARG UBI_RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:4b79c93106c14ad1c234907f83441ff0e4f8d24e78426a36e159098e9f7e6fa5
ARG FIPS_BUILDER=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:bba2b4bbf0ed15cfe7dd72a1e17ae7d2015a141f306b304e1a2785c41400e39c

FROM $FIPS_BUILDER AS fips_builder

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/tektoncd/pipeline
COPY tektoncd-pipeline/upstream .
COPY tektoncd-pipeline/.konflux/patches patches/
RUN set -e; for f in patches/*.patch; do echo "${f}"; [[ -f "${f}" ]] || continue; git apply "${f}"; done
COPY tektoncd-pipeline/head HEAD
ENV GOEXPERIMENT=strictfipsruntime
ENV GODEBUG="http2server=0"
RUN go build -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD)'" -mod=vendor -tags disable_gcp,strictfipsruntime -v -o /tmp/nop \
    ./cmd/nop

FROM $UBI_RUNTIME

ENV NOP=/usr/local/bin/nop \
    KO_APP=/ko-app \
    KO_DATA_PATH=/kodata

COPY --from=builder /tmp/nop /ko-app/nop
COPY tektoncd-pipeline/head ${KO_DATA_PATH}/HEAD
COPY --from=fips_builder /usr/lib64/libcrypto.so.3 /usr/lib64/
COPY --from=fips_builder /usr/lib64/libcrypto.so.3* /usr/lib64/
COPY --from=fips_builder /usr/lib64/ossl-modules/fips.so /usr/lib64/ossl-modules/
COPY --from=fips_builder /etc/redhat-release /etc/


USER 65532

ENTRYPOINT ["/ko-app/nop"]
