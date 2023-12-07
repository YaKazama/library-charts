{{- define "definitions.IngressRule" -}}
  {{- $__regexHost := "^(\\*\\.)?([a-zA-Z0-9][-a-zA-Z0-9]{0,62})(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+$" }}
  {{- with . }}
    {{- if mustRegexMatch $__regexHost .host }}
      {{- nindent 0 "" -}}host: {{ .host | quote }}
    {{- else }}
      {{- fail "definitions.IngressRule: .host not allowed" }}
    {{- end }}

    {{- if .http }}
      {{- range .http }}
        {{- if and .apiGroup .kind .name }}
          {{- $_ := set . "backendType" "resource" }}
        {{- else if or (and .portName .name) (and .portNumber .name) }}
          {{- $_ := set . "backendType" "service" }}
        {{- end }}
      {{- end }}

      {{- $__backend := (include "definitions.HTTPIngressRuleValue" .http | fromYaml) }}

      {{- if $__backend }}
        {{- nindent 0 "" -}}http:
          {{- toYaml $__backend | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
