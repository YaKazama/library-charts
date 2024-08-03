{{- define "definitions.StatefulSetOrdinals" -}}
  {{- with . }}
    {{- $__start := include "base.int.zero" (list .start) }}
    {{- if $__start }}
      {{- nindent 0 "" -}}start: {{ $__start }}
    {{- end }}
  {{- end }}
{{- end }}
