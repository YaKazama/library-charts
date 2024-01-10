{{- define "workloads.StatefulSet" -}}
  {{- $_ := set . "_kind" "StatefulSet" }}

  {{- nindent 0 "" -}}apiVersion: apps/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "workloads.StatefulSetSpec" . | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}
