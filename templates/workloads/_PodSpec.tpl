{{- /*
reference: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podspec-v1-core
*/ -}}
{{- define "workloads.PodSpec" -}}
{{- if or (gt (int ._CTX.activeDeadlineSeconds) 0) (gt (int .Values.activeDeadlineSeconds) 0) }}
  {{- nindent 0 "" -}}activeDeadlineSeconds: {{ int (coalesce ._CTX.activeDeadlineSeconds .Values.activeDeadlineSeconds) }}
{{- end }}

{{- if or (kindIs "bool" ._CTX.automountServiceAccountToken) (kindIs "bool" .Values.automountServiceAccountToken) }}
  {{- nindent 0 "" -}}automountServiceAccountToken: {{ coalesce (toString ._CTX.automountServiceAccountToken) (toString .Values.automountServiceAccountToken) }}
{{- end }}

{{- if or ._CTX.dnsPolicy .Values.dnsPolicy }}
  {{- $__dnsPolicyList := list "ClusterFirstWithHostNet" "ClusterFirst" "Default" "None" }}

  {{- if or (mustHas ._CTX.dnsPolicy $__dnsPolicyList) (mustHas .Values.dnsPolicy $__dnsPolicyList) }}
    {{- nindent 0 "" -}}dnsPolicy: {{ coalesce ._CTX.dnsPolicy .Values.dnsPolicy "ClusterFirst" }}
  {{- end }}
{{- end }}

{{- if or ._CTX.hostname .Values.hostname }}
  {{- nindent 0 "" -}}hostname: {{ coalesce ._CTX.hostname .Values.hostname }}
{{- end }}

{{- if or ._CTX.imagePullSecrets .Values.imagePullSecrets }}
  {{- $__imagePullSecretsList := list }}
  {{- if ._CTX.imagePullSecrets }}
    {{- $__imagePullSecretsList = concat ._CTX.imagePullSecrets }}
  {{- end }}
  {{- if .Values.imagePullSecrets }}
    {{- $__imagePullSecretsList = concat $__imagePullSecretsList .Values.imagePullSecrets }}
  {{- end }}
  {{- if $__imagePullSecretsList }}
    {{- nindent 0 "" -}}imagePullSecrets:
      {{- range $v := $__imagePullSecretsList | uniq }}
        {{- nindent 0 "" -}}- {{ include "definitions.LocalObjectReference" $v | trim }}
      {{- end }}
  {{- end }}
{{- end }}

{{- if or ._CTX.nodeName .Values.nodeName }}
  {{- nindent 0 "" -}}nodeName: {{ coalesce ._CTX.nodeName .Values.nodeName }}
{{- end }}

{{- if or ._CTX.nodeSelector .Values.nodeSelector }}
  {{- nindent 0 "" -}}nodeSelector:
    {{- toYaml (coalesce ._CTX.nodeSelector .Values.nodeSelector) | nindent 2 }}
{{- end }}

{{- if or ._CTX.restartPolicy .Values.restartPolicy }}
  {{- $__restartPolicyList := list "Always" "OnFailure" "Never" }}
  {{- if or (mustHas ._CTX.restartPolicy $__restartPolicyList) (mustHas .Values.restartPolicy $__restartPolicyList) }}
    {{- nindent 0 "" -}}restartPolicy: {{ coalesce ._CTX.restartPolicy .Values.restartPolicy "Always" }}
  {{- end }}
{{- end }}

{{- if or ._CTX.schedulerName .Values.schedulerName }}
  {{- nindent 0 "" -}}schedulerName: {{ coalesce ._CTX.schedulerName .Values.schedulerName "default-scheduler" }}
{{- end }}

{{- if or ._CTX.serviceAccountName .Values.serviceAccountName }}
  {{- nindent 0 "" -}}serviceAccountName: {{ coalesce ._CTX.serviceAccountName .Values.serviceAccountName "default" }}
{{- end }}

{{- if or ._CTX.hostPID .Values.hostPID ._CTX.shareProcessNamespace .Values.shareProcessNamespace }}
  {{- if or (kindIs "bool" ._CTX.hostPID) (kindIs "bool" .Values.hostPID) (kindIs "bool" ._CTX.shareProcessNamespace) (kindIs "bool" .Values.shareProcessNamespace) }}
    {{- if and (or ._CTX.hostPID .Values.hostPID) (not (or ._CTX.shareProcessNamespace .Values.shareProcessNamespace)) }}
      {{- nindent 0 "" -}}hostPID: true
    {{- else if and (or ._CTX.shareProcessNamespace .Values.shareProcessNamespace) (not (or ._CTX.hostPID .Values.hostPID)) }}
      {{- nindent 0 "" -}}shareProcessNamespace: true
    {{- else }}
      {{- fail "HostPID and ShareProcessNamespace cannot both be set" }}
    {{- end }}
  {{- else }}
    {{- fail "HostPID and ShareProcessNamespace must be true or false" }}
  {{- end }}
{{- end }}

