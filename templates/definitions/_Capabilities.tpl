{{- define "definitions.Capabilities" -}}
  {{- with . }}
    {{- $__addClean := list }}
    {{- if kindIs "string" .add }}
      {{- $__addClean = mustAppend $__addClean .add }}
    {{- else if kindIs "slice" .add }}
      {{- $__addClean = concat $__addClean .add }}
    {{- end }}
    {{- $__add := include "base.fmt.slice" (dict "s" $__addClean) }}
    {{- if $__add }}
      {{- nindent 0 "" -}}add:
      {{- $__add | nindent 0 }}
    {{- end }}

    {{- $__dropClean := list }}
    {{- if kindIs "string" .drop }}
      {{- $__dropClean = mustAppend $__dropClean .drop }}
    {{- else if kindIs "slice" .drop }}
      {{- $__dropClean = concat $__dropClean .drop }}
    {{- end }}
    {{- $__drop := include "base.fmt.slice" (dict "s" $__dropClean) }}
    {{- if $__drop }}
      {{- nindent 0 "" -}}drop:
      {{- $__drop | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
