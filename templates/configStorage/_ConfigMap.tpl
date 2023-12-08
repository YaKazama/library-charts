{{- define "configStorage.ConfigMap" -}}
  {{- $_ := set . "_kind" "ConfigMap" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: ConfigMap
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or (and ._CTX.immutable (kindIs "bool" ._CTX.immutable)) (and .Values.immutable (kindIs "bool" .Values.immutable)) }}
    {{- nindent 0 "" -}}immutable: true
  {{- end }}

  {{- /*
    for binaryData
  */ -}}
  {{- if or ._CTX.binaryData .Values.binaryData ._CTX.binaryDataFiles .Values.binaryDataFiles }}
    {{- $__binaryData := dict }}
    {{- $__binaryDataFiles := dict }}

    {{- if ._CTX.binaryData }}
      {{- $__binaryData = mustMerge $__binaryData ._CTX.binaryData }}
    {{- end }}
    {{- if .Values.binaryData }}
      {{- $__binaryData = mustMerge $__binaryData .Values.binaryData }}
    {{- end }}

    {{- if ._CTX.binaryDataFiles }}
      {{- if kindIs "slice" ._CTX.binaryDataFiles }}
        {{- range ._CTX.binaryDataFiles }}
          {{- $_ := mustMerge $__binaryDataFiles (dict (base .) ($.Files.Get .)) }}
        {{- end }}
      {{- else if kindIs "map" ._CTX.binaryDataFiles }}
        {{- range $f, $p := ._CTX.binaryDataFiles }}
          {{- $_ := mustMerge $__binaryDataFiles (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if .Values.binaryDataFiles }}
      {{- if kindIs "slice" .Values.binaryDataFiles }}
        {{- range .Values.binaryDataFiles }}
          {{- $_ := mustMerge $__binaryDataFiles (dict (base .) ($.Files.Get .)) }}
        {{- end }}
      {{- else if kindIs "map" .Values.binaryDataFiles }}
        {{- range $f, $p := .Values.binaryDataFiles }}
          {{- $_ := mustMerge $__binaryDataFiles (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if or $__binaryData $__binaryDataFiles }}
      {{- nindent 0 "" -}}binaryData:
      {{- range $k, $v := $__binaryData }}
        {{- $k | nindent 2 }}: {{ $v | b64enc | quote }}
      {{- end }}
      {{- range $k, $v := $__binaryDataFiles }}
        {{- $k | nindent 2 }}: |
          {{- $v | b64enc | quote | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- /*
    for data
  */ -}}
  {{- if or ._CTX.data .Values.data ._CTX.dataFiles .Values.dataFiles }}
    {{- $__data := dict }}
    {{- $__dataFiles := dict }}

    {{- if ._CTX.data }}
      {{- $__data = mustMerge $__data ._CTX.data }}
    {{- end }}
    {{- if .Values.data }}
      {{- $__data = mustMerge $__data .Values.data }}
    {{- end }}

    {{- if ._CTX.dataFiles }}
      {{- if kindIs "slice" ._CTX.dataFiles }}
        {{- range ._CTX.dataFiles }}
          {{- $_ := mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
        {{- end }}
      {{- else if kindIs "map" ._CTX.dataFiles }}
        {{- range $f, $p := ._CTX.dataFiles }}
          {{- $_ := mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if .Values.dataFiles }}
      {{- if kindIs "slice" .Values.dataFiles }}
        {{- range .Values.dataFiles }}
          {{- $_ := mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
        {{- end }}
      {{- else if kindIs "map" .Values.dataFiles }}
        {{- range $f, $p := .Values.dataFiles }}
          {{- $_ := mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if or $__data $__dataFiles }}
      {{- nindent 0 "" -}}data:
      {{- range $k, $v := $__data }}
        {{- $k | nindent 2 }}: {{ $v | quote }}
      {{- end }}
      {{- range $k, $v := $__dataFiles }}
        {{- $k | nindent 2 }}: |
          {{- $v | nindent 4 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
