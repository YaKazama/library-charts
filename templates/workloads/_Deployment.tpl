{{- /*
  variables:
  - _kind
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#deployment-v1-apps
*/ -}}
{{- define "workloads.Deployment" -}}
  {{- $_ := set . "_kind" "Deployment" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: Deployment
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.DeploymentSpec" . | trim | nindent 2 }}
{{- end }}
