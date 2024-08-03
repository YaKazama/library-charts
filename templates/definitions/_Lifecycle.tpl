{{- define "definitions.Lifecycle" -}}
  {{- with . }}
    {{- $__postStart := include "definitions.LifecycleHandler" .postStart | fromYaml }}
    {{- if $__postStart }}
      {{- nindent 0 "" -}}postStart:
        {{- toYaml $__postStart | nindent 2 }}
    {{- end }}

    {{- $__preStop := include "definitions.LifecycleHandler" .preStop | fromYaml }}
    {{- if $__preStop }}
      {{- nindent 0 "" -}}preStop:
        {{- toYaml $__preStop | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
