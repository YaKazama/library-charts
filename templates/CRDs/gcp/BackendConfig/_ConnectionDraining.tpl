{{- define "crds.gcp.BackendConfig.ConnectionDraining" -}}
  {{- with . }}
  {{- $__drainingTimeoutSec := include "base.int.scope" (list (include "base.int.zero" (list .drainingTimeoutSec) | int) 0 3600) }}
  {{- if $__drainingTimeoutSec }}
    {{- nindent 0 "" -}}drainingTimeoutSec: {{ $__drainingTimeoutSec }}
  {{- end }}
  {{- end }}
{{- end }}
