{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#deploymentspec-v1-apps
*/ -}}
{{- define "workloads.DeploymentSpec" -}}
  {{- $__minReadySeconds := include "base.int" (coalesce .Context.minReadySeconds .Values.minReadySeconds) }}
  {{- if $__minReadySeconds }}
    {{- nindent 0 "" -}}minReadySeconds: {{ $__minReadySeconds }}
  {{- end }}

  {{- $__paused := include "base.bool" (coalesce .Context.paused .Values.paused) }}
  {{- if $__paused }}
    {{- nindent 0 "" -}}paused: {{ $__paused }}
  {{- end }}

  {{- $__progressDeadlineSeconds := include "base.int.zero" (pluck "progressDeadlineSeconds" .Context .Values) }}
  {{- if $__progressDeadlineSeconds }}
    {{- nindent 0 "" -}}progressDeadlineSeconds: {{ $__progressDeadlineSeconds }}
  {{- end }}

  {{- $__replicas := include "base.int" (coalesce .Context.replicas .Values.replicas) }}
  {{- if $__replicas }}
    {{- nindent 0 "" -}}replicas: {{ $__replicas }}
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
  {{- /*
    追加 labels 到 selector ，受 ignoreLabels 参数影响
  */ -}}
  {{- $__ignoreLabels := false }}
  {{- if eq ._kind "Namespace" }}
    {{- $__ignoreLabels = include "base.bool" (coalesce .Context.ignoreLabels .Values.ignoreLabels) }}
  {{- end }}
  {{- if not $__ignoreLabels }}
    {{- $_ := set $__clean "matchLabels" (mustMerge $__clean.matchLabels (include "base.labels" . | fromYaml)) }}
  {{- end }}
  {{- $__selector := include "definitions.LabelSelector" $__clean | fromYaml }}
  {{- if $__selector }}
    {{- nindent 0 "" -}}selector:
      {{- toYaml $__selector | nindent 2 }}
  {{- end }}

  {{- $__clean := dict }}
  {{- $__strategySrc := pluck "strategy" .Context .Values }}
  {{- range ($__strategySrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__strategy := include "workloads.DeploymentStrategy" $__clean | fromYaml }}
  {{- if $__strategy }}
    {{- nindent 0 "" -}}strategy:
      {{- toYaml $__strategy | nindent 2 }}
  {{- end }}

  {{- $__template := include "metadata.PodTemplateSpec" . | fromYaml }}
  {{- if $__template }}
    {{- nindent 0 "" -}}template:
      {{- toYaml $__template | nindent 2 }}
  {{- end }}
{{- end }}
