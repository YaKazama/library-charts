{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nodeselector-v1-core
*/ -}}
{{- define "definitions.NodeSelector" -}}
  {{- nindent 0 "" -}}nodeSelectorTerms:
    {{- include "definitions.NodeSelectorTerm" . | indent 0 }}
{{- end }}
