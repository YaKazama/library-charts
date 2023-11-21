{{- /*
  variables (priority):
  - ._CTX.annotations .Values.annotations
  variables (bool):
  - ._CTX.annotations.validOnly: 是否抑制 .Values.annotations 生效。不会出现在 annotations 中
    - true
    - false (默认值)
  reference:
  descr:
  - ._CTX.annotations .Values.annotations 会进行追加处理，但会覆盖相同 Key 的内容
*/ -}}
{{- define "base.annotations" -}}
  {{- $_ := set . "__baseAnnotations" dict }}
  {{- $_ := set . "__isValidOnly" false }}

    {{- range $k, $v := ._CTX.annotations }}
      {{- if eq $k "validOnly" }}
        {{- $_ := set . "__isValidOnly" $v }}
      {{- else }}
        {{- $_ := set .__baseAnnotations $k $v }}
      {{- end }}
    {{- end }}

    {{- if not .__isValidOnly }}
      {{- range $k, $v := .Values.annotations }}
        {{- $_ := set .__baseAnnotations $k $v }}
      {{- end }}
    {{- end }}

    {{- if .__baseAnnotations }}
      {{- range $k, $v := .__baseAnnotations }}
        {{- $k | nindent 0 }}: {{ $v }}
      {{- end }}
    {{- end }}

  {{- $_ := unset . "__isValidOnly" }}
  {{- $_ := unset . "__baseAnnotations" }}
{{- end }}
