ARG GO_BUILDER=registry.access.redhat.com/ubi9/go-toolset:1.26@sha256:c2bd0309bf78ae317024fdfc5602a31704e0dba9572f6d4b0bd4b681033dc965
ARG UBI_RUNTIME=registry.access.redhat.com/ubi9/ubi-minimal:latest@sha256:4b79c93106c14ad1c234907f83441ff0e4f8d24e78426a36e159098e9f7e6fa5

FROM $GO_BUILDER AS builder

WORKDIR /go/src/github.com/tektoncd/results
COPY tektoncd-results/upstream .
COPY tektoncd-results/.konflux/patches patches/
RUN set -e; for f in patches/*.patch; do echo "${f}"; [[ -f "${f}" ]] || continue; git apply "${f}"; done
COPY tektoncd-results/head HEAD
ENV GODEBUG="http2server=0"
ENV GOEXPERIMENT=strictfipsruntime
RUN go build -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD)'" -mod=vendor -tags disable_gcp,strictfipsruntime -v -o /tmp/results-retention-policy-agent \
    ./cmd/retention-policy-agent

FROM $UBI_RUNTIME

ENV RETENTION_POLICY_AGENT=/usr/local/bin/results-retention-policy-agent \
    KO_APP=/ko-app \
    KO_DATA_PATH=/kodata

COPY --from=builder /tmp/results-retention-policy-agent ${RETENTION_POLICY_AGENT}
COPY --from=builder /tmp/results-retention-policy-agent ${KO_APP}/retention-policy-agent
COPY tektoncd-results/head ${KO_DATA_PATH}/HEAD


RUN groupadd -r -g 65532 nonroot && useradd --no-log-init -r -u 65532 -g nonroot nonroot
USER 65532

ENTRYPOINT ["/usr/local/bin/results-retention-policy-agent"]
