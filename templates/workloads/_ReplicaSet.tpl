{{- define "workloads.ReplicaSet" -}}
  {{- $_ := set . "_kind" "ReplicaSet" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: ReplicaSet
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "workloads.ReplicaSetSpec" . | trim }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- $__spec | nindent 2 }}
  {{- end }}
{{- end }}
