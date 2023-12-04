{{- define "workloads.Pod" -}}
  {{- $_ := set . "_kind" "Pod" }}

  {{- nindent 0 "" -}}apiVersion: core/v1
  {{- nindent 0 "" -}}kind: Pod
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.PodSpec" . | trim | nindent 2 }}
{{- end }}
