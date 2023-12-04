{{- /*
  variables (priority):
  - ._CTX.apiVersion
  - .Values.apiVersion
  reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#api-groups
  descr:
*/ -}}
{{- define "base.apiVersion" -}}
  {{- if or ._CTX.apiVersion .Values.apiVersion }}
    {{- coalesce ._CTX.apiVersion .Values.apiVersion }}
  {{- else }}
    {{- fail "apiVersion not found, please check the values.yaml" }}
  {{- end }}
{{- end }}


{{- /*
  variables (priority):
  - ._CTX.kind
  - .Values.kind
  reference: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#types-kinds
  descr:
*/ -}}
{{- define "base.kind" -}}
  {{- if or ._CTX.kind .Values.kind }}
    {{- coalesce ._CTX.kind .Values.kind }}
  {{- else }}
    {{- fail "kind not found, please check the values.yaml" }}
  {{- end }}
{{- end }}


{{- /*
  variables (priority):
  - ._CTX.name
  - .Values.name
  - .Chart.Name
  reference:
  descr:
*/ -}}
{{- define "base.name" -}}
  {{- if or ._CTX.name .Values.name .Chart.Name }}
    {{- coalesce ._CTX.name .Values.name .Chart.Name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- fail "name not found, please check the values.yaml or Chart.yaml" }}
  {{- end }}
{{- end }}


{{- /*
  variables (priority):
  - .Release.Name
  - ._CTX.fullname
  - .Values.fullname
  reference:
  descr:
  - .Release.Name 与 .fullname 存在包含关系。如果 .Release.Name 中包含 .fullname 的字符串，则使用 .Release.Name
  - .fullname 会覆盖 .name 的值
*/ -}}
{{- define "base.fullname" -}}
  {{- if or ._CTX.fullname .Values.fullname }}
    {{- coalesce ._CTX.fullname .Values.fullname | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $__baseName := include "base.name" . }}

    {{- if contains $__baseName .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- $__baseName | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  variables (priority):
  - .Chart.Name .Chart.Version
  reference:
  descr:
  - 优先级相同。格式：<.Chart.Name>-<.Chart.Version>
*/ -}}
{{- define "base.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- /*
  variables (priority):
  - ._CTX.namespace
  - .Values.namespace
  - "default" (默认值)
  reference: https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
  descr:
*/ -}}
{{- define "base.namespace" -}}
  {{- coalesce ._CTX.namespace .Values.namespace "default" }}
{{- end }}


{{- /*
  descr:
  - 传入的值必需为 Map 类型且包括 m 和 k 两个 Key
  - k 类型的值只能使用 . 号作为分隔符, 格式: a.b
*/ -}}
{{- define "base.map.getValue" -}}
  {{- $__keyList := mustRegexSplit "\\." .k -1 }}
  {{- $__keyCount := len $__keyList }}
  {{- $__firstKey := first $__keyList }}

  {{- if hasKey .m $__firstKey }}
    {{- if eq $__keyCount 1 }}
      {{- nindent 0 "" -}}{{- get .m $__firstKey | toYaml }}
    {{- else }}
      {{- include "base.map.getValue" (dict "m" (get .m $__firstKey) "k" (join "." (mustRest $__keyList))) }}
    {{- end }}
  {{- else }}
    {{- "" }}
  {{- end }}
{{- end }}
