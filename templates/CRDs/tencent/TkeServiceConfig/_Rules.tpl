{{- define "crds.tencent.TkeServiceConfig.Rules" -}}
  {{- with . }}
    {{- $__url := include "base.string" .url }}
    {{- if isAbs $__url }}
      {{- nindent 0 "" -}}url: {{ $__url }}
    {{- end }}

    {{- $__forwardTypeAllowed := list "HTTP" "HTTPS" }}
    {{- $__forwardType := include "base.string" .forwardType }}
    {{- if mustHas $__forwardType $__forwardTypeAllowed }}
      {{- nindent 0 "" -}}forwardType: {{ $__forwardType }}
    {{- end }}

    {{- $__session := include "crds.tencent.TkeServiceConfig.Session" .session | fromYaml }}
    {{- if $__session }}
      {{- nindent 0 "" -}}session:
        {{- toYaml $__session | nindent 2 }}
    {{- end }}

    {{- $__healthCheck := include "crds.tencent.TkeServiceConfig.HealthCheck" .healthCheck | fromYaml }}
    {{- if $__healthCheck }}
      {{- nindent 0 "" -}}healthCheck:
        {{- toYaml $__healthCheck | nindent 2 }}
    {{- end }}

    {{- $__schedulerAllowed := list "WRR" "LEAST_CONN" }}
    {{- $__scheduler := include "base.string" .scheduler }}
    {{- if mustHas $__scheduler $__schedulerAllowed }}
      {{- nindent 0 "" -}}scheduler: {{ $__scheduler | upper }}
    {{- end }}
  {{- end }}
{{- end }}
