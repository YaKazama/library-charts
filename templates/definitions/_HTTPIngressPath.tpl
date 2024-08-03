{{- define "definitions.HTTPIngressPath" -}}
  {{- with . }}
    {{- $__backend := include "definitions.IngressBackend" . | fromYaml }}
    {{- if $__backend }}
      {{- nindent 0 "" -}}backend:
        {{- toYaml $__backend | nindent 2 }}
    {{- end }}

    {{- $__pathPrefix := include "base.string" .pathPrefix }}
    {{- $__pathSuffix := include "base.string" .pathSuffix }}
    {{- $__path := include "base.string" .path }}
    {{- if and $__path (or $__pathPrefix $__pathSuffix) }}
      {{- $__path = print $__pathPrefix $__path $__pathSuffix | trim }}
    {{- end }}
    {{- if isAbs $__path }}
      {{- nindent 0 "" -}}path: {{ $__path }}
    {{- else }}
      {{- fail "definitions.HTTPIngressPath: path must be exists" }}
    {{- end }}

    {{- $__pathTypeAllowed := list "Exact" "Prefix" "ImplementationSpecific" }}
    {{- $__pathType := include "base.string" .pathType }}
    {{- if mustHas $__pathType $__pathTypeAllowed }}
      {{- nindent 0 "" -}}pathType: {{ $__pathType }}
    {{- else }}
      {{- fail "definitions.HTTPIngressPath: pathType must be exists" }}
    {{- end }}
  {{- end }}
{{- end }}
