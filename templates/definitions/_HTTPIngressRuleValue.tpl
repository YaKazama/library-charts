{{- define "definitions.HTTPIngressRuleValue" -}}
  {{- with . }}
    {{- $__val := list }}
    {{- range .http }}
      {{- $__val = mustAppend $__val (include "definitions.HTTPIngressPath" . | fromYaml) }}
    {{- end }}
    {{- $__paths := list }}
    {{- range (include "base.map.merge.single" (dict "s" $__val "k" "path") | fromYaml) }}
      {{- $__paths = mustAppend $__paths . }}
    {{- end }}
    {{- $__paths = $__paths | mustUniq | mustCompact }}
    {{- if $__paths }}
      {{- nindent 0 "" -}}paths:
      {{- toYaml $__paths | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
