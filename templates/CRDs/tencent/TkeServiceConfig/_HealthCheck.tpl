{{- define "crds.tencent.TkeServiceConfig.HealthCheck" -}}
  {{- with . }}
    {{- $__enable := include "base.bool.false" (list .enable) }}
    {{- $__intervalTime := include "base.int.scope" (list .intervalTime 1 300) }}
    {{- $__healthNum := include "base.int.scope" (list .healthNum 2 10) }}
    {{- $__unHealthNum := include "base.int.scope" (list .unHealthNum 2 10) }}
    {{- $__timeout := include "base.int.scope" (list .timeout 2 60) }}
    {{- $__httpCheckPath := include "base.string" .httpCheckPath }}
    {{- $__httpCheckDomain := include "base.string" .httpCheckDomain }}
    {{- $__httpCheckMethod := include "base.string" .httpCheckMethod }}
    {{- $__httpCode := include "base.int.scope" (list .httpCode 1 31) }}
    {{- $__sourceIpType := include "base.int.scope" (list .sourceIpType 0 1) }}

    {{- if or $__intervalTime $__healthNum $__unHealthNum $__timeout $__httpCheckPath $__httpCheckDomain $__httpCheckMethod $__httpCode $__sourceIpType }}
      {{- $__enable = "true" }}
    {{- end }}

    {{- if $__enable }}
      {{- nindent 0 "" -}}enable: {{ $__enable }}
    {{- end }}

    {{- if eq $__enable "true" }}
      {{- if $__intervalTime }}
        {{- nindent 0 "" -}}intervalTime: {{ $__intervalTime }}
      {{- end }}

      {{- if $__healthNum }}
        {{- nindent 0 "" -}}healthNum: {{ $__healthNum }}
      {{- end }}

      {{- if $__unHealthNum }}
        {{- nindent 0 "" -}}unHealthNum: {{ $__unHealthNum }}
      {{- end }}

      {{- if $__timeout }}
        {{- nindent 0 "" -}}timeout: {{ $__timeout }}
      {{- end }}

      {{- if isAbs $__httpCheckPath }}
        {{- nindent 0 "" -}}httpCheckPath: {{ $__httpCheckPath }}
      {{- end }}

      {{- if $__httpCheckDomain }}
        {{- nindent 0 "" -}}httpCheckDomain: {{ $__httpCheckDomain }}
      {{- end }}

      {{- if $__httpCheckMethod }}
        {{- nindent 0 "" -}}httpCheckMethod: {{ $__httpCheckMethod | upper }}
      {{- end }}

      {{- if $__httpCode }}
        {{- nindent 0 "" -}}httpCode: {{ $__httpCode }}
      {{- end }}

      {{- if $__sourceIpType }}
        {{- nindent 0 "" -}}sourceIpType: {{ $__sourceIpType }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
