{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#daemonsetspec-v1-apps
*/ -}}
{{- define "workloads.DaemonSetSpec" -}}
  {{- if or ._CTX.minReadySeconds (kindIs "float64" ._CTX.minReadySeconds) .Values.minReadySeconds (kindIs "float64" .Values.minReadySeconds) }}
    {{- nindent 0 "" -}}minReadySeconds: {{ coalesce (toString ._CTX.minReadySeconds) (toString .Values.minReadySeconds) (toString 0) }}
  {{- end }}

  {{- if ._CTX.revisionHistoryLimit }}
    {{- nindent 0 "" -}}revisionHistoryLimit: {{ int (coalesce ._CTX.revisionHistoryLimit 10) }}
  {{- end }}

  {{- if ._CTX.updateStrategy }}
    {{- nindent 0 "" -}}updateStrategy:
    {{- include "definitions.DaemonSetUpdateStrategy" ._CTX.updateStrategy | indent 2 }}
  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- nindent 0 "" -}}template:
    {{- include "metadata.PodTemplateSpec" . | indent 2 }}
{{- end }}
