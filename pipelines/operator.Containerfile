FROM registry.access.redhat.com/ubi9/go-toolset:1.26 AS builder

WORKDIR /go/src/github.com/tektoncd/operator
COPY operator/upstream .
COPY operator/.konflux/patches patches/
RUN set -e; for f in patches/*.patch; do echo ${f}; [[ -f ${f} ]] || continue; git apply ${f}; done
COPY operator/head HEAD
ENV GODEBUG="http2server=0"
RUN go build -tags disable_gcp,strictfipsruntime -ldflags="-X 'knative.dev/pkg/changeset.rev=$(cat HEAD)'" -mod=vendor -o /tmp/pipelines-operator \
    ./cmd/openshift/operator

FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

ENV OPERATOR=/usr/local/bin/pipelines-operator \
    KO_DATA_PATH=/kodata

COPY --from=builder /tmp/pipelines-operator ${OPERATOR}
COPY --from=builder /go/src/github.com/tektoncd/operator/cmd/openshift/operator/kodata/ ${KO_DATA_PATH}/
COPY operator/.konflux/olm-catalog/bundle/kodata /kodata
COPY operator/head ${KO_DATA_PATH}/HEAD

USER 65532:65532

ENTRYPOINT ["/usr/local/bin/pipelines-operator"]
