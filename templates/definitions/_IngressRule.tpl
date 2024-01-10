{{- define "definitions.IngressRule" -}}
  {{- with . }}
    {{- $__regexHost := "^(\\*\\.)?([a-zA-Z0-9][-a-zA-Z0-9]{0,62})(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$" }}
    {{- $__host := include "base.string" .host }}
    {{- $__host = include "base.fmt" (dict "s" $__host "r" $__regexHost) }}
    {{- if $__host }}
      {{- /*
        域名可能出现 * 号, 所以此处添加 quote
      */ -}}
      {{- nindent 0 "" -}}host: {{ $__host | quote }}
    {{- end }}

    {{- $__http := include "definitions.HTTPIngressRuleValue" (dict "http" .http) | fromYaml }}
    {{- if $__http }}
      {{- nindent 0 "" -}}http:
        {{- toYaml $__http | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
