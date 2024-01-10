{{- define "crds.gcp.BackendConfig.Logging" -}}
  {{- with . }}
    {{- $__enable := include "base.bool.false" (list .enable) }}
    {{- $__sampleRate := include "base.float.scope" (list .sampleRate 0.0 1.0) }}

    {{- if $__sampleRate }}
      {{- $__enable = "true" }}
    {{- end }}

    {{- if $__enable }}
      {{- nindent 0 "" -}}enable: {{ $__enable }}
    {{- end }}

    {{- if eq $__enable "true" }}
      {{- if $__sampleRate }}
        {{- nindent 0 "" -}}sampleRate: {{ $__sampleRate }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
