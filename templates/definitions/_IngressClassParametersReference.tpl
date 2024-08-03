{{- define "definitions.IngressClassParametersReference" -}}
  {{- with . }}
    {{- $__apiGroup := include "base.string" .apiGroup }}
    {{- if $__apiGroup }}
      {{- nindent 0 "" -}}apiGroup: {{ $__apiGroup }}
    {{- end }}

    {{- $__kind := include "base.string" .kind }}
    {{- if $__kind }}
      {{- nindent 0 "" -}}kind: {{ $__kind }}
    {{- else }}
      {{- fail "definitions.IngressClassParametersReference: kind must be exists" }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- else }}
      {{- fail "definitions.IngressClassParametersReference: name must be exists" }}
    {{- end }}

    {{- $__namespace := include "base.string" .namespace }}
    {{- $__scope := include "base.string" .scope }}
    {{- $__scopeAllowed := list "Cluster" "Namespace" }}
    {{- if mustHas $__scope $__scopeAllowed }}
      {{- if eq $__scope "Namespace" }}
        {{- nindent 0 "" -}}namespace: {{ $__namespace }}
      {{- end }}

      {{- nindent 0 "" -}}scope: {{ $__scope }}
    {{- end }}
  {{- end }}
{{- end }}
