{{- define "definitions.SessionAffinityConfig" -}}
  {{- $__clientIPConfig := "" }}

  {{- if kindIs "float64" . }}
    {{- $__clientIPConfig = include "definitions.ClientIPConfig" . }}
  {{- else if kindIs "map" . }}
    {{- with . }}
      {{- if .clientIP }}
          {{- $__clientIPConfig = include "definitions.ClientIPConfig" .clientIP }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- if $__clientIPConfig }}
    {{- nindent 0 "" -}}clientIP:
      {{- $__clientIPConfig | indent 2 }}
  {{- end }}
{{- end }}
