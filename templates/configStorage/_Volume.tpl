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
  {{- $__regexCephfs := "^(cephfs)[:\\-\\|]?.*" }}
  {{- $__regexConfigMap := "^(configMap|cm)[:\\-\\|]?.*" }}
  {{- $__regexEmptyDir := "^(emptyDir)[:\\-\\|]?.*" }}
  {{- $__regexFC := "^(fc)[:\\-\\|]?.*" }}
  {{- $__regexHostPath := "^(hostPath)[:\\-\\|]?.*" }}
  {{- $__regexNFS := "^(nfs)[:\\-\\|]?.*" }}
  {{- $__regexPVC := "^(persistentVolumeClaim|pvc)[:\\-\\|]?.*" }}
  {{- $__regexSecret := "^(secret)[:\\-\\|]?.*" }}
  {{- $__regexRBD := "^(rbd)[:\\-\\|]?.*" }}

  {{- range $k, $v := . }}
    {{- /*
      for cephfs
    */ -}}
    {{- if mustRegexMatch $__regexCephfs $k }}
      {{- $__cephfsList := mustRegexSplit "^(cephfs)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__cephfsList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__cephfsList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-cephfs-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  cephfs:
      {{- include "definitions.CephFSVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for configMap
    */ -}}
    {{- if mustRegexMatch $__regexConfigMap $k }}
      {{- $__cmList := mustRegexSplit "^(configMap|cm)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__cmList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__cmList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-cm-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  configMap:
      {{- include "definitions.ConfigMapVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for emptyDir
    */ -}}
    {{- if mustRegexMatch $__regexEmptyDir $k }}
      {{- $__emptyDirList := mustRegexSplit "^(emptyDir)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__emptyDirList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__emptyDirList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-emptyDir-{{ randAlphaNum 5 }}
      {{- end }}
      {{- $__emptyDir := include "definitions.EmptyDirVolumeSource" $v }}
      {{- if $__emptyDir }}
        {{- nindent 2 "" -}}  emptyDir:
        {{- $__emptyDir | indent 4 }}
      {{- else }}
        {{- nindent 2 "" -}}  emptyDir: {}
      {{- end }}
    {{- end }}

    {{- /*
      for fc
    */ -}}
    {{- if mustRegexMatch $__regexFC $k }}
      {{- $__fcList := mustRegexSplit "^(fc)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__fcList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__fcList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-fc-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  fc:
      {{- include "definitions.FCVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for hostPath
    */ -}}
    {{- if mustRegexMatch $__regexHostPath $k }}
      {{- $__hostPathList := mustRegexSplit "^(hostPath)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__hostPathList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__hostPathList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-hostPath-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  hostPath:
      {{- include "definitions.HostPathVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for nfs
    */ -}}
    {{- if mustRegexMatch $__regexNFS $k }}
      {{- $__NFSList := mustRegexSplit "^(nfs)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__NFSList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__NFSList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-nfs-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  nfs:
      {{- include "definitions.NFSVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for persistentVolumeClaim
    */ -}}
    {{- if mustRegexMatch $__regexPVC $k }}
      {{- $__PVCList := mustRegexSplit "^(persistentVolumeClaim|pvc)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__PVCList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__PVCList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-pvc-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  persistentVolumeClaim:
      {{- include "definitions.PersistentVolumeClaimVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for secret
    */ -}}
    {{- if mustRegexMatch $__regexSecret $k }}
      {{- $__secretList := mustRegexSplit "^(secret)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__secretList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__secretList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-secret-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  secret:
      {{- include "definitions.SecretVolumeSource" $v | indent 4 }}
    {{- end }}

    {{- /*
      for rbd
    */ -}}
    {{- if mustRegexMatch $__regexRBD $k }}
      {{- $__rbdList := mustRegexSplit "^(rbd)[:\\-\\|]?" $k -1 }}

      {{- if mustLast $__rbdList }}
        {{- nindent 0 "" -}}- name: {{ mustLast $__rbdList }}
      {{- else }}
        {{- nindent 0 "" -}}- name: volumes-rbd-{{ randAlphaNum 5 }}
      {{- end }}
      {{- nindent 2 "" -}}  rbd:
      {{- include "definitions.RBDVolumeSource" $v | indent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
