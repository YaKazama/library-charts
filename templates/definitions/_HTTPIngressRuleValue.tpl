{{- define "definitions.HTTPIngressRuleValue" -}}
  {{- with . }}
    {{- $__paths := list }}

    {{- range . }}
      {{- $__paths = mustAppend $__paths (include "definitions.HTTPIngressPath" . | fromYaml) }}
    {{- end }}

    {{- if mustCompact (mustUniq $__paths) }}
      {{- nindent 0 "" -}}paths:
      {{- toYaml $__paths | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
