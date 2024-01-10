{{- define "crds.tencent.TkeServiceConfig.LoadBalancer" -}}
  {{- $__clean := list }}
  {{- $__l4ListenersSrc := pluck "l4Listeners" .Context .Values }}
  {{- range ($__l4ListenersSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__l4Listeners := list }}
  {{- range $k, $v := include "base.map.merge.single" (dict "s" ($__clean | mustUniq | mustCompact) "k" "protocol") | fromYaml }}
    {{- $__l4Listeners = mustAppend $__l4Listeners (include "crds.tencent.TkeServiceConfig.Listeners.L4" $v | fromYaml) }}
  {{- end }}
  {{- if $__l4Listeners }}
    {{- nindent 0 "" -}}l4Listeners:
    {{- toYaml $__l4Listeners | nindent 0 }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__l7ListenersSrc := pluck "l7Listeners" .Context .Values }}
  {{- range ($__l7ListenersSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__l7Listeners := list }}
  {{- range $k, $v := include "base.map.merge.single" (dict "s" ($__clean | mustUniq | mustCompact) "k" "protocol") | fromYaml }}
    {{- $__l7Listeners = mustAppend $__l7Listeners (include "crds.tencent.TkeServiceConfig.Listeners.L7" $v | fromYaml) }}
  {{- end }}
  {{- if $__l7Listeners }}
    {{- nindent 0 "" -}}l7Listeners:
    {{- toYaml $__l7Listeners | nindent 0 }}
  {{- end }}
{{- end }}
