{{- define "definitions.ResourceClaim" -}}
  {{- with . }}
    {{- $__name := "" }}
    {{- if kindIs "string" . }}
      {{- $__name = include "base.string" . }}
    {{- else if kindIs "map" . }}
      {{- if .name }}
        {{- $__name = include "base.string" .name }}
      {{- end }}
    {{- end }}

    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}
  {{- end }}
{{- end }}
