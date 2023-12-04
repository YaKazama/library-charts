{{- /*
  variables (priority):
  - .Values.annotations
  - ._CTX.annotations
    - ._CTX.annotations.validOnly: 是否抑制 .Values.annotations 生效。不会出现在 annotations 中
      - true
      - false (默认值)
  reference: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  descr:
  - 相同 Key 的内容会被覆盖
*/ -}}
{{- define "base.annotations" -}}
  {{- $_ := set . "__baseAnnotations" dict }}

    {{- range $k, $v := .Values.annotations }}
      {{- if not (eq $k "validOnly") }}
        {{- $_ := set $.__baseAnnotations $k $v }}
      {{- end }}
    {{- end }}

    {{- range $k, $v := ._CTX.annotations }}
      {{- if not (eq $k "validOnly") }}
        {{- $_ := set $.__baseAnnotations $k $v }}
      {{- end }}
    {{- end }}

    {{- if .__baseAnnotations }}
      {{- range $k, $v := .__baseAnnotations }}
        {{- $k | nindent 0 }}: {{ $v }}
      {{- end }}
    {{- end }}

  {{- $_ := unset . "__baseAnnotations" }}
{{- end }}
