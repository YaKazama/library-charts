{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#containerport-v1-core
*/ -}}
{{- define "definitions.ContainerPort" -}}
  {{- with . }}
    {{- $__containerPort := include "base.int" .containerPort }}
    {{- if $__containerPort }}
      {{- $__containerPort := include "base.int.scope" (list .containerPort 1 65535) }}
      {{- nindent 0 "" -}}containerPort: {{ $__containerPort }}
    {{- end }}

    {{- $__regexIP := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
    {{- $__hostIP := include "base.string" .hostIP }}
    {{- if mustRegexMatch $__regexIP $__hostIP }}
      {{- nindent 0 "" -}}hostIP: {{ $__hostIP }}
    {{- end }}

    {{- $__hostPort := include "base.int.scope" (list .hostPort 1 65535) }}
    {{- if $__hostPort }}
      {{- nindent 0 "" -}}hostPort: {{ $__hostPort }}
    {{- end }}

    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__protocolAllowed := list "TCP" "UDP" "SCTP" }}
    {{- $__protocol := include "base.string" .protocol | upper }}
    {{- if mustHas $__protocol $__protocolAllowed }}
      {{- nindent 0 "" -}}protocol: {{ (coalesce $__protocol "TCP") | upper }}
    {{- end }}

  {{- end }}
{{- end }}
