{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#cronjobspec-v1-batch
*/ -}}
{{- define "workloads.CronJobSpec" -}}
  {{- $__policyList := list "Allow" "Forbid" "Replace" }}

  {{- if has ._CTX.concurrencyPolicy $__policyList }}
    {{- nindent 0 "" -}}concurrencyPolicy: {{ coalesce ._CTX.concurrencyPolicy "Allow" }}
  {{- end }}

  {{- if gt (int ._CTX.failedJobsHistoryLimit) 1 }}
    {{- nindent 0 "" -}}failedJobsHistoryLimit: {{ coalesce (int ._CTX.failedJobsHistoryLimit) 1 }}
  {{- end }}

  {{- if gt (int ._CTX.startingDeadlineSeconds) 1 }}
    {{- nindent 0 "" -}}startingDeadlineSeconds: {{ coalesce (int ._CTX.startingDeadlineSeconds) 10 }}
  {{- end }}

  {{- if gt (int ._CTX.successfulJobsHistoryLimit) 1 }}
    {{- nindent 0 "" -}}successfulJobsHistoryLimit: {{ coalesce (int ._CTX.successfulJobsHistoryLimit) 3 }}
  {{- end }}

  {{- if and ._CTX.suspend (kindIs "bool" ._CTX.suspend) }}
    {{- nindent 0 "" -}}suspend: true
  {{- end }}

  {{- /*
    reference: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#time-zones
  */ -}}
  {{- if ._CTX.timeZone }}
    {{- nindent 0 "" -}}timeZone: {{ coalesce ._CTX.timeZone "UTC" }}
  {{- end }}

  {{- nindent 0 "" -}}schedule: {{ coalesce ._CTX.schedule "* * * * *" | quote }}
  {{- nindent 0 "" -}}jobTemplate:
    {{- include "definitions.JobTemplateSpec" . | nindent 2 }}
{{- end }}
