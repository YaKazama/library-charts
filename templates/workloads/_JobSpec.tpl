{{- /*
  只实现部分参数

  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#jobspec-v1-batch
*/ -}}
{{- define "workloads.JobSpec" -}}
  {{- $__activeDeadlineSeconds := include "base.int" (coalesce .Context.jobActiveDeadlineSeconds .Values.jobActiveDeadlineSeconds .Context.activeDeadlineSeconds .Values.activeDeadlineSeconds) }}
  {{- if $__activeDeadlineSeconds }}
    {{- nindent 0 "" -}}activeDeadlineSeconds: {{ $__activeDeadlineSeconds }}
  {{- end }}

  {{- $__backoffLimit := include "base.int" (coalesce .Context.backoffLimit .Values.backoffLimit) }}
  {{- if $__backoffLimit }}
    {{- nindent 0 "" -}}backoffLimit: {{ $__backoffLimit }}
  {{- end }}

  {{- $__suspend := include "base.bool" (coalesce .Context.jobSuspend .Values.jobSuspend .Context.suspend .Values.suspend) }}
  {{- if $__suspend }}
    {{- nindent 0 "" -}}suspend: {{ coalesce $__suspend "false" }}
  {{- end }}

  {{- $__ttlSecondsAfterFinished := include "base.int.zero" (pluck "ttlSecondsAfterFinished" .Context .Values) }}
  {{- if $__ttlSecondsAfterFinished }}
    {{- nindent 0 "" -}}ttlSecondsAfterFinished: {{ coalesce $__ttlSecondsAfterFinished 0 }}
  {{- end }}

  {{- $__clean := dict "matchExpressions" list "matchLabels" dict }}
  {{- $__selectorSrc := pluck "selector" .Context .Values }}
  {{- range ($__selectorSrc | mustUniq | mustCompact) }}
    {{- $__valMatchExpressions := list }}
    {{- $__valMatchLabels := dict }}

    {{- if kindIs "map" . }}
      {{- if kindIs "slice" .matchExpressions }}
        {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
      {{- end }}
      {{- if kindIs "map" .matchLabels }}
        {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- if kindIs "slice" .matchExpressions }}
            {{- $__valMatchExpressions = concat $__valMatchExpressions .matchExpressions }}
          {{- end }}
          {{- if kindIs "map" .matchLabels }}
            {{- $__valMatchLabels = mustMerge $__valMatchLabels .matchLabels }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $_ := set $__clean "matchExpressions" (concat $__clean.matchExpressions $__valMatchExpressions) }}
    {{- $_ := set $__clean "matchLabels" (mustMerge $__clean.matchLabels $__valMatchLabels) }}
  {{- end }}
  {{- $__selector := include "definitions.LabelSelector" $__clean | fromYaml }}
  {{- if $__selector }}
    {{- nindent 0 "" -}}selector:
      {{- toYaml $__selector | nindent 2 }}
  {{- end }}

  {{- $__template := include "metadata.PodTemplateSpec" . }}
  {{- if $__template }}
    {{- nindent 0 "" -}}template:
      {{- $__template | indent 2 }}
  {{- end }}
{{- end }}
