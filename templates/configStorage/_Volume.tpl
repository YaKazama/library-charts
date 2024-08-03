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

    {{- /*
      当传入的是 map 时，从其中取出 namePrefix
    */ -}}
    {{- $__namePrefix := .namePrefix }}

    {{- range $k, $v := (omit . "namePrefix") }}
      {{- if not (mustRegexMatch $__regexVolumes $k) }}
        {{- fail (print "configStorage.Volume: volume format not support. Values: " $k) }}
      {{- end }}
      {{- $__val := mustRegexSplit $__regexSplit $k -1 }}
      {{- $__volType := mustFirst $__val | lower }}
      {{- $__volTypeLower := $__volType | lower }}
      {{- $__volName := join "-" (mustRest $__val) | lower }}

      {{- /*
        当传入的是 slice 时，从其中取 namePrefix
        由于 slice 和 map 不能同时传入，所以此时 $__namePrefix 为空字符
      */ -}}
      {{- $__namePrefix = dig "namePrefix" $__namePrefix $v }}

      {{- if or (eq $__volTypeLower "cephfs") (mustRegexMatch "^(cephfs).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "cephfs" "define" "definitions.CephFSVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "configmap") (eq $__volType "cm") (mustRegexMatch "^(configMap|cm).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "configMap" "define" "definitions.ConfigMapVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "emptydir") (mustRegexMatch "^(emptyDir).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "emptyDir" "define" "definitions.EmptyDirVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "fc") (mustRegexMatch "^(fc).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "fc" "define" "definitions.FCVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "hostpath") (mustRegexMatch "^(hostPath).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "hostPath" "define" "definitions.HostPathVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "nfs") (mustRegexMatch "^(nfs).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "nfs" "define" "definitions.NFSVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "persistentvolumeclaim") (eq $__volType "pvc") (mustRegexMatch "^(persistentVolumeClaim|pvc).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "persistentVolumeClaim" "define" "definitions.PersistentVolumeClaimVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "rbd") (mustRegexMatch "^(rbd).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "rbd" "define" "definitions.RBDVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

      {{- if or (eq $__volTypeLower "secret") (mustRegexMatch "^(secret).*" $__volType) }}
        {{- include "configStorage.Volume.VolumeSource" (dict "s" $v "k" "secret" "define" "definitions.SecretVolumeSource" "name" $__volName "namePrefix" $__namePrefix) | nindent 0 }}
      {{- end }}

    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  variables:
  - s: 需要传入引用模板定义的数据
  - k: string, map 的键名
  - define: string, 需要引用的模板定义名称
  - name: string, volumes.name
  - namePrefix: string, 名称前缀，默认为空
*/ -}}
{{- define "configStorage.Volume.VolumeSource" -}}
  {{- with . }}
    {{- $__s := .s }}
    {{- $__namePrefix := .namePrefix }}
    {{- $__s = mustMerge $__s (dict "name" (coalesce .name (randAlpha 8 | lower))) }}

    {{- $__vs := include .define $__s | fromYaml }}
    {{- if $__vs }}
      {{- $__name := $__s.name | trim | trimPrefix "-" }}
      {{- if $__namePrefix }}
        {{- $__name = printf "%s-%s" ($__namePrefix | trimSuffix "-") $__name }}
      {{- end }}
      {{- nindent 0 "" -}}name: {{ $__name | trim }}
      {{- nindent 0 "" -}}{{ .k }}:
      {{- toYaml $__vs | nindent 2 }}
    {{- end }}
  {{- end }}
{{- end }}
