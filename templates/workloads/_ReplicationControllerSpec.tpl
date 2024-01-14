{{- define "workloads.ReplicationControllerSpec" -}}
  {{- $__minReadySeconds := include "base.int" (coalesce .Context.minReadySeconds .Values.minReadySeconds) }}
  {{- if $__minReadySeconds }}
    {{- nindent 0 "" -}}minReadySeconds: {{ $__minReadySeconds }}
  {{- end }}

  {{- $__replicas := include "base.int" (coalesce .Context.replicas .Values.replicas) }}
  {{- if $__replicas }}
    {{- nindent 0 "" -}}replicas: {{ $__replicas }}
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
  {{- /*
    追加 labels 到 selector ，受 ignoreLabels 参数影响
  */ -}}
  {{- $__ignoreLabels := false }}
  {{- if eq ._kind "Namespace" }}
    {{- $__ignoreLabels = include "base.bool" (coalesce .Context.ignoreLabels .Values.ignoreLabels) }}
  {{- end }}
  {{- if not $__ignoreLabels }}
    {{- $__selector = mustMerge $__selector (include "base.labels" . | fromYaml) }}
  {{- end }}
  {{- if $__selector }}
    {{- nindent 0 "" -}}selector:
      {{- toYaml $__selector | nindent 2 }}
  {{- end }}

  {{- $__template := include "metadata.PodTemplateSpec" . | fromYaml }}
  {{- if $__template }}
    {{- nindent 0 "" -}}template:
      {{- toYaml $__template | nindent 2 }}
  {{- end }}
{{- end }}
