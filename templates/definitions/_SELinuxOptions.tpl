{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#selinuxoptions-v1-core
  - https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#assign-selinux-labels-to-a-container
*/ -}}
{{- define "definitions.SELinuxOptions" -}}
  {{- with . }}
    {{- if .level }}
      {{- nindent 0 "" -}}level: {{ .level }}
    {{- end }}
    {{- if .role }}
      {{- nindent 0 "" -}}role: {{ .role }}
    {{- end }}
    {{- if .type }}
      {{- nindent 0 "" -}}type: {{ .type }}
    {{- end }}
    {{- if .user }}
      {{- nindent 0 "" -}}user: {{ .user }}
    {{- end }}
  {{- end }}
{{- end }}
