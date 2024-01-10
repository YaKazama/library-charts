{{- define "definitions.RoleRef" -}}
  {{- with . }}
    {{- $__apiGroup := include "base.string" (coalesce .apiGroup "rbac.authorization.k8s.io") }}
    {{- if $__apiGroup }}
      {{- nindent 0 "" -}}apiGroup: {{ $__apiGroup }}
    {{- end }}

    {{- $__kind := include "base.string" (coalesce .kind "ClusterRole") }}
    {{- if $__kind }}
      {{- nindent 0 "" -}}kind: {{ $__kind }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- else }}
      {{- fail "definitions.RoleRef: name not found." }}
    {{- end }}
  {{- end }}
{{- end }}
