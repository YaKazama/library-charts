{{- /*
reference:
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#podspec-v1-core

(dig "template" "spec" "activeDeadlineSeconds" 0 .Context)
*/ -}}
{{- define "workloads.PodSpec" -}}
  {{- $__activeDeadlineSeconds := include "base.int" (coalesce .Context.podActiveDeadlineSeconds .Values.podActiveDeadlineSeconds .Context.activeDeadlineSeconds .Values.activeDeadlineSeconds) }}
  {{- if $__activeDeadlineSeconds }}
    {{- nindent 0 "" -}}activeDeadlineSeconds: {{ $__activeDeadlineSeconds }}
  {{- end }}

  {{- $__nodeAffinity := dict }}
  {{- $__nodeAffinitySrc := pluck "nodeAffinity" .Context .Values }}
  {{- range ($__nodeAffinitySrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__nodeAffinity = mustMerge $__nodeAffinity . }}
    {{- end }}
  {{- end }}
  {{- $__podAffinity := dict }}
  {{- $__podAffinitySrc := pluck "podAffinity" .Context .Values }}
  {{- range ($__podAffinitySrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__podAffinity = mustMerge $__podAffinity . }}
    {{- end }}
  {{- end }}
  {{- $__podAntiAffinity := dict }}
  {{- $__podAntiAffinitySrc := pluck "podAntiAffinity" .Context .Values }}
  {{- range ($__podAntiAffinitySrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__podAntiAffinity = mustMerge $__podAntiAffinity . }}
    {{- end }}
  {{- end }}
  {{- $__affinity := include "definitions.Affinity" (dict "nodeAffinity" $__nodeAffinity "podAffinity" $__podAffinity "podAntiAffinity" $__podAntiAffinity) }}
  {{- if $__affinity }}
    {{- nindent 0 "" -}}affinity:
      {{- $__affinity | indent 2 }}
  {{- end }}

  {{- $__automountServiceAccountToken := include "base.bool.false" (pluck "automountServiceAccountToken" .Context .Values) }}
  {{- if $__automountServiceAccountToken }}
    {{- nindent 0 "" -}}automountServiceAccountToken: {{ $__automountServiceAccountToken }}
  {{- end }}

  {{- $__dnsPolicyAllowed := list "ClusterFirstWithHostNet" "ClusterFirst" "Default" "None" }}
  {{- if mustHas (coalesce .Context.dnsPolicy .Values.dnsPolicy) $__dnsPolicyAllowed }}
    {{- nindent 0 "" -}}dnsPolicy: {{ coalesce .Context.dnsPolicy .Values.dnsPolicy "ClusterFirst" }}
  {{- end }}

  {{- $__hostAlias := list }}
  {{- $__clean := list }}
  {{- $__cleanDict := dict }}
  {{- $__hostAliasesSrc := pluck "hostAliases" .Context .Values }}
  {{- range ($__hostAliasesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "string" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- else if kindIs "map" . }}
      {{- $__cleanDict = mustMerge $__cleanDict . }}
    {{- end }}
  {{- end }}
  {{- range $k, $v := $__cleanDict }}
    {{- $__clean = mustAppend $__clean (dict $k $v) }}
  {{- end }}
  {{- range $__clean | mustUniq | mustCompact }}
    {{- $__hostAlias = mustAppend $__hostAlias (include "definitions.HostAlias" . | fromYaml) }}
  {{- end }}
  {{- if $__hostAlias }}
    {{- nindent 0 "" -}}hostAliases:
    {{- toYaml $__hostAlias | nindent 0 }}
  {{- end }}

  {{- $__hostPID := include "base.bool" (coalesce .Context.hostPID .Values.hostPID) }}
  {{- $__shareProcessNamespace := include "base.bool" (coalesce .Context.shareProcessNamespace .Values.shareProcessNamespace) }}
  {{- if or $__hostPID $__shareProcessNamespace }}
    {{- if and $__hostPID (not $__shareProcessNamespace) }}
      {{- nindent 0 "" -}}hostPID: {{ $__hostPID }}
    {{- else if and $__shareProcessNamespace (not $__hostPID) }}
      {{- nindent 0 "" -}}shareProcessNamespace: {{ $__shareProcessNamespace }}
    {{- else }}
      {{- fail "HostPID and ShareProcessNamespace cannot both be set" }}
    {{- end }}
  {{- end }}

  {{- $__hostname := include "base.string" (coalesce .Context.hostname .Values.hostname) }}
  {{- if $__hostname }}
    {{- nindent 0 "" -}}hostname: {{ $__hostname }}
  {{- end }}

  {{- $__imagePullSecrets := include "base.fmt.slice" (dict "s" (pluck "imagePullSecrets" .Context .Values) "define" "definitions.LocalObjectReference") }}
  {{- if $__imagePullSecrets }}
    {{- nindent 0 "" -}}imagePullSecrets:
    {{- $__imagePullSecrets | nindent 0 }}
  {{- end }}

  {{- $__nodeName := include "base.string" (coalesce .Context.nodeName .Values.nodeName) }}
  {{- if $__nodeName }}
    {{- nindent 0 "" -}}nodeName: {{ $__nodeName }}
  {{- end }}

  {{- $__nodeSelector := dict }}
  {{- $__clean := dict }}
  {{- $__validOnly := false }}
  {{- if kindIs "map" .Context.nodeSelector }}
    {{- $__validOnly = dig "validOnly" false .Context.nodeSelector }}
    {{- $__clean = mustMerge $__clean (omit .Context.nodeSelector "validOnly") }}
  {{- end }}
  {{- if kindIs "map" .Values.nodeSelector }}
    {{- if not $__validOnly }}
      {{- $__clean = mustMerge $__clean (omit .Values.nodeSelector "validOnly") }}
    {{- end }}
  {{- end }}
  {{- if $__clean }}
    {{- nindent 0 "" -}}nodeSelector:
      {{- toYaml $__clean | nindent 2 }}
  {{- end }}

  {{- $__restartPolicyAllowed := list "Always" "OnFailure" "Never" }}
  {{- $__restartPolicyForJobAllowed := list "OnFailure" "Never" }}
  {{- $__restartPolicy := include "base.toa" (coalesce .Context.restartPolicy .Values.restartPolicy) }}
  {{- if eq ._kind "Job" }}
    {{- if mustHas $__restartPolicy $__restartPolicyForJobAllowed }}
      {{- nindent 0 "" -}}restartPolicy: {{ coalesce $__restartPolicy "Always"  }}
    {{- end }}
  {{- else }}
    {{- if mustHas $__restartPolicy $__restartPolicyAllowed }}
      {{- nindent 0 "" -}}restartPolicy: {{ coalesce $__restartPolicy "Always"  }}
    {{- end }}
  {{- end }}

  {{- $__schedulerName := include "base.string" (coalesce .Context.schedulerName .Values.schedulerName) }}
  {{- if $__schedulerName }}
    {{- nindent 0 "" -}}schedulerName: {{ coalesce $__schedulerName "default-scheduler" }}
  {{- end }}

  {{- $__clean := dict }}
  {{- $__securityContextSrc := pluck "securityContext" .Context .Values }}
  {{- range ($__securityContextSrc | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__clean = mustMerge $__clean . }}
    {{- end }}
  {{- end }}
  {{- $__securityContext := include "definitions.PodSecurityContext" $__clean }}
  {{- if $__securityContext }}
    {{- nindent 0 "" -}}securityContext:
    {{- $__securityContext | indent 2 }}
  {{- end }}

  {{- $__serviceAccountName := include "base.string" (coalesce .Context.serviceAccountName .Values.serviceAccountName) }}
  {{- if $__serviceAccountName }}
    {{- nindent 0 "" -}}serviceAccountName: {{ $__serviceAccountName }}
  {{- end }}

  {{- $__subdomain := include "base.string" (coalesce .Context.subdomain .Values.subdomain) }}
  {{- if $__subdomain }}
    {{- nindent 0 "" -}}subdomain: {{ $__subdomain }}
  {{- end }}

  {{- $__terminationGracePeriodSeconds := include "base.int.zero" (pluck "terminationGracePeriodSeconds" .Context .Values) }}
  {{- if $__terminationGracePeriodSeconds }}
    {{- nindent 0 "" -}}terminationGracePeriodSeconds: {{ coalesce $__terminationGracePeriodSeconds 30 }}
  {{- end }}

  {{- $__tolerations := list }}
  {{- $__clean := list }}
  {{- $__tolerationsSrc := pluck "tolerations" .Context .Values }}
  {{- range ($__tolerationsSrc | mustUniq | mustCompact) }}
    {{- if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- end }}
  {{- end }}
  {{- range $__clean | mustUniq | mustCompact }}
    {{- $__tolerations = mustAppend $__tolerations (include "definitions.Toleration" . | fromYaml) }}
  {{- end }}
  {{- if $__tolerations }}
    {{- nindent 0 "" -}}tolerations:
    {{- toYaml $__tolerations | nindent 0 }}
  {{- end }}

  {{- $__volumes := list }}
  {{- $__clean := list }}
  {{- $__volumesSrc := pluck "volumes" .Context .Values }}
  {{- range ($__volumesSrc | mustUniq | mustCompact) }}
    {{- if kindIs "slice" . }}
      {{- $__clean = concat $__clean . }}
    {{- else if kindIs "map" . }}
      {{- range $k, $v := . }}
        {{- $__clean = mustAppend $__clean (dict $k $v) }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- range $__clean | mustUniq | mustCompact }}
    {{- $__volumes = mustAppend $__volumes (include "configStorage.Volume" . | fromYaml) }}
  {{- end }}
  {{- if $__volumes }}
    {{- nindent 0 "" -}}volumes:
    {{- toYaml $__volumes | nindent 0 }}
  {{- end }}

  {{- $__containers := list }}
  {{- $__clean := list }}
  {{- if kindIs "slice" .Context.containers }}
    {{- $__clean = concat $__clean .Context.containers }}
  {{- else if kindIs "map" .Context.containers }}
    {{- $__clean = mustAppend $__clean .Context.containers }}
  {{- end }}
  {{- range $__clean | mustUniq | mustCompact }}
    {{- $__containers = mustAppend $__containers (include "workloads.Container" (dict "container" . "isInitContainer" false "Values" $.Values "Files" $.Files "Chart" $.Chart "Release" $.Release "Context" $.Context) | fromYaml) }}
  {{- end }}
  {{- if $__containers }}
    {{- nindent 0 "" -}}containers:
    {{- toYaml $__containers | nindent 0 }}
  {{- end }}

  {{- $__initContainers := list }}
  {{- $__clean := list }}
  {{- if kindIs "slice" .Context.initContainers }}
    {{- $__clean = concat $__clean .Context.initContainers }}
  {{- else if kindIs "map" .Context.initContainers }}
    {{- $__clean = mustAppend $__clean .Context.initContainers }}
  {{- end }}
  {{- range $__clean | mustUniq | mustCompact }}
    {{- $__initContainers = mustAppend $__initContainers (include "workloads.Container" (dict "container" . "isInitContainer" true "Values" $.Values "Files" $.Files "Chart" $.Chart "Release" $.Release "Context" $.Context) | fromYaml) }}
  {{- end }}
  {{- if $__initContainers }}
    {{- nindent 0 "" -}}initContainers:
    {{- toYaml $__initContainers | nindent 0 }}
  {{- end }}
{{- end }}
