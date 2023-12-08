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
  {{- $__baseAnnotations := dict }}
  {{- $__validOnly := false }}

  {{- if kindIs "map" ._CTX.annotations }}
    {{- $__validOnly = dig "validOnly" false ._CTX.annotations }}
    {{- $_ := mustMerge $__baseAnnotations (omit ._CTX.annotations "validOnly") }}
  {{- end }}

  {{- if kindIs "map" .Values.annotations }}
    {{- if not $__validOnly }}
      {{- $_ := mustMerge $__baseAnnotations (omit .Values.annotations "validOnly") }}
    {{- end }}
  {{- end }}

  {{- if $__baseAnnotations }}
    {{- range $k, $v := $__baseAnnotations }}
      {{- $k | nindent 0 }}: {{ $v }}
    {{- end }}
  {{- end }}
{{- end }}
