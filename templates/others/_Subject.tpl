{{- define "others.Subject.v1" -}}
  {{- with . }}
    {{- $__kindAllowed := list "User" "Group" "ServiceAccount" }}

    {{- $__apiGroup := include "base.string" (coalesce .apiGroup "rbac.authorization.k8s.io") }}
    {{- $__kind := include "base.string" .kind }}
    {{- if and (mustHas $__kind $__kindAllowed) (not (eq $__kind "ServiceAccount")) }}
      {{- nindent 0 "" -}}apiGroup: {{ $__apiGroup }}
    {{- end }}
    {{- if mustHas $__kind $__kindAllowed }}
      {{- nindent 0 "" -}}kind: {{ $__kind }}
    {{- else }}
      {{- fail "others.Subject.v1: kind not support, only User, Group and ServiceAccount are supported." }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- else }}
      {{- fail "others.Subject.v1: name not found." }}
    {{- end }}

    {{- $__namespace := include "base.string" .namespace }}
    {{- if $__namespace }}
      {{- if not (or (eq $__kind "User") (eq $__kind "Group")) }}
        {{- nindent 0 "" -}}namespace: {{ $__namespace }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
