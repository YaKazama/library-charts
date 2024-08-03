{{- define "base.annotations" -}}
  {{- $__clean := dict }}
  {{- $__validOnly := false }}

  {{- /*
    清洗 validOnly 变量
  */ -}}
  {{- if kindIs "map" .Context.annotations }}
    {{- $__validOnly = dig "validOnly" false .Context.annotations }}
    {{- $__clean = mustMerge $__clean (omit .Context.annotations "validOnly") }}
  {{- end }}
  {{- if kindIs "map" .Values.annotations }}
    {{- /*
      当 .Context.annotations.validOnly = true 时，抑制 .Values.annotations
    */ -}}
    {{- if not $__validOnly }}
      {{- $__clean = mustMerge $__clean (omit .Values.annotations "validOnly") }}
    {{- end }}
  {{- end }}

  {{- if $__clean }}
    {{- /*
      for Secret
      type = kubernetes.io/service-account-token
    */ -}}
    {{- if eq ._kind "Secret" }}
      {{- if eq (coalesce .Context.type .Values.type) "kubernetes.io/service-account-token" }}
        {{- if or .Context.serviceAccountName .Values.serviceAccountName }}
          {{- $_ := set $__clean "kubernetes.io/service-account.name" (coalesce .Context.serviceAccountName .Values.serviceAccountName "default") }}
        {{- else if not (get $__clean "kubernetes.io/service-account.name") }}
          {{- fail "base.annotations: Secret.metadata.annotations[kubernetes.io/service-account.name] is required" }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- toYaml $__clean | nindent 0 }}
  {{- end }}
{{- end }}
