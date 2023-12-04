{{- define "workloads.Job" -}}
  {{- $_ := set . "_kind" "Job" }}

  {{- nindent 0 "" -}}apiVersion: batch/v1
  {{- nindent 0 "" -}}kind: Job
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.JobSpec" . | trim | nindent 2 }}
{{- end }}
