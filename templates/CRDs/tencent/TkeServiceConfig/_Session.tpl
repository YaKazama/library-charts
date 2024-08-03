{{- define "crds.tencent.TkeServiceConfig.Session" -}}
  {{- with . }}
    {{- $__enable := include "base.bool.false" (list .enable) }}
    {{- $__sessionExpireTime := include "base.int.scope" (list .sessionExpireTime 1 3600) }}

    {{- if $__sessionExpireTime }}
      {{- $__enable = "true" }}
    {{- end }}

    {{- if $__enable }}
      {{- nindent 0 "" -}}enable: {{ $__enable }}
    {{- end }}

    {{- if eq $__enable "true" }}
      {{- if $__sessionExpireTime }}
        {{- nindent 0 "" -}}sessionExpireTime: {{ $__sessionExpireTime }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
