{{- define "definitions.ObjectReference" -}}
  {{- with . }}
    {{- if .apiVersion }}
      {{- nindent 0 "" -}}apiVersion: {{ .apiVersion }}
    {{- end }}
    {{- if .kind }}
      {{- nindent 0 "" -}}kind: {{ .kind }}
    {{- end }}
    {{- if or .name .targetName }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- end }}
    {{- if .namespace }}
      {{- nindent 0 "" -}}namespace: {{ .namespace }}
    {{- end }}
    {{- if .fieldPath }}
      {{- nindent 0 "" -}}fieldPath: {{ .fieldPath }}
    {{- end }}
    {{- if .resourceVersion }}
      {{- nindent 0 "" -}}resourceVersion: {{ .resourceVersion }}
    {{- end }}
    {{- if or .uid .uuid }}
      {{- nindent 0 "" -}}uid: {{ coalesce .uid .uuid }}
    {{- end }}
  {{- end }}
{{- end }}
