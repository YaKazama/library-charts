{{- define "configStorage.ConfigMap" -}}
  {{- $_ := set . "_kind" "ConfigMap" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__immutable := include "base.bool" (coalesce .Context.immutable .Values.immutable) }}
  {{- if $__immutable }}
    {{- nindent 0 "" -}}immutable: {{ $__immutable }}
  {{- end }}

  {{- /*
    for binaryData and data
  */ -}}
  {{- $__binaryDataSrc := pluck "binaryData" .Context .Values }}
  {{- $__binaryDataFilesSrc := pluck "binaryDataFiles" .Context .Values }}
  {{- $__binaryData := include "configStorage.ConfigMap.data.parser" (dict "dataSrc" $__binaryDataSrc "dataFilesSrc" $__binaryDataFilesSrc "key" "binaryData" "Files" .Files) | fromYaml }}
  {{- if $__binaryData }}
    {{- toYaml $__binaryData | nindent 0 }}
  {{- end }}

  {{- $__dataSrc := pluck "data" .Context .Values }}
  {{- $__dataFilesSrc := pluck "dataFiles" .Context .Values }}
  {{- $__data := include "configStorage.ConfigMap.data.parser" (dict "dataSrc" $__dataSrc "dataFilesSrc" $__dataFilesSrc "key" "data" "Files" .Files) | fromYaml }}
  {{- if $__data }}
    {{- toYaml $__data | nindent 0 }}
  {{- end }}
{{- end }}


{{- /*
  解析 data binaryData
  variables:
  - dataSrc: slice of data or binaryData
  - dataFilesSrc: slice of dataFiles or binaryDataFiles
  - key: one of keywords: data or binaryData
  - Files: $.Files
  descr:
  - 优先级
    - data > dataFiles
    - binaryData > binaryDataFiles
*/ -}}
{{- define "configStorage.ConfigMap.data.parser" -}}
  {{- with . }}
    {{- $__data := dict }}
    {{- range .dataSrc | mustUniq | mustCompact }}
      {{- if kindIs "map" . }}
        {{- $__data = mustMerge $__data . }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "map" . }}
            {{- $__data = mustMerge $__data . }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- $__dataFiles := dict }}
    {{- range .dataFilesSrc | mustUniq | mustCompact }}
      {{- if kindIs "map" . }}
        {{- range $f, $p := . }}
          {{- $__dataFiles = mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "map" . }}
            {{- range $f, $p := . }}
              {{- $__dataFiles = mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
            {{- end }}
          {{- else if kindIs "string" . }}
            {{- $__dataFiles = mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" . }}
        {{- $__dataFiles = mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- end }}

    {{- if or $__data $__dataFiles }}
      {{- nindent 0 "" -}}{{ .key }}:
      {{- if eq .key "binaryData" }}
        {{- range $k, $v := $__data }}
          {{- $k | nindent 2 }}: {{ toString $v | b64enc }}
        {{- end }}
        {{- range $k, $v := $__dataFiles }}
          {{- $k | nindent 2 }}: |
            {{- $v | b64enc | nindent 4 }}
        {{- end }}
      {{- else if eq .key "data" }}
        {{- range $k, $v := $__data }}
          {{- $k | nindent 2 }}: {{ toString $v }}
        {{- end }}
        {{- range $k, $v := $__dataFiles }}
          {{- $k | nindent 2 }}: |
            {{- $v | nindent 4 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
