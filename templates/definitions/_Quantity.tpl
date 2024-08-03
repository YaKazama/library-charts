{{- define "definitions.Quantity" -}}
  {{- with . }}
    {{- $__regexQuantity := "^[+-]?(\\d+)?\\.?(\\d+)?([KMGTPE]i|[mkMGTPE]|[eE]\\s[+-]?(\\d+)?\\.?(\\d+)?)?$" }}
    {{- include "base.fmt" (dict "s" . "r" $__regexQuantity) }}
  {{- end }}
{{- end }}
