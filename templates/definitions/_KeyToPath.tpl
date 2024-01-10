{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#keytopath-v1-core
*/ -}}
{{- define "definitions.KeyToPath" -}}
  {{- with . }}
    {{- $__key := include "base.string" .key }}
    {{- if $__key }}
      {{- nindent 0 "" -}}key: {{ $__key }}
    {{- else }}
      {{- fail "definitions.KeyToPath: key must be exists" }}
    {{- end }}

    {{- $__mode := include "base.fmt" (dict "s" (toString .mode) "r" "^(0[0124]{3}|[1-9]?[0-9]|[1-4][0-9]{2}|50[0-9]|51[01])$") }}
    {{- if $__mode }}
      {{- nindent 0 "" -}}mode: {{ coalesce $__mode "0644" }}
    {{- end }}

    {{- $__path := include "base.string" .path }}
    {{- if $__path }}
      {{- nindent 0 "" -}}path: {{ $__path }}
    {{- end }}
  {{- end }}
{{- end }}
