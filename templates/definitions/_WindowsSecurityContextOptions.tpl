{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#windowssecuritycontextoptions-v1-core
*/ -}}
{{- define "definitions.WindowsSecurityContextOptions" -}}
  {{- with . }}
    {{- $__gmsaCredentialSpec := include "base.string" .gmsaCredentialSpec }}
    {{- if $__gmsaCredentialSpec }}
      {{- nindent 0 "" -}}gmsaCredentialSpec: {{ $__gmsaCredentialSpec }}
    {{- end }}

    {{- $__gmsaCredentialSpecName := include "base.string" .gmsaCredentialSpecName }}
    {{- if $__gmsaCredentialSpecName }}
      {{- nindent 0 "" -}}gmsaCredentialSpecName: {{ $__gmsaCredentialSpecName }}
    {{- end }}

    {{- $__hostProcess := include "base.bool" .hostProcess }}
    {{- if $__hostProcess }}
      {{- nindent 0 "" -}}hostProcess: {{ $__hostProcess }}
    {{- end }}

    {{- $__runAsUserName := include "base.string" .runAsUserName }}
    {{- if $__runAsUserName }}
      {{- nindent 0 "" -}}runAsUserName: {{ $__runAsUserName }}
    {{- end }}
  {{- end }}
{{- end }}
