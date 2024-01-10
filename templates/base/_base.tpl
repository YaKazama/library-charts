{{- define "base.apiVersion" -}}
  {{- coalesce .Context.apiVersion .Values.apiVersion }}
{{- end }}


{{- define "base.kind" -}}
  {{- coalesce .Context.kind .Values.kind }}
{{- end }}


{{- /*
  name: 对象名称

  descr:
  - 此处遵循 RFC 1035
  reference:
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/names/
*/ -}}
{{- define "base.name" -}}
  {{- $__regexRFC1035 := "^([a-z]{1,63}|[a-z][a-z0-9-]{0,61}[a-z0-9])$" }}

  {{- $__name := include "base.toa" (coalesce .Context.Name .Values.Name .Chart.Name) }}

  {{- coalesce (include "base.fmt" (dict "s" (kebabcase $__name | lower) "r" $__regexRFC1035)) | nospace | trimSuffix "-" }}
{{- end }}


{{- /*
  fullname: 完整的对象名称，设置后可以替换 name 参数的值

  descr:
  - 此处遵循 RFC 1035
  - 优先级: fullname > name
  reference:
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/names/
*/ -}}
{{- define "base.fullname" -}}
  {{- $__regexRFC1035 := "^([a-z]{1,63}|[a-z][a-z0-9-]{0,61}[a-z0-9])$" }}

  {{- $__fullname := include "base.toa" (coalesce .Context.fullname .Values.fullname) }}

  {{- if not $__fullname }}
    {{- $__fullname = include "base.name" . }}
  {{- end }}

  {{- if contains $__fullname .Release.Name }}
    {{- $__fullname = include "base.toa" .Release.Name }}
  {{- end }}

  {{- coalesce (include "base.fmt" (dict "s" (kebabcase $__fullname | lower) "r" $__regexRFC1035)) "" | nospace | trimSuffix "-" }}
{{- end }}


{{- /*
  namespace: K8S 命名空间

  descr:
  - 需要符合 RFC 1123
  reference:
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/namespaces/
  - https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/names/#dns-label-names
*/ -}}
{{- define "base.namespace" -}}
  {{- $__regexRFC1123 := "^([a-z0-9]{1,63}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])$" }}

  {{- $__ns := include "base.toa" (coalesce .Context.namespace .Values.namespace) }}

  {{- coalesce (include "base.fmt" (dict "s" (kebabcase $__ns | lower) "r" $__regexRFC1123)) "default" | nospace | trimSuffix "-" }}
{{- end }}


{{- define "base.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}
