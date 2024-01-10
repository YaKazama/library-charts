{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podaffinityterm-v1-core
  TODO: labelSelector 和 namespaceSelector 需要配合 definitions.LabelSelector 进行修改
*/ -}}
{{- define "definitions.PodAffinityTerm" -}}
  {{- with . }}
    {{- if .topologyKey }}
      {{- nindent 0 "" -}}topologyKey: {{ .topologyKey | quote }}
    {{- else }}
      {{- fail "definitions.PodAffinityTerm: Empty topologyKey is not allowed" }}
    {{- end }}

    {{- if .labelSelector }}
      {{- nindent 0 "" -}}labelSelector:
        {{- include "definitions.LabelSelector" .labelSelector | indent 2 }}
    {{- end }}

    {{- if .namespaceSelector }}
      {{- nindent 0 "" -}}namespaceSelector:
        {{- include "definitions.LabelSelector" .namespaceSelector | indent 2 }}
    {{- end }}

    {{- if .namespaces }}
      {{- $__namespaces := include "base.fmt.slice" (dict "s" (list .namespaces)) }}
      {{- nindent 0 "" -}}namespaces:
      {{- $__namespaces | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
