ARG NODEJS_BUILDER=registry.access.redhat.com/ubi9/nodejs-18:latest@sha256:ffbad8210aee178157e7621b5fa43fb85f1ac205246b0d2606bea778549da8c1
ARG RUNTIME=registry.access.redhat.com/ubi9/nginx-122:latest@sha256:e43c8f9d87591e16bbb7d301c9abd1cbf1515e36f3ef9e73b0e08ec0aca3dcb1

FROM $NODEJS_BUILDER AS builder

ARG REMOTE_SOURCE=/go/src/github.com/tektoncd/hub

WORKDIR $REMOTE_SOURCE

COPY tektoncd-hub/upstream .
USER root
RUN chmod -R g+w $REMOTE_SOURCE
COPY tektoncd-hub/.konflux/patches patches/
RUN set -e; for f in patches/*.patch; do echo "${f}"; [[ -f "${f}" ]] || continue; git apply "${f}"; done

WORKDIR $REMOTE_SOURCE/ui

RUN npm clean-install --legacy-peer-deps && npm run build

FROM $RUNTIME
ARG REMOTE_SOURCE=/go/src/github.com/tektoncd/hub

COPY --from=builder $REMOTE_SOURCE/ui/build /opt/app-root/src
COPY --from=builder --chown=1001 $REMOTE_SOURCE/ui/image/start.sh /usr/bin/
ENV BASE_PATH="/opt/app-root/src"

USER root
RUN chmod ugo+rw /opt/app-root/src/config.js && \
    chown nginx:nginx /opt/app-root/src/config.js && \
    chmod +x /usr/bin/start.sh
USER nginx

EXPOSE 8080

COPY --from=builder --chown=1001 $REMOTE_SOURCE/ui/image/location.locations "${NGINX_DEFAULT_CONF_PATH}"/location.conf

CMD /usr/bin/start.sh
