{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#deploymentspec-v1-apps
*/ -}}
{{- define "workloads.DeploymentSpec" -}}
  {{- if ._CTX.minReadySeconds }}
    {{- nindent 0 "" -}}minReadySeconds: {{ int (coalesce ._CTX.minReadySeconds 0) }}
  {{- end }}

  {{- if and ._CTX.paused (kindIs "bool" ._CTX.paused) }}
    {{- nindent 0 "" -}}paused: true
  {{- end }}

  {{- if ._CTX.progressDeadlineSeconds }}
    {{- nindent 0 "" -}}progressDeadlineSeconds: {{ int (coalesce ._CTX.progressDeadlineSeconds 600) }}
  {{- end }}

  {{- if ._CTX.replicas }}
    {{- nindent 0 "" -}}replicas: {{ int (coalesce ._CTX.replicas 1) }}
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
