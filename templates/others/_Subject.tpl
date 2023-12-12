{{- define "others.Subject.v1" -}}
  {{- $__kindList := list "User" "Group" "ServiceAccount" }}

  {{- with . }}
    {{- if and (mustHas .kind $__kindList) (not (eq .kind "ServiceAccount")) }}
      {{- nindent 0 "" -}}apiGroup: {{ .apiGroup }}
    {{- end }}

    {{- if mustHas .kind $__kindList }}
      {{- nindent 0 "" -}}kind: {{ .kind }}
    {{- else }}
      {{- fail "others.Subject.v1: .kind not support" }}
    {{- end }}

    {{- if .name }}
      {{- nindent 0 "" -}}name: {{ .name }}
    {{- else }}
      {{- fail "others.Subject.v1: .name not found" }}
    {{- end }}

    {{- if .namespace }}
      {{- nindent 0 "" -}}namespace: {{ .namespace }}
    {{- end }}
  {{- end }}
{{- end }}
