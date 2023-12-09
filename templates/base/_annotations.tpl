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
  {{- $__annotations := dict }}
  {{- $__validOnly := false }}

  {{- if kindIs "map" ._CTX.annotations }}
    {{- $__validOnly = dig "validOnly" false ._CTX.annotations }}
    {{- $_ := mustMerge $__annotations (omit ._CTX.annotations "validOnly") }}
  {{- end }}
  {{- if kindIs "map" .Values.annotations }}
    {{- if not $__validOnly }}
      {{- $_ := mustMerge $__annotations (omit .Values.annotations "validOnly") }}
    {{- end }}
  {{- end }}

  {{- if $__annotations }}
    {{- /*
      for Secret
      type = kubernetes.io/service-account-token
    */ -}}
    {{- if eq ._kind "Secret" }}
      {{- if eq (coalesce ._CTX.type .Values.type) "kubernetes.io/service-account-token" }}
        {{- if or ._CTX.serviceAccountName .Values.serviceAccountName }}
          {{- $_ := set $__annotations "kubernetes.io/service-account.name" (coalesce ._CTX.serviceAccountName .Values.serviceAccountName "default") }}
        {{- else if not (get $__annotations "kubernetes.io/service-account.name") }}
          {{- fail "base.annotations: Secret.metadata.annotations[kubernetes.io/service-account.name] is required" }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- toYaml $__annotations | nindent 0 }}
  {{- end }}
{{- end }}
