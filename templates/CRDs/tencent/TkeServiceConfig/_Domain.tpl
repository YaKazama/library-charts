{{- define "crds.tencent.TkeServiceConfig.Domain" -}}
  {{- with . }}
    {{- $__domain := include "base.string.empty" (dict "s" .domain "empty" true) }}
    {{- if $__domain }}
      {{- nindent 0 "" -}}domain: {{ $__domain }}
    {{- end }}

    {{- $__rules := list }}
    {{- range (.rules | mustUniq | mustCompact) }}
      {{- $__rules = mustAppend $__rules (include "crds.tencent.TkeServiceConfig.Rules" . | fromYaml) }}
    {{- end }}
    {{- $__rules = $__rules | mustUniq | mustCompact }}
    {{- if $__rules }}
      {{- nindent 0 "" -}}rules:
      {{- toYaml $__rules | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
