{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#labelselector-v1-meta
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/
  descr:
  - .Context.LabelSelector 和 .Values.LabelSelector 的支持参考 workloads.DaemonSetSpec 中的处理方式
    - matchExpressions 只能使用 slice 格式
    - matchLabels 只能使用 map 格式
*/ -}}
{{- define "definitions.LabelSelector" -}}
  {{- $__matchExpressions := list }}
  {{- $__matchLabels := dict }}

  {{- if kindIs "slice" . }}
    {{- range . }}
      {{- if kindIs "slice" .matchExpressions }}
        {{- range .matchExpressions }}
          {{- $__matchExpressions = mustAppend $__matchExpressions (include "definitions.LabelSelectorRequirement" . ) }}
        {{- end }}
      {{- end }}

      {{- if kindIs "map" .matchLabels }}
        {{- $__matchLabels = mustMerge $__matchLabels .matchLabels }}
      {{- else }}
        {{- fail "definitions.LabelSelector: matchLabels (slice) not support, please use map" }}
      {{- end }}
    {{- end }}
  {{- else if kindIs "map" . }}
    {{- if .matchExpressions }}
      {{- range .matchExpressions }}
        {{- $__matchExpressions = mustAppend $__matchExpressions (include "definitions.LabelSelectorRequirement" . | fromYaml) }}
      {{- end }}
    {{- end }}

    {{- if kindIs "map" .matchLabels }}
      {{- $__matchLabels = mustMerge $__matchLabels .matchLabels }}
    {{- else }}
      {{- fail "definitions.LabelSelector: matchLabels (map) not support, please use map" }}
    {{- end }}
  {{- else }}
    {{- fail "definitions.LabelSelector: matchExpressions not support, please use slice or map" }}
  {{- end }}

  {{- $__matchExpressions = mustCompact (mustUniq $__matchExpressions) }}
  {{- if $__matchExpressions }}
    {{- nindent 0 "" -}}matchExpressions:
    {{- toYaml $__matchExpressions | nindent 0 }}
  {{- end }}
  {{- if $__matchLabels }}
    {{- nindent 0 "" -}}matchLabels:
      {{- toYaml $__matchLabels | nindent 2 }}
  {{- end }}
{{- end }}
