{{- define "workloads.Pod" -}}
  {{- $_ := set . "_kind" "Pod" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: Pod
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__spec := include "workloads.PodSpec" . | trim }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- $__spec | nindent 2 }}
  {{- end }}
{{- end }}
