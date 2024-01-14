{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#volume-v1-core
  - https://kubernetes.io/docs/concepts/storage/volumes/
  descr:
  - 已支持列表
    - cephfs
    - configMap / cm
    - emptyDir
    - fc
    - hostPath
    - nfs
    - persistentVolumeClaim / pvc
    - secret
    - rbd (ceph)
*/ -}}
{{- define "configStorage.Volume" -}}
  {{- with . }}
    {{- $__regexVolumes := "^(cephfs|configMap|cm|emptyDir|fc|hostPath|nfs|persistentVolumeClaim|pvc|secret|rbd)(\\s+|\\s*[\\|\\:\\-,]\\s*)?.*" }}
    {{- $__regexSplit := "\\s+|\\s*[\\|\\:\\-,]\\s*" }}

    {{- range $k, $v := . }}
      {{- if not (mustRegexMatch $__regexVolumes $k) }}
        {{- fail (print "configStorage.Volume: volume format not support. Values: " $k) }}
      {{- end }}
      {{- $__val := mustRegexSplit $__regexSplit $k -1 }}
      {{- $__volType := mustFirst $__val | lower }}
      {{- $__volName := join "-" (mustRest $__val) | lower  }}

      {{- if or (eq $__volType "cephfs") (mustRegexMatch "^(cephfs).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "cephfs" "define" "definitions.CephFSVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "configmap") (eq $__volType "cm") (mustRegexMatch "^(configMap|cm).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "configMap" "define" "definitions.ConfigMapVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "emptydir") (mustRegexMatch "^(emptyDir).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "emptyDir" "define" "definitions.EmptyDirVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "fc") (mustRegexMatch "^(fc).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "fc" "define" "definitions.FCVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "hostpath") (mustRegexMatch "^(hostPath).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "hostPath" "define" "definitions.HostPathVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "nfs") (mustRegexMatch "^(nfs).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "nfs" "define" "definitions.NFSVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "persistentvolumeclaim") (eq $__volType "pvc") (mustRegexMatch "^(persistentVolumeClaim|pvc).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "persistentVolumeClaim" "define" "definitions.PersistentVolumeClaimVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "rbd") (mustRegexMatch "^(rbd).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "rbd" "define" "definitions.RBDVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volType "secret") (mustRegexMatch "^(secret).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "secret" "define" "definitions.SecretVolumeSource" "name" $__volName) | nindent 0 }}
      {{- end }}

    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  variables:
  - s: 需要传入引用模板定义的数据
  - k: map 的键名
  - define: 需要引用的模板定义名称
  - name: volumes.name
*/ -}}
{{- define "configStorage.Volume.VolumeSource" -}}
  {{- with . }}
    {{- $__s := .s }}
    {{- $__name := coalesce .name (randAlpha 8 | lower) | trim | trimPrefix "vol-" }}
    {{- $__s = mustMerge $__s (dict "name" $__name) }}
    {{- $__vs := include .define $__s | fromYaml }}
    {{- if $__vs }}
      {{- nindent 0 "" -}}name: vol-{{ coalesce $__vs.name $__name | trim }}
      {{- nindent 0 "" -}}{{ .k }}:
      {{- toYaml $__vs | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
