{{- /*
  variables (priority):
  - base.namespace
    - 创建以下资源时忽略此配置
      - Namespace
      - ClusterRole
      - ClusterRoleBinding
      - JobTemplateSpec
      - PodTemplateSpec
  - ._CTX.nameAlias: 用于替换 base.fullname 的值
  - base.fullname
  - base.annotations
    - 创建以下资源时忽略此配置
      - Namespace
      - ClusterRole
      - ClusterRoleBinding
      - JobTemplateSpec
      - PodTemplateSpec
  - base.labels
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#objectmeta-v1-meta
  descr:
*/ -}}
{{- define "definitions.ObjectMeta" -}}
  {{- if eq ._kind "Namespace" }}
    {{- nindent 0 "" -}}name: {{ kebabcase (include "base.namespace" .) | lower }}
  {{- else }}
    {{- $__clusterResourceList := list "ClusterRole" "ClusterRoleBinding" }}
    {{- $__templateSpecList := list "JobTemplateSpec" "PodTemplateSpec" }}
    {{- $__secretName := "" }}
    {{- $__secretNS := "" }}

    {{- if eq ._kind "Secret" }}
      {{- if eq (coalesce ._CTX.type .Values.type) "bootstrap.kubernetes.io/token" }}
        {{- $__secretName = include "definitions.Secret.getTokenID" . }}
        {{- $__secretNS = "kube-system" }}
      {{- end }}
    {{- end }}

    {{- if not (or (has ._kind $__clusterResourceList) (has ._kind $__templateSpecList)) }}
      {{- nindent 0 "" -}}namespace: {{ coalesce $__secretNS (kebabcase (include "base.namespace" .) | lower) }}
    {{- end }}

    {{- if not (has ._kind $__templateSpecList) }}
      {{- nindent 0 "" -}}name: {{ coalesce $__secretName (kebabcase (coalesce ._CTX.nameAlias (include "base.fullname" .)) | lower) }}
    {{- end }}

    {{- if not (or (has ._kind $__clusterResourceList) (has ._kind $__templateSpecList)) }}
      {{- nindent 0 "" -}}annotations:
        {{- include "base.annotations" . | indent 2 }}
    {{- end }}

    {{- nindent 0 "" -}}labels:
      {{- include "base.labels" . | indent 2 }}
  {{- end }}
{{- end }}
