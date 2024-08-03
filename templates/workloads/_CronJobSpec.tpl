{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#cronjobspec-v1-batch
*/ -}}
{{- define "workloads.CronJobSpec" -}}
  {{- $__policyAllowed := list "Allow" "Forbid" "Replace" }}
  {{- $__concurrencyPolicy := include "base.toa" (coalesce .Context.concurrencyPolicy .Values.concurrencyPolicy) }}
  {{- if mustHas $__concurrencyPolicy $__policyAllowed }}
    {{- nindent 0 "" -}}concurrencyPolicy: {{ coalesce $__concurrencyPolicy "Allow" }}
  {{- end }}

  {{- $__failedJobsHistoryLimit := include "base.int" (coalesce .Context.failedJobsHistoryLimit .Values.failedJobsHistoryLimit) }}
  {{- if int $__failedJobsHistoryLimit }}
    {{- nindent 0 "" -}}failedJobsHistoryLimit: {{ coalesce $__failedJobsHistoryLimit 1 }}
  {{- end }}

  {{- $__jobTemplate := include "definitions.JobTemplateSpec" . | fromYaml }}
  {{- if $__jobTemplate }}
    {{- nindent 0 "" -}}jobTemplate:
      {{- toYaml $__jobTemplate | nindent 2 }}
  {{- end }}

  {{- /*
    正则参考
    - minute: (\*|[0-5]?\d(\-[0-5]?\d)?)(\/[0-5]?\d)?(\,[0-5]?\d(\-[0-5]?\d)?(\/[0-5]?\d)?)*
    - hour: (\*|([0-1]?\d|2[0-3])(\-([0-1]?\d|2[0-3]))?)(\/([0-1]?\d|2[0-3]))?(\,([0-1]?\d|2[0-3])(\-([0-1]?\d|2[0-3]))?(\/([0-1]?\d|2[0-3]))?)*
    - day of month: (\*|([0-2]?\d|3[01])(\-([0-2]?\d|3[01]))?)(\/([0-2]?\d|3[01]))?(\,([0-2]?\d|3[01])(\-([0-2]?\d|3[01]))?(\/([0-2]?\d|3[01]))?)*
    - month: (\*|(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec)(\-(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?)(\/(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?(\,(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec)(\-(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?(\/(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?)*
    - day of week: (\*|(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat)(\-(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?)(\/(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?(\,(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat)(\-(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?(\/(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?)*
  */ -}}
  {{- $__regexCron := "^((\\*|[0-5]?\\d(\\-[0-5]?\\d)?)(\\/[0-5]?\\d)?(\\,[0-5]?\\d(\\-[0-5]?\\d)?(\\/[0-5]?\\d)?)*)\\s+((\\*|([0-1]?\\d|2[0-3])(\\-([0-1]?\\d|2[0-3]))?)(\\/([0-1]?\\d|2[0-3]))?(\\,([0-1]?\\d|2[0-3])(\\-([0-1]?\\d|2[0-3]))?(\\/([0-1]?\\d|2[0-3]))?)*)\\s+((\\*|([0-2]?\\d|3[01])(\\-([0-2]?\\d|3[01]))?)(\\/([0-2]?\\d|3[01]))?(\\,([0-2]?\\d|3[01])(\\-([0-2]?\\d|3[01]))?(\\/([0-2]?\\d|3[01]))?)*)\\s+((\\*|(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec)(\\-(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?)(\\/(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?(\\,(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec)(\\-(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?(\\/(0?[1-9]|1[0-2]|JAN|jan|FEB|feb|MAR|mar|APR|apr|MAY|may|JUN|jun|JUL|jul|AUG|aug|SEP|sep|OCT|oct|NOV|nov|DEC|dec))?)*)\\s+((\\*|(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat)(\\-(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?)(\\/(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?(\\,(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat)(\\-(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?(\\/(0?[0-7]|SUN|sun|MON|mon|TUE|tue|WED|wed|THU|thu|FRI|fri|SAT|sat))?)*)$" }}
  {{- $__schedule := include "base.string" (coalesce .Context.schedule .Values.schedule) }}
  {{- $__schedule = include "base.fmt" (dict "s" $__schedule "r" $__regexCron) }}
  {{- if $__schedule }}
    {{- nindent 0 "" -}}schedule: {{ coalesce $__schedule "* * * * *" | quote }}
  {{- end }}

  {{- $__startingDeadlineSeconds := include "base.toa" (coalesce .Context.startingDeadlineSeconds .Values.startingDeadlineSeconds) }}
  {{- if int $__startingDeadlineSeconds }}
    {{- nindent 0 "" -}}startingDeadlineSeconds: {{ coalesce $__startingDeadlineSeconds 1 }}
  {{- end }}

  {{- $__successfulJobsHistoryLimit := include "base.toa" (coalesce .Context.successfulJobsHistoryLimit .Values.successfulJobsHistoryLimit) }}
  {{- if int $__successfulJobsHistoryLimit }}
    {{- nindent 0 "" -}}successfulJobsHistoryLimit: {{ coalesce $__successfulJobsHistoryLimit 3 }}
  {{- end }}

  {{- $__suspend := include "base.bool" (coalesce .Context.cronJobSuspend .Values.cronJobSuspend .Context.suspend .Values.suspend) }}
  {{- if $__suspend }}
    {{- nindent 0 "" -}}suspend: {{ coalesce $__suspend "false" }}
  {{- end }}

  {{- /*
    reference:
    - https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#time-zones
    - https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  */ -}}
  {{- $__tz := include "base.string" (coalesce .Context.timeZone .Values.timeZone) }}
  {{- if $__tz }}
    {{- nindent 0 "" -}}timeZone: {{ coalesce $__tz "UTC" }}
  {{- end }}
{{- end }}
