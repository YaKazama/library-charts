{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#secretvolumesource-v1-core
  - https://kubernetes.io/docs/concepts/configuration/secret/
*/ -}}
{{- define "definitions.SecretVolumeSource" -}}
  {{- with . }}
    {{- if or .secretName .name }}
      {{- nindent 0 "" -}}secretName: {{ coalesce .secretName .name }}
    {{- else }}
      {{- fail "secret.secretName not found" }}
    {{- end }}
    {{- if .defaultMode }}
      {{- nindent 0 "" -}}defaultMode: {{ int (coalesce .defaultMode 0644) }}
    {{- end }}
    {{- if .items }}
      {{- nindent 0 "" -}}items:
      {{- include "definitions.KeyToPath" .items | indent 0 }}
    {{- end }}
    {{- if kindIs "bool" .optional }}
      {{- nindent 0 "" -}}optional: {{ .optional }}
    {{- end }}
  {{- end }}
{{- end }}
