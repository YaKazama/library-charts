{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#deploymentspec-v1-apps
*/ -}}
{{- define "workloads.DeploymentSpec" -}}
  {{- if or ._CTX.minReadySeconds (kindIs "float64" ._CTX.minReadySeconds) .Values.minReadySeconds (kindIs "float64" .Values.minReadySeconds) }}
    {{- nindent 0 "" -}}minReadySeconds: {{ coalesce (toString ._CTX.minReadySeconds) (toString .Values.minReadySeconds) (toString 0) }}
  {{- end }}

  {{- if and ._CTX.paused (kindIs "bool" ._CTX.paused) }}
    {{- nindent 0 "" -}}paused: true
  {{- end }}

  {{- if ._CTX.progressDeadlineSeconds }}
    {{- nindent 0 "" -}}progressDeadlineSeconds: {{ int (coalesce ._CTX.progressDeadlineSeconds 600) }}
  {{- end }}

  {{- if or ._CTX.replicas (kindIs "float64" ._CTX.replicas) .Values.replicas (kindIs "float64" .Values.replicas) }}
    {{- nindent 0 "" -}}replicas: {{ coalesce (toString ._CTX.replicas) (toString .Values.replicas) (toString 1) }}
  {{- end }}

  {{- if ._CTX.revisionHistoryLimit }}
    {{- nindent 0 "" -}}revisionHistoryLimit: {{ int (coalesce ._CTX.revisionHistoryLimit 10) }}
  {{- end }}

  {{- if ._CTX.strategy }}
    {{- nindent 0 "" -}}strategy:
    {{- include "workloads.DeploymentStrategy" ._CTX.strategy | indent 2 }}
  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- nindent 0 "" -}}template:
    {{- include "metadata.PodTemplateSpec" . | indent 2 }}
{{- end }}
