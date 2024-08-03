{{- define "definitions.ResourceFieldSelector" -}}
  {{- with . }}
    {{- $__containerName := include "base.string" .containerName }}
    {{- if $__containerName }}
      {{- nindent 0 "" -}}containerName: {{ $__containerName }}
    {{- end }}

    {{- $__divisor := include "definitions.Quantity" .divisor }}
    {{- if $__divisor }}
      {{- nindent 0 "" -}}divisor: {{ coalesce $__divisor "" }}
    {{- end }}

    {{- $__resource := include "base.string" .resource }}
    {{- if $__resource }}
      {{- nindent 0 "" -}}resource: {{ $__resource }}
    {{- end }}
  {{- end }}
{{- end }}
