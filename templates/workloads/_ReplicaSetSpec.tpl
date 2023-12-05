{{- define "workloads.ReplicaSetSpec" -}}
  {{- if or ._CTX.minReadySeconds (kindIs "float64" ._CTX.minReadySeconds) .Values.minReadySeconds (kindIs "float64" .Values.minReadySeconds) }}
    {{- nindent 0 "" -}}minReadySeconds: {{ coalesce (toString ._CTX.minReadySeconds) (toString .Values.minReadySeconds) (toString 0) }}
  {{- end }}

  {{- if or ._CTX.replicas (kindIs "float64" ._CTX.replicas) .Values.replicas (kindIs "float64" .Values.replicas) }}
    {{- nindent 0 "" -}}replicas: {{ coalesce (toString ._CTX.replicas) (toString .Values.replicas) (toString 1) }}
  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- nindent 0 "" -}}template:
    {{- include "metadata.PodTemplateSpec" . | indent 2 }}
{{- end }}
