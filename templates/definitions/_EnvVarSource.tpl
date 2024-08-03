{{- define "definitions.EnvVarSource" -}}
  {{- with . }}
    {{- $__configMapKeyRef := include "definitions.ConfigMapKeySelector" .configMapKeyRef | fromYaml }}
    {{- if $__configMapKeyRef }}
      {{- nindent 0 "" -}}configMapKeyRef:
        {{- toYaml $__configMapKeyRef | nindent 2 }}
    {{- end }}

    {{- $__fieldRef := include "definitions.ObjectFieldSelector" .fieldRef | fromYaml }}
    {{- if $__fieldRef }}
      {{- nindent 0 "" -}}fieldRef:
        {{- toYaml $__fieldRef | nindent 2 }}
    {{- end }}

    {{- $__resourceFieldRef := include "definitions.ResourceFieldSelector" .resourceFieldRef | fromYaml }}
    {{- if $__resourceFieldRef }}
      {{- nindent 0 "" -}}resourceFieldRef:
        {{- toYaml $__resourceFieldRef | nindent 2 }}
    {{- end }}

    {{- $__secretKeyRef := include "definitions.SecretKeySelector" .secretKeyRef | fromYaml }}
    {{- if $__secretKeyRef }}
      {{- nindent 0 "" -}}secretKeyRef:
        {{- toYaml $__secretKeyRef | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
