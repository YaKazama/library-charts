{{- define "definitions.ObjectMeta" -}}
  {{- if eq ._kind "Namespace" }}
    {{- nindent 0 "" -}}name: {{ include "base.namespace" . }}
  {{- else }}
    {{- /*
      Secret 特殊处理
      参考: https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/#bootstrap-token-secrets
    */ -}}
    {{- $__secretName := "" }}
    {{- $__secretNS := "" }}
    {{- if eq ._kind "Secret" }}
      {{- $__tokenType := "bootstrap.kubernetes.io/token" }}
      {{- $__type := include "base.string" (coalesce .Context.type .Values.type "Opaque") }}
      {{- if eq $__type $__tokenType }}
        {{- $__stringDataSrc := pluck "stringData" .Context .Values }}
        {{- $__stringDataFilesSrc := pluck "stringDataFiles" .Context .Values }}
        {{- $__secretName = include "configStorage.Secret.getTokenID" (dict "dataSrc" $__stringDataSrc "dataFilesSrc" $__stringDataFilesSrc "Files" .Files) }}

        {{- $__dataSrc := pluck "data" .Context .Values }}
        {{- $__dataFilesSrc := pluck "dataFiles" .Context .Values }}
        {{- $__secretName = include "configStorage.Secret.getTokenID" (dict "dataSrc" $__dataSrc "dataFilesSrc" $__dataFilesSrc "Files" .Files) }}

        {{- if not $__secretName }}
          {{- fail "definitions.ObjectMeta: Secret secretName must be exists, please check token-id." }}
        {{- end }}
        {{- $__secretNS = "kube-system" }}
      {{- end }}
    {{- end }}

    {{- $__templateSpecAllowed := list "JobTemplateSpec" "PodTemplateSpec" }}
    {{- if not (mustHas ._kind $__templateSpecAllowed) }}
      {{- nindent 0 "" -}}name: {{ coalesce $__secretName .Context.nameAlias (include "base.fullname" .) }}
    {{- end }}

    {{- $__clusterResourceAllowed := list "ClusterRole" "ClusterRoleBinding" }}
    {{- if not (or (mustHas ._kind $__clusterResourceAllowed) (mustHas ._kind $__templateSpecAllowed)) }}
      {{- nindent 0 "" -}}namespace: {{ coalesce $__secretNS (include "base.namespace" .) }}

      {{- $__annotations := include "base.annotations" . }}
      {{- if $__annotations }}
        {{- nindent 0 "" -}}annotations:
          {{- $__annotations | indent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- /*
    variables:
    - ignoreLabels: 是否忽略 labels
      - 默认值为 false 表示不忽略
      - 在 kind = "Namespace" 时有效
  */ -}}
  {{- $__ignoreLabels := false }}
  {{- if eq ._kind "Namespace" }}
    {{- $__ignoreLabels := include "base.bool" (coalesce .Context.ignoreLabels .Values.ignoreLabels) }}
  {{- end }}
  {{- if not $__ignoreLabels }}
    {{- nindent 0 "" -}}labels:
      {{- include "base.labels" . | indent 2 }}
  {{- end }}
{{- end }}
