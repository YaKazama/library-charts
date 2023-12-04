{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#persistentvolumeclaimvolumesource-v1-core
*/ -}}
{{- define "definitions.PersistentVolumeClaimVolumeSource" -}}
  {{- with . }}
    {{- if .claimName }}
      {{- nindent 0 "" -}}claimName: {{ .claimName }}
    {{- else }}
      {{- fail "pvc.claimName not found" }}
    {{- end }}
    {{- if and .readOnly (kindIs "bool" .readOnly) }}
      {{- nindent 0 "" -}}readOnly: true
    {{- end }}
  {{- end }}
{{- end }}
