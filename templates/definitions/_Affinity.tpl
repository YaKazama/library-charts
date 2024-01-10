{{- define "definitions.Affinity" -}}
  {{- with . }}
    {{- if .nodeAffinity }}
      {{- $__nodeAffinity := include "definitions.NodeAffinity" .nodeAffinity }}
      {{- if $__nodeAffinity }}
        {{- nindent 0 "" -}}nodeAffinity:
          {{- $__nodeAffinity | indent 2 }}
      {{- end }}
    {{- end }}
    {{- if .podAffinity }}
      {{- $__podAffinity := include "definitions.PodAffinity" .podAffinity }}
      {{- if $__podAffinity }}
        {{- nindent 0 "" -}}podAffinity:
          {{- $__podAffinity | indent 2 }}
      {{- end }}
    {{- end }}
    {{- if .podAntiAffinity }}
      {{- $__podAntiAffinity := include "definitions.PodAntiAffinity" .podAntiAffinity }}
      {{- if $__podAntiAffinity }}
        {{- nindent 0 "" -}}podAntiAffinity:
          {{- $__podAntiAffinity | indent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
