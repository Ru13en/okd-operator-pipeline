#!/bin/bash

NAMESPACE="pipelines"
MAJOR=1
MINOR=24
source ../common.sh

# Image definitions
export IMG_OPERATOR="${REGISTRY}/operator:${OCP_DATE}"
export IMG_TRIGGERS_CONTROLLER="${REGISTRY}/triggers-controller:${OCP_DATE}"
export IMG_TRIGGERS_CORE_INTERCEPTORS="${REGISTRY}/triggers-core-interceptors:${OCP_DATE}"
export IMG_TRIGGERS_EVENTLISTENERSINK="${REGISTRY}/triggers-eventlistenersink:${OCP_DATE}"
export IMG_TRIGGERS_WEBHOOK="${REGISTRY}/triggers-webhook:${OCP_DATE}"
export IMG_PIPELINE_CONTROLLER="${REGISTRY}/controller:${OCP_DATE}"
export IMG_PIPELINE_ENTRYPOINT="${REGISTRY}/entrypoint:${OCP_DATE}"
export IMG_PIPELINE_EVENTS="${REGISTRY}/events:${OCP_DATE}"
export IMG_PIPELINE_NOP="${REGISTRY}/nop:${OCP_DATE}"
export IMG_PIPELINE_RESOLVERS="${REGISTRY}/resolvers:${OCP_DATE}"
export IMG_PIPELINE_SIDECARLOGRESULTS="${REGISTRY}/sidecarlogresults:${OCP_DATE}"
export IMG_PIPELINE_WEBHOOK="${REGISTRY}/webhook:${OCP_DATE}"
export IMG_PIPELINE_WORKINGDIRINIT="${REGISTRY}/workingdirinit:${OCP_DATE}"
export IMG_CHAINS_CONTROLLER="${REGISTRY}/chains-controller:${OCP_DATE}"
export IMG_RESULTS_API="${REGISTRY}/results-api:${OCP_DATE}"
export IMG_RESULTS_RETENTION_POLICY_AGENT="${REGISTRY}/results-retention-policy-agent:${OCP_DATE}"
export IMG_RESULTS_WATCHER="${REGISTRY}/results-watcher:${OCP_DATE}"
export IMG_CLI_TKN="${REGISTRY}/cli-tkn:${OCP_DATE}"
export IMG_HUB_DB_MIGRATION="${REGISTRY}/hub-db-migration:${OCP_DATE}"
export IMG_HUB_API="${REGISTRY}/hub-api:${OCP_DATE}"
export IMG_HUB_UI="${REGISTRY}/hub-ui:${OCP_DATE}"
export IMG_OPERATOR_PROXY="${REGISTRY}/operator-proxy:${OCP_DATE}"
export IMG_OPERATOR_WEBHOOK="${REGISTRY}/operator-webhook:${OCP_DATE}"
IMG_BUNDLE="${REGISTRY}/operator-bundle:${OCP_DATE}"

## Functions

init() {
    submodule_initialize operator release-v${MAJOR}.${MINOR}.x
    submodule_initialize tektoncd-pipeline release-v${MAJOR}.${MINOR}.x
    submodule_initialize tektoncd-triggers release-v${MAJOR}.${MINOR}.x
    submodule_initialize tektoncd-chains release-v${MAJOR}.${MINOR}.x
    submodule_initialize tektoncd-results release-v${MAJOR}.${MINOR}.x
    submodule_initialize tektoncd-cli release-v${MAJOR}.${MINOR}.x
    submodule_initialize tektoncd-hub main
    submodule_initialize manual-approval-gate release-v0.9.2
    submodule_initialize pipelines-as-code release-v0.50.2
    submodule_initialize tekton-caches main
    submodule_initialize opc main
}

