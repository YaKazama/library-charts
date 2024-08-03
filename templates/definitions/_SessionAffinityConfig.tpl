{{- define "definitions.SessionAffinityConfig" -}}
  {{- with . }}
    {{- $__clean := dict }}
    {{- if or (kindIs "int" .clientIP) (kindIs "float64" .clientIP) }}
      {{- $__clean = mustMerge (dict "timeoutSeconds" .clientIP) }}
    {{- else if kindIs "map" .clientIP }}
      {{- $__clean = mustMerge $__clean .clientIP }}
    {{- end }}
    {{- $__clientIP := include "definitions.ClientIPConfig" $__clean | fromYaml }}
    {{- if $__clientIP }}
      {{- nindent 0 "" -}}clientIP:
        {{- toYaml $__clientIP | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
