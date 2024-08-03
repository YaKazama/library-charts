{{- define "crds.gcp.ManagedCertificate.ManagedCertificateSpec" -}}
  {{- $__clean := list }}
  {{- $__domainsSrc := pluck "domains" .Context .Values }}
  {{- range ($__domainsSrc | mustUniq | mustCompact) }}
    {{- if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- else if kindIs "string" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__domains := include "base.fmt.slice" (dict "s" $__clean) }}
  {{- if $__domains }}
    {{- nindent 0 "" -}}domains:
    {{- $__domains | nindent 0 }}
  {{- end }}
{{- end }}
