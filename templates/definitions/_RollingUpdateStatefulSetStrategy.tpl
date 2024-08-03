{{- define "definitions.RollingUpdateStatefulSetStrategy" -}}
  {{- with . }}
    {{- $__maxUnavailable := include "base.fmt" (dict "s" .maxUnavailable "r" "^\\d+(\\%)?$") }}
    {{- if $__maxUnavailable }}
      {{- nindent 0 "" -}}maxUnavailable: {{ $__maxUnavailable }}
    {{- else }}
      {{- fail "definitions.RollingUpdateStatefulSetStrategy: maxUnavailable can not be 0" }}
    {{- end }}

    {{- $__partition := include "base.int.zero" (list .partition) }}
    {{- if $__partition }}
      {{- nindent 0 "" -}}partition: {{ $__partition }}
    {{- end }}
  {{- end }}
{{- end }}