deinit() {
    submodule_reset operator release-v${MAJOR}.${MINOR}.x
    submodule_reset tektoncd-pipeline release-v${MAJOR}.${MINOR}.x
    submodule_reset tektoncd-triggers release-v${MAJOR}.${MINOR}.x
    submodule_reset tektoncd-chains release-v${MAJOR}.${MINOR}.x
    submodule_reset tektoncd-results release-v${MAJOR}.${MINOR}.x
    submodule_reset tektoncd-cli release-v${MAJOR}.${MINOR}.x
    submodule_reset tektoncd-hub main
    submodule_reset manual-approval-gate release-v0.9.2
    submodule_reset pipelines-as-code release-v0.50.2
    submodule_reset tekton-caches main
    submodule_reset opc main
}

update() {
    submodule_update operator release-v${MAJOR}.${MINOR}.x https://github.com/openshift-pipelines/operator.git
    submodule_update tektoncd-pipeline release-v${MAJOR}.${MINOR}.x https://github.com/openshift-pipelines/tektoncd-pipeline.git
    submodule_update tektoncd-triggers release-v${MAJOR}.${MINOR}.x https://github.com/openshift-pipelines/tektoncd-triggers.git
    submodule_update tektoncd-chains release-v${MAJOR}.${MINOR}.x https://github.com/openshift-pipelines/tektoncd-chains.git
    submodule_update tektoncd-results release-v${MAJOR}.${MINOR}.x https://github.com/openshift-pipelines/tektoncd-results.git
    submodule_update tektoncd-cli release-v${MAJOR}.${MINOR}.x https://github.com/openshift-pipelines/tektoncd-cli.git
    submodule_update tektoncd-hub main https://github.com/openshift-pipelines/tektoncd-hub.git
    submodule_update manual-approval-gate release-v0.9.2 https://github.com/openshift-pipelines/manual-approval-gate.git
    submodule_update pipelines-as-code release-v0.50.2 https://github.com/openshift-pipelines/pipelines-as-code.git
    submodule_update tekton-caches main https://github.com/openshift-pipelines/tekton-caches.git
    submodule_update opc main https://github.com/openshift-pipelines/opc.git
}

build_containers() {
    podman build -t "${IMG_OPERATOR}" -f operator.Containerfile .
    podman build -t "${IMG_TRIGGERS_CONTROLLER}" -f triggers-controller.Containerfile .
    podman build -t "${IMG_TRIGGERS_CORE_INTERCEPTORS}" -f triggers-core-interceptors.Containerfile .
    podman build -t "${IMG_TRIGGERS_EVENTLISTENERSINK}" -f triggers-eventlistenersink.Containerfile .
    podman build -t "${IMG_TRIGGERS_WEBHOOK}" -f triggers-webhook.Containerfile .
    podman build -t "${IMG_PIPELINE_CONTROLLER}" -f pipeline-controller.Containerfile .
    podman build -t "${IMG_PIPELINE_ENTRYPOINT}" -f pipeline-entrypoint.Containerfile .
    podman build -t "${IMG_PIPELINE_EVENTS}" -f pipeline-events.Containerfile .
    podman build -t "${IMG_PIPELINE_NOP}" -f pipeline-nop.Containerfile .
    podman build -t "${IMG_PIPELINE_RESOLVERS}" -f pipeline-resolvers.Containerfile .
    podman build -t "${IMG_PIPELINE_SIDECARLOGRESULTS}" -f pipeline-sidecarlogresults.Containerfile .
    podman build -t "${IMG_PIPELINE_WEBHOOK}" -f pipeline-webhook.Containerfile .
    podman build -t "${IMG_PIPELINE_WORKINGDIRINIT}" -f pipeline-workingdirinit.Containerfile .
    podman build -t "${IMG_CHAINS_CONTROLLER}" -f chains-controller.Containerfile .
    podman build -t "${IMG_RESULTS_API}" -f results-api.Containerfile .
    podman build -t "${IMG_RESULTS_RETENTION_POLICY_AGENT}" -f results-retention-policy-agent.Containerfile .
    podman build -t "${IMG_RESULTS_WATCHER}" -f results-watcher.Containerfile .
    podman build -t "${IMG_CLI_TKN}" -f cli-tkn.Containerfile .
    podman build -t "${IMG_HUB_DB_MIGRATION}" -f hub-db-migration.Containerfile .
    podman build -t "${IMG_HUB_API}" -f hub-api.Containerfile .
    podman build -t "${IMG_HUB_UI}" -f hub-ui.Containerfile .
    podman build -t "${IMG_OPERATOR_PROXY}" -f operator-proxy.Containerfile .
    podman build -t "${IMG_OPERATOR_WEBHOOK}" -f operator-webhook.Containerfile .
}

