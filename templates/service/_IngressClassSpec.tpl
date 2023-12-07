{{- define "service.IngressClassSpec" -}}
  {{- if or ._CTX.controller .Values.controller }}
    {{- nindent 0 "" -}}controller: {{ coalesce ._CTX.controller .Values.controller }}
  {{- end }}

  {{- if or ._CTX.parameters .Values.parameters }}
    {{- $__parametersDict := dict }}

    {{- if ._CTX.parameters }}
      {{- $__parametersDict = mustMerge $__parametersDict ._CTX.parameters }}
    {{- end }}
    {{- if .Values.parameters }}
      {{- $__parametersDict = mustMerge $__parametersDict .Values.parameters }}
    {{- end }}

    {{- $__parameters := include "definitions.IngressClassParametersReference" $__parametersDict | fromYaml }}
    {{- if $__parameters }}
      {{- nindent 0 "" -}}parameters:
        {{- toYaml $__parameters | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
