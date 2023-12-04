{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#labelselector-v1-meta
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/
  descr:
  - matchLabels 默认会统一添加
  - matchExpressions 为列表，以“|”作为分隔符。格式: <key> <operator> <value>
    - <value> 如果使用 array 需要使用 ["a", "b"] 形式
    - <operator> 的值为 In, NotIn, Exists, DoesNotExists
      - 当值为 Exists 或 DoesNotExists 时，<value> 可以为空
*/ -}}
{{- define "definitions.LabelSelector" -}}
  {{- nindent 0 "" -}}matchLabels:
  {{- if .matchLabels }}
    {{- /*
      for base.PodAffinityTerm
    */ -}}
    {{- toYaml .matchLabels | nindent 2 }}
  {{- else }}
    {{- include "base.labels" . | indent 2 }}
  {{- end }}

  {{- if or .matchExpressions ._CTX.matchExpressions }}
    {{- nindent 0 "" -}}matchExpressions:
    {{- if .matchExpressions }}
      {{- /*
        for base.PodAffinityTerm
      */ -}}
      {{- include "definitions.LabelSelectorRequirement" .matchExpressions | indent 0 }}
    {{- else }}
      {{- include "definitions.LabelSelectorRequirement" ._CTX.matchExpressions | indent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
