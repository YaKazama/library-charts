{{- define "definitions.Affinity" -}}
  {{- with . }}
    {{- if .nodeAffinity }}
      {{- $__nodeAffinity := include "definitions.NodeAffinity" .nodeAffinity | fromYaml }}
      {{- if $__nodeAffinity }}
        {{- nindent 0 "" -}}nodeAffinity:
          {{- toYaml $__nodeAffinity | nindent 2 }}
      {{- end }}
    {{- end }}
    {{- if .podAffinity }}
      {{- $__podAffinity := include "definitions.PodAffinity" .podAffinity | fromYaml }}
      {{- if $__podAffinity }}
        {{- nindent 0 "" -}}podAffinity:
          {{- toYaml $__podAffinity | nindent 2 }}
      {{- end }}
    {{- end }}
    {{- if .podAntiAffinity }}
      {{- $__podAntiAffinity := include "definitions.PodAntiAffinity" .podAntiAffinity | fromYaml }}
      {{- if $__podAntiAffinity }}
        {{- nindent 0 "" -}}podAntiAffinity:
          {{- toYaml $__podAntiAffinity | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
