{{- define "workloads.ReplicaSet" -}}
  {{- $_ := set . "_kind" "ReplicaSet" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: ReplicaSet
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.ReplicaSetSpec" . | trim | nindent 2 }}
{{- end }}