{{- if or ._CTX.subdomain .Values.subdomain }}
  {{- nindent 0 "" -}}subdomain: {{ coalesce ._CTX.subdomain .Values.subdomain }}
{{- end }}

{{- if or (gt (int ._CTX.terminationGracePeriodSeconds) 0) (gt (int .Values.terminationGracePeriodSeconds) 0) }}
  {{- nindent 0 "" -}}terminationGracePeriodSeconds: {{ int (coalesce ._CTX.terminationGracePeriodSeconds .Values.terminationGracePeriodSeconds 30) }}
{{- end }}

{{- if or ._CTX.nodeAffinity .Values.nodeAffinity ._CTX.podAffinity .Values.podAffinity ._CTX.podAntiAffinity .Values.podAntiAffinity }}
  {{- $__affinityDict := dict "nodeAffinity" "" "podAffinity" "" "podAntiAffinity" "" }}

  {{- $__nodeAffinityDict := dict }}
  {{- $__podAffinityDict := dict }}
  {{- $__podAntiAffinityDict := dict }}

  {{- if ._CTX.nodeAffinity }}
    {{- $__nodeAffinityDict = merge $__nodeAffinityDict ._CTX.nodeAffinity }}
  {{- end }}
  {{- if .Values.nodeAffinity }}
    {{- $__nodeAffinityDict = merge $__nodeAffinityDict .Values.nodeAffinity }}
  {{- end }}
  {{- if $__nodeAffinityDict }}
    {{- $_ := set $__affinityDict "nodeAffinity" (include "definitions.NodeAffinity" $__nodeAffinityDict) }}
  {{- end }}

  {{- if ._CTX.podAffinity }}
    {{- $__podAffinityDict = merge $__podAffinityDict ._CTX.podAffinity }}
  {{- end }}
  {{- if .Values.podAffinity }}
    {{- $__podAffinityDict = merge $__podAffinityDict .Values.podAffinity }}
  {{- end }}
  {{- if $__podAffinityDict }}
    {{- $_ := set $__affinityDict "podAffinity" (include "definitions.PodAffinity" $__podAffinityDict) }}
  {{- end }}

  {{- if ._CTX.podAntiAffinity }}
    {{- $__podAntiAffinityDict = merge $__podAntiAffinityDict ._CTX.podAntiAffinity }}
  {{- end }}
  {{- if .Values.podAntiAffinity }}
    {{- $__podAntiAffinityDict = merge $__podAntiAffinityDict .Values.podAntiAffinity }}
  {{- end }}
  {{- if $__podAntiAffinityDict }}
    {{- $_ := set $__affinityDict "podAntiAffinity" (include "definitions.PodAntiAffinity" $__podAntiAffinityDict) }}
  {{- end }}

  {{- if or $__affinityDict.nodeAffinity $__affinityDict.podAffinity $__affinityDict.podAntiAffinity }}
    {{- nindent 0 "" -}}affinity:
    {{- if $__affinityDict.nodeAffinity }}
      {{- nindent 2 "" -}}  nodeAffinity:
        {{- get $__affinityDict "nodeAffinity" | indent 4 }}
    {{- end }}
    {{- if $__affinityDict.podAffinity }}
      {{- nindent 2 "" -}}  podAffinity:
        {{- get $__affinityDict "podAffinity" | indent 4 }}
    {{- end }}
    {{- if $__affinityDict.podAntiAffinity }}
      {{- nindent 2 "" -}}  podAntiAffinity:
        {{- get $__affinityDict "podAntiAffinity" | indent 4 }}
    {{- end }}
  {{- end }}
{{- end }}

