{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorterm-v1-core
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorrequirement-v1-core
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselectorrequirement-v1-core
  descr:
  - 复用 definitions.LabelSelectorRequirement
*/ -}}
{{- define "definitions.NodeSelectorTerm" -}}
  {{- if .matchExpressions }}
    {{- nindent 0 "" -}}- matchExpressions:
      {{- include "definitions.LabelSelectorRequirement" .matchExpressions | indent 2 }}
  {{- end }}
  {{- if .matchFields }}
    {{- nindent 0 "" -}}- matchFields:
      {{- include "definitions.LabelSelectorRequirement" .matchFields | indent 2 }}
  {{- end }}
{{- end }}
