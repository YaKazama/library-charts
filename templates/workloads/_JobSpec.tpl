{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#jobspec-v1-batch
*/ -}}
{{- define "workloads.JobSpec" -}}
  {{- if and ._CTX.activeDeadlineSeconds (ge (int ._CTX.activeDeadlineSeconds) 0) }}
    {{- nindent 0 "" -}}activeDeadlineSeconds: {{ coalesce (int ._CTX.activeDeadlineSeconds) 0 }}
  {{- end }}

  {{- if and ._CTX.backoffLimit (ge (int ._CTX.backoffLimit) 0) }}
    {{- nindent 0 "" -}}backoffLimit: {{ coalesce (int ._CTX.backoffLimit) 6 }}
  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- nindent 0 "" -}}template:
    {{- include "metadata.PodTemplateSpec" . | indent 2 }}
{{- end }}