push_containers() {
    push_all_images  # Or manually push each image
}

update_bundle_image() {
    local csv_path="$1"
    local image_name="$2"
    local image_value="$3"
    local env_count
    local related_count

    export BUNDLE_IMAGE_NAME="${image_name}"
    export BUNDLE_IMAGE_VALUE="${image_value}"

    env_count=$(yq e '[.spec.install.spec.deployments[].spec.template.spec.containers[].env[] | select(.name == strenv(BUNDLE_IMAGE_NAME))] | length' "${csv_path}")
    related_count=$(yq e '[.spec.relatedImages[] | select(.name == strenv(BUNDLE_IMAGE_NAME))] | length' "${csv_path}")
    if [[ "${env_count}" -eq 0 || "${related_count}" -eq 0 ]]; then
        echo "Bundle CSV is missing environment or related-image entries for ${image_name}" >&2
        return 1
    fi

    yq e -i '
      (.spec.install.spec.deployments[].spec.template.spec.containers[].env[] | select(.name == strenv(BUNDLE_IMAGE_NAME)).value) = strenv(BUNDLE_IMAGE_VALUE) |
      (.spec.relatedImages[] | select(.name == strenv(BUNDLE_IMAGE_NAME)).image) = strenv(BUNDLE_IMAGE_VALUE)
    ' "${csv_path}"
}

update_bundle_related_image() {
    local csv_path="$1"
    local image_name="$2"
    local image_value="$3"
    local related_count

    export BUNDLE_IMAGE_NAME="${image_name}"
    export BUNDLE_IMAGE_VALUE="${image_value}"

    related_count=$(yq e '[.spec.relatedImages[] | select(.name == strenv(BUNDLE_IMAGE_NAME))] | length' "${csv_path}")
    if [[ "${related_count}" -eq 0 ]]; then
        echo "Bundle CSV is missing a related-image entry for ${image_name}" >&2
        return 1
    fi

    yq e -i '(.spec.relatedImages[] | select(.name == strenv(BUNDLE_IMAGE_NAME)).image) = strenv(BUNDLE_IMAGE_VALUE)' "${csv_path}"
}

