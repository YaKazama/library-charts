{{- define "crds.gcp.BackendConfig.HealthCheck" -}}
  {{- with . }}
    {{- $__checkIntervalSec := include "base.int" .checkIntervalSec }}
    {{- if $__checkIntervalSec }}
      {{- nindent 0 "" -}}checkIntervalSec: {{ coalesce $__checkIntervalSec 5 }}
    {{- end }}

    {{- $__timeoutSec := include "base.int.scope" (list .timeoutSec 1 $__checkIntervalSec) }}
    {{- if $__timeoutSec }}
      {{- nindent 0 "" -}}timeoutSec: {{ $__timeoutSec }}
    {{- end }}

    {{- $__healthyThreshold := include "base.int" .healthyThreshold }}
    {{- if $__healthyThreshold }}
      {{- nindent 0 "" -}}healthyThreshold: {{ coalesce $__healthyThreshold 2 }}
    {{- end }}

    {{- $__unhealthyThreshold := include "base.int" .unhealthyThreshold }}
    {{- if $__unhealthyThreshold }}
      {{- nindent 0 "" -}}unhealthyThreshold: {{ coalesce $__unhealthyThreshold 2 }}
    {{- end }}

    {{- $__typeAllowed := list "HTTP" "HTTPS" "HTTP2" }}
    {{- $__type := include "base.string" .type }}
    {{- if mustHas $__type $__typeAllowed }}
      {{- nindent 0 "" -}}type: {{ $__type }}
    {{- end }}

    {{- $__requestPath := include "base.string" .requestPath }}
    {{- if isAbs $__requestPath }}
      {{- nindent 0 "" -}}requestPath: {{ coalesce $__requestPath "/" }}
    {{- end }}

    {{- $__port := include "base.int.scope" (list .port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- end }}
  {{- end }}
{{- end }}
