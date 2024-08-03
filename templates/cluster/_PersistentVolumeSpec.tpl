{{- /*
  descr:
  - 有限支持
    - cephfs
    - fc
    - hostPath
    - nfs
    - rbd
*/ -}}
{{- define "cluster.PersistentVolumeSpec" -}}
  {{- with . }}
    {{- $__accessModesAllowed := list "ReadWriteOnce" "ReadOnlyMany" "ReadWriteMany" "ReadWriteOncePod" }}
    {{- $__regexCheck := "(ReadWriteOnce|ReadOnlyMany|ReadWriteMany|ReadWriteOncePod)" }}
    {{- $__accessModes := include "base.fmt.slice" (dict "s" (list .accessModes) "c" $__regexCheck) }}
    {{- if $__accessModes }}
      {{- nindent 0 "" -}}accessModes:
      {{- $__accessModes | nindent 0 }}
    {{- end }}

    {{- $__capacity := include "base.map" .capacity | fromYaml }}
    {{- if $__capacity }}
      {{- nindent 0 "" -}}capacity:
        {{- toYaml $__capacity | nindent 2 }}
    {{- end }}

    {{- $__regexSplit := "\\s+" }}
    {{- $__mountOptions := include "base.fmt.slice" (dict "s" (list .mountOptions) "r" $__regexSplit) }}
    {{- if $__mountOptions }}
      {{- nindent 0 "" -}}mountOptions:
      {{- $__mountOptions | nindent 0 }}
    {{- end }}

    {{- $__persistentVolumeReclaimPolicyAllowed := list "Retain" "Delete" }}
    {{- $__persistentVolumeReclaimPolicy := include "base.string" .persistentVolumeReclaimPolicy }}
    {{- if mustHas $__persistentVolumeReclaimPolicy $__persistentVolumeReclaimPolicyAllowed }}
      {{- nindent 0 "" -}}persistentVolumeReclaimPolicy: {{ $__persistentVolumeReclaimPolicy }}
    {{- end }}

    {{- $__storageClassName := include "base.string.empty" (dict "s" .storageClassName "empty" true) }}
    {{- if $__storageClassName }}
      {{- nindent 0 "" -}}storageClassName: {{ $__storageClassName }}
    {{- end }}

    {{- $__volumeModeAllowed := list "Filesystem" "Block" }}
    {{- $__volumeMode := include "base.string" .volumeMode }}
    {{- if mustHas $__volumeMode $__volumeModeAllowed }}
      {{- nindent 0 "" -}}volumeMode: {{ $__volumeMode }}
    {{- end }}

    {{- if .nodeAffinity }}
      {{- $__nodeAffinity := include "definitions.VolumeNodeAffinity" .nodeAffinity | fromYaml }}
      {{- if $__nodeAffinity }}
        {{- nindent 0 "" -}}nodeAffinity:
          {{- toYaml $__nodeAffinity | nindent 2 }}
      {{- end }}
    {{- end }}

    {{- if .cephfs }}
      {{- include "configStorage.Volume.VolumeSource" (dict "s" .cephfs "k" "cephfs" "define" "definitions.CephFSPersistentVolumeSource") | indent 0 }}
    {{- end }}

    {{- if .fc }}
      {{- include "configStorage.Volume.VolumeSource" (dict "s" .fc "k" "fc" "define" "definitions.FCVolumeSource") | indent 0 }}
    {{- end }}

    {{- if .hostPath }}
      {{- include "configStorage.Volume.VolumeSource" (dict "s" .hostPath "k" "hostPath" "define" "definitions.HostPathVolumeSource") | indent 0 }}
    {{- end }}

    {{- if .nfs }}
      {{- include "configStorage.Volume.VolumeSource" (dict "s" .nfs "k" "nfs" "define" "definitions.NFSVolumeSource") | indent 0 }}
    {{- end }}

    {{- if .rbd }}
      {{- include "configStorage.Volume.VolumeSource" (dict "s" .rbd "k" "rbd" "define" "definitions.RBDPersistentVolumeSource") | indent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
