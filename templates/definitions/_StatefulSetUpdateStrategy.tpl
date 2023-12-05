{{- define "definitions.StatefulSetUpdateStrategy" -}}
  {{- $__typeList := list "RollingUpdate" }}

  {{- with . }}
    {{- if mustHas .type $__typeList }}
      {{- nindent 0 "" -}}type: {{ default "RollingUpdate" .type }}

      {{- if and (eq .type "RollingUpdate") .rollingUpdate }}
        {{- $__rollingUpdate := include "definitions.RollingUpdateStatefulSetStrategy" .rollingUpdate }}
        {{- if $__rollingUpdate }}
          {{- nindent 0 "" -}}rollingUpdate:
            {{- $__rollingUpdate | indent 2 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
