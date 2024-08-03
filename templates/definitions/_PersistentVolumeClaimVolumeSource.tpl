{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#persistentvolumeclaimvolumesource-v1-core
*/ -}}
{{- define "definitions.PersistentVolumeClaimVolumeSource" -}}
  {{- with . }}
    {{- $__claimName := include "base.string" .claimName }}
    {{- if $__claimName }}
      {{- nindent 0 "" -}}claimName: {{ $__claimName }}
    {{- end }}

    {{- $__readOnly := include "base.bool" .readOnly }}
    {{- if $__readOnly }}
      {{- nindent 0 "" -}}readOnly: {{ $__readOnly }}
    {{- end }}
  {{- end }}
{{- end }}
