{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#toleration-v1-core
  - https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
*/ -}}
{{- define "definitions.Toleration" -}}
  {{- $__effectAllowed := list "NoSchedule" "PreferNoSchedule" "NoExecute" }}
  {{- $__operatorAllowed := list "Exists" "Equal" }}

  {{- with . }}
    {{- $__effect := include "base.string" .effect }}
    {{- if mustHas $__effect $__effectAllowed }}
      {{- nindent 0 "" -}}effect: {{ $__effect }}
    {{- end }}

    {{- $__key := include "base.string" .key }}
    {{- if $__key }}
      {{- nindent 0 "" -}}key: {{ $__key }}
    {{- end }}

    {{- $__operator := include "base.string" .operator }}
    {{- if mustHas $__operator $__operatorAllowed }}
      {{- if not $__key }}
        {{- $__operator = "Exists" }}
      {{- end }}
      {{- nindent 0 "" -}}operator: {{ coalesce $__operator "Equal" }}
    {{- end }}

    {{- $__tolerationSeconds := include "base.int.zero" (.tolerationSeconds | list) }}
    {{- if and $__tolerationSeconds (eq $__effect "NoExecute") }}
      {{- nindent 0 "" -}}tolerationSeconds: {{ $__tolerationSeconds }}
    {{- end }}

    {{- $__value := include "base.string" .value }}
    {{- if and $__value (not (eq $__operator "Exists")) }}
      {{- nindent 0 "" -}}value: {{ $__value }}
    {{- end }}
  {{- end }}
{{- end }}
