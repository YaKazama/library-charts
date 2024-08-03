{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#selinuxoptions-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#assign-selinux-labels-to-a-container
*/ -}}
{{- define "definitions.SELinuxOptions" -}}
  {{- with . }}
    {{- $__level := include "base.string" .level }}
    {{- if $__level }}
      {{- nindent 0 "" -}}level: {{ $__level }}
    {{- end }}

    {{- $__role := include "base.string" .role }}
    {{- if $__role }}
      {{- nindent 0 "" -}}role: {{ $__role }}
    {{- end }}

    {{- $__type := include "base.string" .type }}
    {{- if $__type }}
      {{- nindent 0 "" -}}type: {{ $__type }}
    {{- end }}

    {{- $__user := include "base.string" .user }}
    {{- if $__user }}
      {{- nindent 0 "" -}}user: {{ $__user }}
    {{- end }}
  {{- end }}
{{- end }}
