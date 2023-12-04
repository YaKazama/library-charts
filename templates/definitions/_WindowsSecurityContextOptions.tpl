{{- /*
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#windowssecuritycontextoptions-v1-core
*/ -}}
{{- define "definitions.WindowsSecurityContextOptions" -}}
  {{- with . }}
    {{- if .gmsaCredentialSpec }}
      {{- nindent 0 "" -}}gmsaCredentialSpec: {{ .gmsaCredentialSpec }}
    {{- end }}
    {{- if .gmsaCredentialSpecName }}
      {{- nindent 0 "" -}}gmsaCredentialSpecName: {{ .gmsaCredentialSpecName }}
    {{- end }}
    {{- if and .hostProcess (kindIs "bool" .hostProcess) }}
      {{- nindent 0 "" -}}hostProcess: true
    {{- end }}
    {{- if .runAsUserName }}
      {{- nindent 0 "" -}}runAsUserName: {{ .runAsUserName }}
    {{- end }}
  {{- end }}
{{- end }}
