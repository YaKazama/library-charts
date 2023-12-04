{{- define "workloads.ReplicaSetSpec" -}}
  {{- if ._CTX.minReadySeconds }}
    {{- nindent 0 "" -}}minReadySeconds: {{ int (coalesce ._CTX.minReadySeconds 0) }}
  {{- end }}

  {{- if ._CTX.replicas }}
    {{- nindent 0 "" -}}replicas: {{ int (coalesce ._CTX.replicas 1) }}
  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- nindent 0 "" -}}template:
    {{- include "metadata.PodTemplateSpec" . | indent 2 }}
{{- end }}
