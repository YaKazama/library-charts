{{- /*
  variables:
  - _kind
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#cronjob-v1-batch
  - https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
*/ -}}
{{- define "workloads.CronJob" -}}
  {{- $_ := set . "_kind" "CronJob" }}

  {{- nindent 0 "" -}}apiVersion: batch/v1
  {{- nindent 0 "" -}}kind: CronJob
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}
  {{- nindent 0 "" -}}spec:
    {{- include "workloads.CronJobSpec" . | trim | nindent 2 }}
{{- end }}
