{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#emptydirvolumesource-v1-core
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#quantity-resource-core
  - https://kubernetes.io/zh-cn/docs/reference/kubernetes-api/common-definitions/quantity/
*/ -}}
{{- define "definitions.EmptyDirVolumeSource" -}}
  {{- $__regexMediumAllowed := list "Memory" }}

  {{- with . }}
    {{- $__medium := include "base.string" .medium }}
    {{- if mustHas $__medium $__regexMediumAllowed }}
      {{- nindent 0 "" -}}medium: {{ coalesce $__medium "" }}
    {{- end }}

    {{- $__sizeLimit := include "definitions.Quantity" .sizeLimit }}
    {{- if $__sizeLimit }}
      {{- nindent 0 "" -}}sizeLimit: {{ coalesce $__sizeLimit "" }}
    {{- end }}
  {{- end }}
{{- end }}
