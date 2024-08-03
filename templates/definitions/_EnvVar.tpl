{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#envvar-v1-core
*/ -}}
{{- define "definitions.EnvVar" -}}
  {{- with . }}
    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- end }}

    {{- $__value := include "base.string.zero" .value }}
    {{- if $__value }}
      {{- nindent 0 "" -}}value: {{ $__value | quote }}
    {{- else if and .valueFrom (empty $__value) }}
      {{- $__valueFrom := include "definitions.EnvVarSource" .valueFrom | fromYaml }}
      {{- if $__valueFrom }}
        {{- nindent 0 "" -}}valueFrom:
          {{- toYaml $__valueFrom | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
