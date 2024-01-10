{{- define "definitions.HTTPIngressRuleValue" -}}
  {{- with . }}
    {{- $__paths := list }}
    {{- range .http }}
      {{- $__paths = mustAppend $__paths (include "definitions.HTTPIngressPath" . | fromYaml) }}
    {{- end }}
    {{- $__paths := $__paths | mustUniq | mustCompact }}
    {{- if $__paths }}
      {{- nindent 0 "" -}}paths:
      {{- toYaml $__paths | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
