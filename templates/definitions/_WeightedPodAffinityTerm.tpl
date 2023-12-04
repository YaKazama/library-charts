{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#weightedpodaffinityterm-v1-core
*/ -}}
{{- define "definitions.WeightedPodAffinityTerm" -}}
  {{- range $k, $v := . }}
    {{- if $v }}
      {{- nindent 0 "" -}}- weight: {{ int (trimPrefix "weight" $k) }}
      {{- nindent 2 "" -}}  podAffinityTerm:
      {{- include "definitions.PodAffinityTerm" $v | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
