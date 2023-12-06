{{- define "definitions.ClientIPConfig" -}}
  {{- if kindIs "float64" . }}
    {{- $__num := (int .) }}
    {{- if le (int $__num) 0 }}
      {{- $__num = 10800 }}
    {{- end }}
    {{- if gt (int $__num) 86400 }}
      {{- $__num = 86400 }}
    {{- end }}
    {{- nindent 0 "" -}}timeoutSeconds: {{ toString $__num }}
  {{- else if kindIs "map" . }}
    {{- with . }}
      {{- if kindIs "float64" .timeoutSeconds }}
        {{- if le (int .timeoutSeconds) 0 }}
          {{- $_ := set . "timeoutSeconds" 10800 }}
        {{- end }}
        {{- if gt (int .timeoutSeconds) 86400 }}
          {{- $_ := set . "timeoutSeconds" 86400 }}
        {{- end }}
        {{- nindent 0 "" -}}timeoutSeconds: {{ toString .timeoutSeconds }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
