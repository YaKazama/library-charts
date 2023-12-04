{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#seccompprofile-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-seccomp-profile-for-a-container
*/ -}}
{{- define "definitions.SeccompProfile" -}}
  {{- $__typeList := list "Localhost" "RuntimeDefault" "Unconfined" }}
  {{- with . }}
    {{- if mustHas .type $__typeList }}
      {{- nindent 0 "" -}}type: {{ .type }}

      {{- if eq .type "Localhost" }}
        {{- if .localhostProfile }}
          {{- nindent 0 "" -}}localhostProfile: {{ .localhostProfile }}
        {{- else }}
          {{- fail "Must be set if type is \"Localhost\"" }}
        {{- end }}
      {{- end }}
    {{- else }}
      {{- fail "seccompProfile.type not support" }}
    {{- end }}
  {{- end }}
{{- end }}