build_bundle() {
    local csv_path="operator/.konflux/olm-catalog/bundle/manifests/openshift-pipelines-operator-rh.clusterserviceversion.yaml"
    local bundle_operator_deployment_count
    local bundle_webhook_deployment_count

    convert_all_images_to_digest

    update_bundle_image "${csv_path}" IMAGE_PIPELINES_TEKTON_PIPELINES_CONTROLLER "${IMG_PIPELINE_CONTROLLER}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_WEBHOOK "${IMG_PIPELINE_WEBHOOK}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_CONTROLLER "${IMG_PIPELINE_RESOLVERS}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_TEKTON_EVENTS_CONTROLLER "${IMG_PIPELINE_EVENTS}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_ARG__ENTRYPOINT_IMAGE "${IMG_PIPELINE_ENTRYPOINT}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_ARG__SHELL_IMAGE "${IMG_PIPELINE_ENTRYPOINT}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_ARG__WORKINGDIRINIT_IMAGE "${IMG_PIPELINE_WORKINGDIRINIT}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_ARG__NOP_IMAGE "${IMG_PIPELINE_NOP}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_ARG__SIDECARLOGRESULTS_IMAGE "${IMG_PIPELINE_SIDECARLOGRESULTS}"
    update_bundle_image "${csv_path}" IMAGE_TRIGGERS_TEKTON_TRIGGERS_CONTROLLER "${IMG_TRIGGERS_CONTROLLER}"
    update_bundle_image "${csv_path}" IMAGE_TRIGGERS_WEBHOOK "${IMG_TRIGGERS_WEBHOOK}"
    update_bundle_image "${csv_path}" IMAGE_TRIGGERS_TEKTON_TRIGGERS_CORE_INTERCEPTORS "${IMG_TRIGGERS_CORE_INTERCEPTORS}"
    update_bundle_image "${csv_path}" IMAGE_TRIGGERS_ARG__EL_IMAGE "${IMG_TRIGGERS_EVENTLISTENERSINK}"
    update_bundle_image "${csv_path}" IMAGE_CHAINS_TEKTON_CHAINS_CONTROLLER "${IMG_CHAINS_CONTROLLER}"
    update_bundle_image "${csv_path}" IMAGE_RESULTS_API "${IMG_RESULTS_API}"
    update_bundle_image "${csv_path}" IMAGE_RESULTS_WATCHER "${IMG_RESULTS_WATCHER}"
    update_bundle_image "${csv_path}" IMAGE_RESULTS_RETENTION_POLICY_AGENT "${IMG_RESULTS_RETENTION_POLICY_AGENT}"
    update_bundle_image "${csv_path}" IMAGE_JOB_PRUNER_TKN "${IMG_CLI_TKN}"
    update_bundle_image "${csv_path}" IMAGE_ADDONS_PARAM_TKN_IMAGE "${IMG_CLI_TKN}"
    update_bundle_image "${csv_path}" IMAGE_ADDONS_TKN "${IMG_CLI_TKN}"
    update_bundle_image "${csv_path}" IMAGE_PIPELINES_PROXY "${IMG_OPERATOR_PROXY}"
    update_bundle_related_image "${csv_path}" TEKTON_OPERATOR_WEBHOOK "${IMG_OPERATOR_WEBHOOK}"
    update_bundle_related_image "${csv_path}" OPENSHIFT_PIPELINES_OPERATOR_LIFECYCLE "${IMG_OPERATOR}"
    update_bundle_related_image "${csv_path}" OPENSHIFT_PIPELINES_OPERATOR_CLUSTER_OPERATIONS "${IMG_OPERATOR}"

    bundle_operator_deployment_count=$(yq e '[.spec.install.spec.deployments[] | select(.name == "openshift-pipelines-operator")] | length' "${csv_path}")
    bundle_webhook_deployment_count=$(yq e '[.spec.install.spec.deployments[] | select(.name == "tekton-operator-webhook")] | length' "${csv_path}")
    if [[ "${bundle_operator_deployment_count}" -eq 0 || "${bundle_webhook_deployment_count}" -eq 0 ]]; then
        echo "Bundle CSV is missing an operator or webhook deployment" >&2
        return 1
    fi

    export BUNDLE_OPERATOR_IMAGE="${IMG_OPERATOR}"
    export BUNDLE_OPERATOR_WEBHOOK_IMAGE="${IMG_OPERATOR_WEBHOOK}"
    yq e -i '
      .metadata.annotations.containerImage = strenv(BUNDLE_OPERATOR_IMAGE) |
      (.spec.install.spec.deployments[] | select(.name == "openshift-pipelines-operator").spec.template.spec.containers[].image) = strenv(BUNDLE_OPERATOR_IMAGE) |
      (.spec.install.spec.deployments[] | select(.name == "tekton-operator-webhook").spec.template.spec.containers[].image) = strenv(BUNDLE_OPERATOR_WEBHOOK_IMAGE)
    ' "${csv_path}"

    podman build -t "${IMG_BUNDLE}" -f operator/.konflux/dockerfiles/bundle.Dockerfile operator
    podman push "${IMG_BUNDLE}"
}

## Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi