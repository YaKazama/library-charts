{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#nfsvolumesource-v1-core
*/ -}}
{{- define "definitions.NFSVolumeSource" -}}
  {{- with . }}
    {{- $__path := include "base.fmt" (dict "s" .path "r" "^/.*") }}
    {{- if $__path }}
      {{- nindent 0 "" -}}path: {{ $__path }}
    {{- else }}
      {{- fail "definitions.NFSVolumeSource: .path invalid or not found" }}
    {{- end }}

    {{- $__readOnly := include "base.bool" .readOnly }}
    {{- if $__readOnly }}
      {{- nindent 0 "" -}}readOnly: {{ $__readOnly }}
    {{- end }}

    {{- $__server := include "base.string" .server }}
    {{- if $__server }}
      {{- nindent 0 "" -}}server: {{ $__server }}
    {{- else }}
      {{- fail "definitions.NFSVolumeSource: .server must be exists" }}
    {{- end }}
  {{- end }}
{{- end }}
