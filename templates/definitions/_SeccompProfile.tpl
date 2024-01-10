{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#seccompprofile-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-seccomp-profile-for-a-container
*/ -}}
{{- define "definitions.SeccompProfile" -}}
  {{- $__typeAllowed := list "Localhost" "RuntimeDefault" "Unconfined" }}
  {{- with . }}
    {{- $__type := include "base.string" .type }}
    {{- if not (mustHas $__type $__typeAllowed) }}
      {{- fail "definitions.SeccompProfile: type not allowed" }}
    {{- end }}

    {{- if $__type }}
      {{- nindent 0 "" -}}type: {{ $__type }}
      {{- if eq .type "Localhost" }}
        {{- $__localhostProfile := include "base.string" .localhostProfile }}
        {{- if $__localhostProfile }}
          {{- nindent 0 "" -}}localhostProfile: {{ $__localhostProfile }}
        {{- else }}
          {{- fail "definitions.SeccompProfile: Must be set if type is \"Localhost\"" }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
