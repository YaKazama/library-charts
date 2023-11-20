{{- /*
  可用值:
  - .Values.apiVersion
  - ._ctx.apiVersion
  优先级: ._ctx.apiVersion > .Values.apiVersion
  参考: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#api-groups
  备注:
*/ -}}
{{- define "base.apiVersion" -}}
  {{- if or ._ctx.apiVersion .Values.apiVersion }}
    {{- coalesce ._ctx.apiVersion .Values.apiVersion }}
  {{- else }}
    {{- fail "apiVersion not found, please check the values.yaml" }}
  {{- end }}
{{- end }}


{{- /*
  可用值:
  - .Values.kind
  - ._ctx.kind
  优先级: ._ctx.kind > .Values.kind
  参考:
  备注:
*/ -}}
{{- define "base.kind" -}}
  {{- if or ._ctx.kind .Values.kind }}
    {{- coalesce ._ctx.kind .Values.kind }}
  {{- else }}
    {{- fail "kind not found, please check the values.yaml" }}
  {{- end }}
{{- end }}


{{- /*
  可用值:
  - .Values.name
  - ._CTX.name
  - .Chart.Name
  优先级: ._CTX.name > .Values.name > .Chart.Name
  参考:
  备注:
*/ -}}
{{- define "base.name" -}}
  {{- if or ._CTX.name .Values.name .Chart.Name }}
    {{- coalesce ._CTX.name .Values.name .Chart.Name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- fail "name not found, please check the values.yaml or Chart.yaml" }}
  {{- end }}
{{- end }}


{{- /*
  可用值:
  - .Values.fullname
  - ._CTX.fullname
  - .Release.Name
  优先级: .Release.Name > ._CTX.fullname > .Values.fullname
  参考:
  备注:
  - .Release.Name 与 .fullname 存在包含关系，如果 .Release.Name 中包含 .fullname 的字符串，则使用 .Release.Name
  - .fullname 会覆盖 .name 的值
*/ -}}
{{- define "base.fullname" -}}
  {{- if or ._CTX.fullname .Values.fullname }}
    {{- coalesce ._CTX.fullname .Values.fullname | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $_ := set . "_baseName" (include "base.name" .) }}

    {{- if contains ._baseName .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- ._baseName | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}


{{- /*
  可用值: .Chart.Name .Chart.Version
  优先级:
  参考:
  备注:
*/ -}}
{{- define "base.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{- /*
  可用值:
  - ._CTX.namespace
  - .Values.namespace
  - "default" (默认值)
  优先级: ._CTX.namespace > .Values.namespace > "default"
  参考:
  备注:
*/ -}}
{{- define "base.namespace" -}}
  {{- coalesce ._CTX.namespace .Values.namespace "default" }}
{{- end }}
