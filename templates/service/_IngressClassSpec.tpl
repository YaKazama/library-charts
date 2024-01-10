{{- define "service.IngressClassSpec" -}}
  {{- $__controller := include "base.string" (coalesce .Context.controller .Values.controller) }}
  {{- if $__controller }}
    {{- nindent 0 "" -}}controller: {{ $__controller }}
  {{- end }}

  {{- $__clean := dict }}
  {{- $__parametersSrc := pluck "parameters" .Context .Values }}
  {{- range ($__parametersSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustMerge $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__parameters := include "definitions.IngressClassParametersReference" $__clean | fromYaml }}
  {{- if $__parameters }}
    {{- nindent 0 "" -}}parameters:
      {{- toYaml $__parameters | nindent 2 }}
  {{- end }}
{{- end }}
