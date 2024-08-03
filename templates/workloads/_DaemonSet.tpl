{{- /*
  variables:
  - _kind
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#daemonset-v1-apps
*/ -}}
{{- define "workloads.DaemonSet" -}}
  {{- $_ := set . "_kind" "DaemonSet" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "workloads.DaemonSetSpec" . | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
