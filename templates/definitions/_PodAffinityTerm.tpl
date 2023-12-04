{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podaffinityterm-v1-core
*/ -}}
{{- define "definitions.PodAffinityTerm" -}}
  {{- with . }}
    {{- if .topologyKey }}
      {{- nindent 0 "" -}}- topologyKey: {{ .topologyKey | quote }}
    {{- else }}
      {{- fail "Empty topologyKey is not allowed" }}
    {{- end }}

    {{- if .labelSelector }}
      {{- nindent 2 "" -}}labelSelector:
      {{- include "definitions.LabelSelector" .labelSelector | indent 4 }}
    {{- end }}

    {{- if .namespaceSelector }}
      {{- nindent 2 "" -}}namespaceSelector:
      {{- include "definitions.LabelSelector" .namespaceSelector | indent 4 }}
    {{- end }}

    {{- if .namespaces }}
      {{- nindent 2 "" -}}namespaces:
      {{- toYaml .namespaces | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
