{{- define "workloads.ReplicationController" -}}
  {{- $_ := set . "_kind" "ReplicationController" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: ReplicationController
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.ReplicationControllerSpec" . | trim | nindent 2 }}
{{- end }}
