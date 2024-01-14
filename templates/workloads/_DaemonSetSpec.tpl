{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#daemonsetspec-v1-apps
*/ -}}
{{- define "workloads.DaemonSetSpec" -}}
  {{- $__minReadySeconds := include "base.int" (coalesce .Context.minReadySeconds .Values.minReadySeconds) }}
  {{- if $__minReadySeconds }}
    {{- nindent 0 "" -}}minReadySeconds: {{ $__minReadySeconds }}
  {{- end }}

  {{- $__revisionHistoryLimit := include "base.int" (coalesce .Context.revisionHistoryLimit .Values.revisionHistoryLimit) }}
  {{- if $__revisionHistoryLimit }}
    {{- nindent 0 "" -}}revisionHistoryLimit: {{ $__revisionHistoryLimit }}
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

  {{- $__templateSrc := pluck "template" .Context .Values }}
  {{- range ($__templateSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- /*
        The only allowed template.spec.restartPolicy value is "Always".
        此处直接覆盖 $.Context.restartPolicy 的值
      */ -}}
      {{- $__valTempate := dig "spec" "restartPolicy" "Always" . }}
      {{- if not (eq $__valTempate "Always") }}
        {{- $_ := set $.Context "restartPolicy" "Always" }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__template := include "metadata.PodTemplateSpec" . | fromYaml }}
  {{- if $__template }}
    {{- nindent 0 "" -}}template:
      {{- toYaml $__template | nindent 2 }}
  {{- end }}

  {{- $__clean := dict }}
  {{- $__updateStrategySrc := pluck "updateStrategy" .Context .Values }}
  {{- range ($__updateStrategySrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__updateStrategy := include "definitions.DaemonSetUpdateStrategy" $__clean | fromYaml }}
  {{- if $__updateStrategy }}
    {{- nindent 0 "" -}}updateStrategy:
      {{- toYaml $__updateStrategy | nindent 2 }}
  {{- end }}
{{- end }}
