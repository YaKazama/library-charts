{{- define "configStorage.PersistentVolumeClaim" -}}
  {{- $_ := set . "_kind" "PersistentVolumeClaim" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__clean := dict }}
  {{- $__persistentVolumeSrc := list .Context .Context.spec .Context.persistentVolumeClaim .Values .Values.spec .Values.persistentVolumeClaim }}
  {{- range ($__persistentVolumeSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__spec := include "configStorage.PersistentVolumeClaimSpec" $__clean | fromYaml }}
  {{- if $__spec }}
    {{- nindent 0 "" -}}spec:
      {{- toYaml $__spec | nindent 2 }}
  {{- end }}
{{- end }}


{{- define "configStorage.PersistentVolumeClaim.StatefulSet" -}}
  {{- with . }}
    {{- $__name := include "base.string" .name }}
    {{- if $__name }}
      {{- nindent 0 "" -}}metadata:
        {{- nindent 2 "" -}}name: {{ $__name }}
    {{- else }}
      {{- fail "configStorage.PersistentVolumeClaim.StatefulSet: name must be exists" }}
    {{- end }}

    {{- $__accessModesAllowed := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}
    {{- $__regexAccessModesCheck := "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)" }}
    {{- $__accessModes := include "base.fmt.slice" (dict "s" (list .accessModes) "c" $__regexAccessModesCheck) }}
    {{- $__storageClassName := include "base.string.empty" (dict "s" .storageClassName "empty" true) }}
    {{- $__size := include "definitions.Quantity" .size }}
    {{- $__storage := include "definitions.Quantity" .storage }}
    {{- if and $__accessModes $__storageClassName (or $__size $__storage) }}
      {{- nindent 0 "" -}}spec:
        {{- if $__accessModes }}
          {{- nindent 2 "" -}}accessModes:
          {{- $__accessModes | nindent 2 }}
        {{- end }}

        {{- if $__storageClassName }}
          {{- nindent 2 "" -}}storageClassName: {{ $__storageClassName }}
        {{- end }}

        {{- if or $__size $__storage }}
          {{- nindent 2 "" -}}resources:
            {{- nindent 4 "" -}}requests:
              {{- nindent 6 "" -}}storage: {{ coalesce $__storage $__size "1Gi" }}
        {{- end }}
    {{- else }}
      {{- fail "configStorage.PersistentVolumeClaim.StatefulSet: accessModes storageClassName storage (size) must be exists" }}
    {{- end }}
  {{- end }}
{{- end }}
