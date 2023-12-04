{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#preferredschedulingterm-v1-core
*/ -}}
{{- define "definitions.PreferredSchedulingTerm" -}}
  {{- range $k, $v := . }}
    {{- if $v }}
      {{- nindent 0 "" -}}- weight: {{ int (trimPrefix "weight" $k) }}
      {{- nindent 2 "" -}}  preference:
      {{- include "definitions.NodeSelectorTerm" $v | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
