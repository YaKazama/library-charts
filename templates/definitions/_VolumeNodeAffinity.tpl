{{- define "definitions.VolumeNodeAffinity" -}}
  {{- with . }}
    {{- if .required }}
      {{- if or (kindIs "slice" .required) (kindIs "map" .required) }}
        {{- $__required := include "definitions.NodeSelector" .required }}
        {{- if $__required }}
          {{- nindent 0 "" -}}required:
            {{- $__required | indent 2 }}
        {{- end }}
      {{- else }}
        {{- fail "definitions.VolumeNodeAffinity: required not support, please use slice or map" }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
