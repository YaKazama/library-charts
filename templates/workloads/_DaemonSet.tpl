{{- /*
  variables:
  - _kind
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#daemonset-v1-apps
*/ -}}
{{- define "workloads.DaemonSet" -}}
  {{- $_ := set . "_kind" "DaemonSet" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: DaemonSet
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.DaemonSetSpec" . | trim | nindent 2 }}
{{- end }}
