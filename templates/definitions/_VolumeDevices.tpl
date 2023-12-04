{{- define "definitions.VolumeDevices" -}}
  {{- with . }}
    {{- if or .name }}
      {{- nindent 0 "" -}}name: {{ .name }}

      {{- if or .devicePath }}
        {{- nindent 0 "" -}}devicePath: {{ .devicePath }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
