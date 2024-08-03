{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorterm-v1-core
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorrequirement-v1-core
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorrequirement-v1-core
  descr:
  - 复用 definitions.LabelSelectorRequirement
    - 实际应该调用 definitions.NodeSelectorRequirement
*/ -}}
{{- define "definitions.NodeSelectorTerm" -}}
  {{- with . }}
    {{- $__matchExpressions := list }}
    {{- $__matchFields := list }}

    {{- range .matchExpressions }}
      {{- $__matchExpressions = mustAppend $__matchExpressions (include "definitions.LabelSelectorRequirement" . | fromYaml) }}
    {{- end }}
    {{- range .matchFields }}
      {{- $__matchFields = mustAppend $__matchFields (include "definitions.LabelSelectorRequirement" . | fromYaml) }}
    {{- end }}

    {{- $__matchExpressions = mustCompact (mustUniq $__matchExpressions) }}
    {{- $__matchFields = mustCompact (mustUniq $__matchFields) }}
    {{- if $__matchExpressions }}
      {{- nindent 0 "" -}}matchExpressions:
        {{- toYaml $__matchExpressions | nindent 0 }}
    {{- end }}
    {{- if $__matchFields }}
      {{- nindent 0 "" -}}matchFields:
        {{- toYaml $__matchFields | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
