{{- define "definitions.EnvFromSource" -}}
  {{- with . }}
    {{- $__configMapRef := include "definitions.ConfigMapEnvSource" .configMapRef | fromYaml }}
    {{- if $__configMapRef }}
      {{- nindent 0 "" -}}configMapRef:
        {{- toYaml $__configMapRef | nindent 2 }}
    {{- end }}

    {{- $__prefix := include "base.string" .prefix }}
    {{- if $__prefix }}
      {{- nindent 0 "" -}}prefix: {{ $__prefix }}
    {{- end }}

    {{- $__secretRef := include "definitions.SecretEnvSource" .secretRef | fromYaml }}
    {{- if $__secretRef }}
      {{- nindent 0 "" -}}secretRef:
        {{- toYaml $__secretRef | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
