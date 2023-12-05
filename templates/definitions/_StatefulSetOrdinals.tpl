{{- define "definitions.StatefulSetOrdinals" -}}
  {{- $__regexNum := "^\\d+$" }}

  {{- if kindIs "map" . }}
    {{- with . }}
      {{- nindent 0 "" -}}start: {{ int .start }}
    {{- end }}
  {{- else if mustRegexMatch $__regexNum (toString .) }}
    {{- nindent 0 "" -}}start: {{ int . }}
  {{- end }}
{{- end }}