{{- if or ._CTX.hostAliases .Values.hostAliases }}
  {{- $__regexHostList := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\s+[a-zA-Z0-9][-a-zA-Z0-9]{0,62}(\\.[a-zA-Z0-9][-a-zA-Z0-9]{0,62})+)+$" }}

  {{- $__hostList := list }}
  {{- $__hostDict := dict }}

  {{- if ._CTX.hostAliases }}
    {{- if kindIs "slice" ._CTX.hostAliases }}
      {{- $__hostList = concat $__hostList ._CTX.hostAliases }}
    {{- else if kindIs "map" ._CTX.hostAliases }}
      {{- $__hostDict = mustMergeOverwrite $__hostDict ._CTX.hostAliases }}
    {{- else if kindIs "string" ._CTX.hostAliases }}
      {{- if not (mustRegexMatch $__regexHostList ._CTX.hostAliases) }}
        {{- fail "Not a standard format, refer to the /etc/hosts file - 1" }}
      {{- end }}
      {{- $__hostList = mustAppend $__hostList ._CTX.hostAliases }}
    {{- end }}
  {{- end }}

  {{- if .Values.hostAliases }}
    {{- if kindIs "slice" .Values.hostAliases }}
      {{- $__hostList = concat $__hostList .Values.hostAliases }}
    {{- else if kindIs "map" .Values.hostAliases }}
      {{- $__hostDict = mustMergeOverwrite $__hostDict .Values.hostAliases }}
    {{- else if kindIs "string" .Values.hostAliases }}
      {{- if not (mustRegexMatch $__regexHostList .Values.hostAliases) }}
        {{- fail "Not a standard format, refer to the /etc/hosts file - 2" }}
      {{- end }}
      {{- $__hostList = mustAppend $__hostList .Values.hostAliases }}
    {{- end }}
  {{- end }}

  {{- if or $__hostList $__hostDict }}
    {{- nindent 0 "" -}}hostAliases:
    {{- if $__hostList }}
      {{- include "definitions.HostAlias" ($__hostList | uniq) | indent 2 }}
    {{- end }}
    {{- if $__hostDict }}
      {{- include "definitions.HostAlias" $__hostDict | indent 2 }}
    {{- end }}
  {{- end }}
{{- end }}

{{- if or ._CTX.securityContext .Values.securityContext }}
  {{- $__securityContextDict := dict }}

  {{- if .Values.securityContext }}
    {{- $__securityContextDict = mustMergeOverwrite $__securityContextDict .Values.securityContext }}
  {{- end }}

  {{- if ._CTX.securityContext }}
    {{- $__securityContextDict = mustMergeOverwrite $__securityContextDict ._CTX.securityContext }}
  {{- end }}

  {{- $__securityContext := include "definitions.PodSecurityContext" $__securityContextDict }}
  {{- if $__securityContext }}
    {{- nindent 0 "" -}}securityContext:
    {{- $__securityContext | indent 2 }}
  {{- end }}
{{- end }}

{{- if or ._CTX.tolerations .Values.tolerations }}
  {{- $__tolerationsList := list }}

  {{- if ._CTX.tolerations }}
    {{- $__tolerationsList = concat $__tolerationsList ._CTX.tolerations }}
  {{- end }}

  {{- if .Values.tolerations }}
    {{- $__tolerationsList = concat $__tolerationsList .Values.tolerations }}
  {{- end }}

  {{- $__tolerations := include "definitions.Toleration" ($__tolerationsList | uniq) }}
  {{- if $__tolerations }}
    {{- nindent 0 "" -}}tolerations:
    {{- $__tolerations | indent 0 }}
  {{- end }}
{{- end }}

{{- if or ._CTX.volumes .Values.volumes }}
  {{- $__volumesDict := dict }}

  {{- if ._CTX.volumes }}
    {{- $__volumesDict = mustMergeOverwrite $__volumesDict ._CTX.volumes }}
  {{- end }}

  {{- if .Values.volumes }}
    {{- $__volumesDict = mustMergeOverwrite $__volumesDict .Values.volumes }}
  {{- end }}

  {{- $__volumes := include "configStorage.Volume" $__volumesDict }}
  {{- if $__volumes }}
    {{- nindent 0 "" -}}volumes:
    {{- $__volumes | indent 0 }}
  {{- end }}
{{- end }}

{{- if and ._CTX.containers (kindIs "slice" ._CTX.containers) }}
  {{- $_ := set . "__isInitContainer" false }}

  {{- nindent 0 "" -}}containers:
  {{- include "workloads.Container" . | indent 0 }}
{{- end }}

{{- if and ._CTX.initContainers (kindIs "slice" ._CTX.initContainers) }}
  {{- $_ := set . "__isInitContainer" true }}

  {{- nindent 0 "" -}}initContainers:
  {{- include "workloads.Container" . | indent 0 }}
{{- end }}
{{- end }}
