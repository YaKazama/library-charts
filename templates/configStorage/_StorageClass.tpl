{{- define "configStorage.StorageClass" -}}
  {{- $_ := set . "_kind" "StorageClass" }}

  {{- nindent 0 "" -}}apiVersion: storage.k8s.io/v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__allowVolumeExpansion := include "base.bool" (coalesce .Context.allowVolumeExpansion .Values.allowVolumeExpansion) }}
  {{- if $__allowVolumeExpansion }}
    {{- nindent 0 "" -}}allowVolumeExpansion: {{ $__allowVolumeExpansion }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__allowedTopologiesSrc := pluck "allowedTopologies" .Context .Values }}
  {{- range ($__allowedTopologiesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__allowedTopologies := list }}
  {{- range ($__clean | mustUniq | mustCompact) }}
    {{- $__allowedTopologies = mustAppend $__allowedTopologies (include "definitions.TopologySelectorTerm" . | fromYaml) }}
  {{- end }}
  {{- $__allowedTopologies = $__allowedTopologies | mustUniq | mustCompact }}
  {{- if $__allowedTopologies }}
    {{- nindent 0 "" -}}allowedTopologies:
    {{- toYaml $__allowedTopologies | nindent 0 }}
  {{- end }}

  {{- $__mountOptionsSrc := pluck "mountOptions" .Context .Values }}
  {{- $__mountOptions := include "base.fmt.slice" (dict "s" $__mountOptionsSrc) }}
  {{- if $__mountOptions }}
    {{- nindent 0 "" -}}mountOptions:
    {{- $__mountOptions | nindent 0 }}
  {{- else }}
    {{- fail "configStorage.StorageClass: mountOptions not found" }}
  {{- end }}

  {{- $__parameters := dict }}
  {{- $__parametersSrc := pluck "parameters" .Context .Values }}
  {{- range ($__parametersSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__parameters = mustMerge $__parameters . }}
    {{- end }}
  {{- end }}
  {{- if $__parameters }}
    {{- nindent 0 "" -}}parameters:
      {{- toYaml $__parameters | nindent 2 }}
  {{- else }}
    {{- fail "configStorage.StorageClass: parameters not found" }}
  {{- end }}

  {{- $__provisioner := include "base.string" (coalesce .Context.provisioner .Values.provisioner) }}
  {{- if $__provisioner }}
    {{- nindent 0 "" -}}provisioner: {{ $__provisioner }}
  {{- end }}

  {{- $__reclaimPlicyAllowed := list "Retain" "Delete" }}
  {{- $__reclaimPolicy := include "base.string" (coalesce .Context.reclaimPolicy .Values.reclaimPolicy) }}
  {{- if mustHas $__reclaimPolicy $__reclaimPlicyAllowed }}
    {{- nindent 0 "" -}}reclaimPolicy: {{ coalesce $__reclaimPolicy "Delete" }}
  {{- end }}

  {{- $__volumeBindingModeAllowed := list "Immediate" "WaitForFirstConsumer" }}
  {{- $__volumeBindingMode := include "base.string" (coalesce .Context.volumeBindingMode .Values.volumeBindingMode) }}
  {{- if mustHas $__volumeBindingMode $__volumeBindingModeAllowed }}
    {{- nindent 0 "" -}}volumeBindingMode: {{ coalesce $__volumeBindingMode "Immediate" }}
  {{- end }}
{{- end }}
