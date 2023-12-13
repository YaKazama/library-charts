{{- define "configStorage.StorageClass" -}}
  {{- $_ := set . "_kind" "StorageClass" }}

  {{- nindent 0 "" -}}apiVersion: storage.k8s.io/v1
  {{- nindent 0 "" -}}kind: StorageClass
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- if or ._CTX.provisioner .Values.provisioner }}
    {{- nindent 0 "" -}}provisioner: {{ coalesce ._CTX.provisioner .Values.provisioner }}
  {{- else }}
    {{- fail "configStorage.StorageClass: provisioner not found" }}
  {{- end }}

  {{- if or ._CTX.parameters .Values.parameters }}
    {{- $__parameters := dict }}

    {{- if kindIs "map" ._CTX.parameters }}
      {{- $__parameters = mustMerge $__parameters ._CTX.parameters }}
    {{- end }}
    {{- if kindIs "map" .Values.parameters }}
      {{- $__parameters = mustMerge $__parameters .Values.parameters }}
    {{- end }}

    {{- if $__parameters }}
      {{- nindent 0 "" -}}parameters:
        {{- toYaml $__parameters | nindent 2 }}
    {{- else }}
      {{- fail "configStorage.StorageClass: parameters not found" }}
    {{- end }}
  {{- end }}

  {{- $__reclaimPlicyList := list "Retain" "Delete" }}
  {{- if or (mustHas ._CTX.reclaimPolicy $__reclaimPlicyList) (mustHas .Values.reclaimPolicy $__reclaimPlicyList) }}
    {{- nindent 0 "" -}}reclaimPolicy: {{ coalesce ._CTX.reclaimPolicy .Values.reclaimPolicy "Delete" }}
  {{- else }}
    {{- nindent 0 "" -}}reclaimPolicy: Delete
  {{- end }}

  {{- if or ._CTX.allowVolumeExpansion .Values.allowVolumeExpansion }}
    {{- nindent 0 "" -}}allowVolumeExpansion: true
  {{- end }}

  {{- if or ._CTX.mountOptions .Values.mountOptions }}
    {{- $__mountOptions := list }}

    {{- if ._CTX.mountOptions }}
      {{- if kindIs "string" ._CTX.mountOptions }}
        {{- range (mustRegexSplit "(,)?\\s+" ._CTX.mountOptions -1) }}
          {{- $__mountOptions = mustAppend $__mountOptions . }}
        {{- end }}
      {{- else if kindIs "slice" ._CTX.mountOptions }}
        {{- $__mountOptions = concat $__mountOptions ._CTX.mountOptions }}
      {{- else }}
        {{- fail "configStorage.StorageClass: mountOptions not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.mountOptions }}
      {{- if kindIs "string" .Values.mountOptions }}
        {{- range (mustRegexSplit "(,)?\\s+" .Values.mountOptions -1) }}
          {{- $__mountOptions = mustAppend $__mountOptions . }}
        {{- end }}
      {{- else if kindIs "slice" .Values.mountOptions }}
        {{- $__mountOptions = concat $__mountOptions .Values.mountOptions }}
      {{- else }}
        {{- fail "configStorage.StorageClass: mountOptions not support" }}
      {{- end }}
    {{- end }}

    {{- $__mountOptions = mustCompact (mustUniq $__mountOptions) }}
    {{- if $__mountOptions }}
      {{- nindent 0 "" -}}mountOptions:
      {{- toYaml $__mountOptions | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- $__volumeBindingModeList := list "Immediate" "WaitForFirstConsumer" }}
  {{- if or (mustHas ._CTX.volumeBindingMode $__volumeBindingModeList) (mustHas .Values.volumeBindingMode $__volumeBindingModeList) }}
    {{- nindent 0 "" -}}volumeBindingMode: {{ coalesce ._CTX.volumeBindingMode .Values.volumeBindingMode "Immediate" }}
  {{- end }}

  {{- if or ._CTX.allowedTopologies .Values.allowedTopologies }}
    {{- $__allowedTopologiesDict := dict }}

    {{- if ._CTX.allowedTopologies }}
      {{- if kindIs "map" ._CTX.allowedTopologies }}
        {{- $__allowedTopologiesDict = mustMerge $__allowedTopologiesDict ._CTX.allowedTopologies }}
      {{- else }}
        {{- fail "configStorage.StorageClass: .allowedTopologies not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.allowedTopologies }}
      {{- if kindIs "map" .Values.allowedTopologies }}
        {{- $__allowedTopologiesDict = mustMerge $__allowedTopologiesDict .Values.allowedTopologies }}
      {{- else }}
        {{- fail "configStorage.StorageClass: .Values.allowedTopologies not support" }}
      {{- end }}
    {{- end }}

    {{- $__allowedTopologies := include "definitions.TopologySelectorTerm" $__allowedTopologiesDict | fromYaml }}
    {{- if $__allowedTopologies }}
      {{- nindent 0 "" -}}allowedTopologies:
      {{- toYaml $__allowedTopologies | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
