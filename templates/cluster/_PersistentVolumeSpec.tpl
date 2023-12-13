{{- define "cluster.PersistentVolumeSpec" -}}
  {{- $__accessModesList := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}

  {{- if or ._CTX.accessModes .Values.accessModes }}
    {{- $__accessModes := list }}

    {{- if ._CTX.accessModes }}
      {{- if kindIs "slice" ._CTX.accessModes }}
        {{- range ._CTX.accessModes }}
          {{- if mustHas . $__accessModesList }}
            {{- $__accessModes = mustAppend $__accessModes . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" ._CTX.accessModes }}
        {{- if mustRegexMatch "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)((,)?\\s*)*" ._CTX.accessModes }}
          {{- range (mustRegexSplit "(,)?\\s+" ._CTX.accessModes -1) }}
            {{- $__accessModes = mustAppend $__accessModes . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "cluster.PersistentVolumeSpec: .accessModes not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.accessModes }}
      {{- if kindIs "slice" .Values.accessModes }}
        {{- range .Values.accessModes }}
          {{- if mustHas . $__accessModesList }}
            {{- $__accessModes = mustAppend $__accessModes . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" .Values.accessModes }}
        {{- if mustRegexMatch "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)((,)?\\s*)*" .Values.accessModes }}
          {{- range (mustRegexSplit "(,)?\\s+" .Values.accessModes -1) }}
            {{- $__accessModes = mustAppend $__accessModes . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "cluster.PersistentVolumeSpec: .accessModes not support" }}
      {{- end }}
    {{- end }}

    {{- $__accessModes = mustCompact (mustUniq $__accessModes) }}
    {{- if $__accessModes }}
      {{- nindent 0 "" -}}accessModes:
      {{- toYaml $__accessModes | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- if or (kindIs "string" ._CTX.storageClassName) (kindIs "string" .Values.storageClassName) }}
    {{- nindent 0 "" -}}storageClassName: {{ coalesce ._CTX.storageClassName .Values.storageClassName "" }}
  {{- end }}

  {{- $__volumeModeList := list "Filesystem" "Block" }}
  {{- if or (mustHas ._CTX.volumeMode $__volumeModeList) (mustHas .Values.volumeMode $__volumeModeList) }}
    {{- nindent 0 "" -}}volumeMode: {{ coalesce .volumeMode "Filesystem" }}
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

  {{- /*
    TODO: 半成品，暂无需求，此功能暂停开发 2023-12-13
  */ -}}
{{- end }}
