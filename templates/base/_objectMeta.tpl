{{- /*
  variables (priority):
  - base.namespace
    - 创建以下资源时忽略此配置
      - Namespace
      - ClusterRole
      - ClusterRoleBinding
      - JobTemplateSpec
      - PodTemplateSpec
  - base.fullname
  - base.annotations
  - base.labels
  reference:
  descr:
*/ -}}
{{- define "base.ObjectMeta" -}}
  {{- if eq ._kind "Namespace" }}
    {{- -}}name: {{ include "base.namespace" . }}
  {{- else }}
    {{- $_ := set .__clusterResourceList "ClusterRole" "ClusterRoleBinding" }}
    {{- $_ := set .__templateSpecList "JobTemplateSpec" "PodTemplateSpec" }}

    {{- if not (or (has ._kind .__clusterResourceList) (has ._kind .__templateSpecList)) }}
      {{- -}}namespace: {{ include "base.namespace" . }}
    {{- end }}

    {{- if not (has ._kind .__templateSpecList) }}
      {{- -}}name: {{ include "base.fullname" . }}
    {{- end }}

    {{- -}}annotations:
      {{- include "base.annotations" . | nindent 2 }}

    {{- -}}labels:
      {{- include "base.labels" . | nindent 2 }}

    {{- $_ := unset . "__templateSpecList" }}
    {{- $_ := unset . "__clusterResourceList" }}
  {{- end }}
{{- end }}
