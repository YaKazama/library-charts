{{- define "definitions.ClientIPConfig" -}}
  {{- with . }}
    {{- $__scope := list .timeoutSeconds 1 9223372036854775807 }}
    {{- if eq .sessionAffinity "ClientIP" }}
      {{- $__scope = list .timeoutSeconds 1 86400 }}
    {{- end }}
    {{- $__timeoutSeconds := include "base.int.scope" $__scope }}
    {{- if $__timeoutSeconds }}
      {{- nindent 0 "" -}}timeoutSeconds: {{ $__timeoutSeconds }}
    {{- end }}
  {{- end }}
{{- end }}
