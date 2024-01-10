{{- /*
  此处没有对标签键和值进行正则判断，需用户自行遵守

  descr:
  - 如果用户传入的键值对中存在 name 这个键，则会覆盖默认值（固定的 name 标签）
  reference:
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/labels/
*/ -}}
{{- define "base.labels" -}}
  {{- $__labels := dict }}

  {{- /*
    添加固定 Labels
    descr:
    - 当 ._kind = "Namespace" 时，默认的 name 标签令依次调用 base.namespace, base.fullname
  */ -}}
  {{- if eq ._kind "Namespace" }}
    {{- $_ := set $__labels "name" (coalesce (include "base.namespace" .) (include "base.fullname" .)) }}
  {{- else }}
    {{- $_ := set $__labels "name" (include "base.fullname" .) }}
  {{- end }}

  {{- /*
    处理用户传入。键 name 的值会覆盖默认的值
  */ -}}
  {{- $__labelsSrc := pluck "labels" .Context .Values }}
  {{- range $__labelsSrc | mustUniq | mustCompact }}
    {{- if kindIs "map" . }}
      {{- $__labels = mustMerge $__labels . }}
    {{- end }}
  {{- end }}

  {{- /*
    添加 HELM 相关的 Labels
    会覆盖已出现的同名 Key 的内容
  */ -}}
  {{- if or .Context.helmLabels .Values.helmLabels }}
    {{- $_ := set $__labels "helm.sh/chart" (include "base.chart" .) }}
    {{- $_ := set $__labels "app.kubernetes.io/version" .Chart.AppVersion }}
    {{- $_ := set $__labels "app.kubernetes.io/managed-by" .Release.Service }}
  {{- end }}

  {{- if $__labels }}
    {{- toYaml $__labels | nindent 0 }}
  {{- end }}
{{- end }}
