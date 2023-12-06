{{- define "service.ServiceSpec" -}}
  {{- $__regexIP := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
  {{- $__typeList := list "ExternalName" "ClusterIP" "NodePort" "LoadBalancer" }}
  {{- $__externalTrafficPolicyList := list "Local" "Cluster" }}
  {{- $__internalTrafficPolicyList := list "Local" "Cluster" }}
  {{- $__ipFamilyPolicyList := list "SingleStack" "PreferDualStack" "RequireDualStack" }}
  {{- $__sessionAffinityList := list "ClientIP" "None" }}

  {{- if or (kindIs "bool" ._CTX.allocateLoadBalancerNodePorts) (kindIs "bool" .Values.allocateLoadBalancerNodePorts) }}
    {{- nindent 0 "" -}}allocateLoadBalancerNodePorts: {{ coalesce (toString ._CTX.allocateLoadBalancerNodePorts) (toString .Values.allocateLoadBalancerNodePorts) }}
  {{- end }}

  {{- if or (mustRegexMatch $__regexIP ._CTX.clusterIP) (mustRegexMatch $__regexIP .Values.clusterIP) }}
    {{- nindent 0 "" -}}clusterIP: {{ coalesce ._CTX.clusterIP .Values.clusterIP }}
  {{- end }}

  {{- if or ._CTX.clusterIPs .Values.clusterIPs }}
    {{- $__clusterIPs := list }}

    {{- if ._CTX.clusterIPs }}
      {{- if kindIs "slice" ._CTX.clusterIPs }}
        {{- range ._CTX.clusterIPs }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__clusterIPs = mustAppend $__clusterIPs . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" ._CTX.clusterIPs }}
        {{- range (mustRegexSplit "\\s+" ._CTX.clusterIPs -1) }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__clusterIPs = mustAppend $__clusterIPs . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .clusterIPs not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.clusterIPs }}
      {{- if kindIs "slice" .Values.clusterIPs }}
        {{- range .Values.clusterIPs }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__clusterIPs = mustAppend $__clusterIPs . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" .Values.clusterIPs }}
        {{- range (mustRegexSplit "\\s+" .Values.clusterIPs -1) }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__clusterIPs = mustAppend $__clusterIPs . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .Values.clusterIPs not support" }}
      {{- end }}
    {{- end }}

    {{- if (mustCompact (mustUniq $__clusterIPs)) }}
      {{- nindent 0 "" -}}clusterIPs:
      {{- toYaml (mustCompact (mustUniq $__clusterIPs)) | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- if or ._CTX.externalIPs .Values.externalIPs }}
    {{- $__externalIPs := list }}

    {{- if ._CTX.externalIPs }}
      {{- if kindIs "slice" ._CTX.externalIPs }}
        {{- range ._CTX.externalIPs }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__externalIPs = mustAppend $__externalIPs . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" ._CTX.externalIPs }}
        {{- range (mustRegexSplit "\\s+" ._CTX.externalIPs -1) }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__externalIPs = mustAppend $__externalIPs . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .externalIPs not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.externalIPs }}
      {{- if kindIs "slice" .Values.externalIPs }}
        {{- range .Values.externalIPs }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__externalIPs = mustAppend $__externalIPs . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" .Values.externalIPs }}
        {{- range (mustRegexSplit "\\s+" .Values.externalIPs -1) }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__externalIPs = mustAppend $__externalIPs . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .Values.externalIPs not support" }}
      {{- end }}
    {{- end }}

    {{- if (mustCompact (mustUniq $__externalIPs)) }}
      {{- nindent 0 "" -}}externalIPs:
      {{- toYaml (mustCompact (mustUniq $__externalIPs)) | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- if and (or ._CTX.externalName .Values.externalName) (or (eq "ExternalName" ._CTX.type) (eq "ExternalName" .Values.type)) }}
    {{- nindent 0 "" -}}externalName: {{ coalesce ._CTX.externalName .Values.externalName | lower }}
  {{- end }}

  {{- if or (mustHas ._CTX.externalTrafficPolicy $__externalTrafficPolicyList) (mustHas .Values.externalTrafficPolicy $__externalTrafficPolicyList) }}
    {{- nindent 0 "" -}}externalTrafficPolicy: {{ coalesce ._CTX.externalTrafficPolicy .Values.externalTrafficPolicy "Cluster" }}
  {{- end }}

  {{- if or (kindIs "float64" ._CTX.healthCheckNodePort) (kindIs "float64" .Values.healthCheckNodePort) }}
    {{- nindent 0 "" -}}healthCheckNodePort: {{ coalesce (toString ._CTX.healthCheckNodePort) (toString .Values.healthCheckNodePort) }}
  {{- end }}

  {{- if or (mustHas ._CTX.internalTrafficPolicy $__internalTrafficPolicyList) (mustHas .Values.internalTrafficPolicy $__internalTrafficPolicyList) }}
    {{- nindent 0 "" -}}internalTrafficPolicy: {{ coalesce ._CTX.internalTrafficPolicy .Values.internalTrafficPolicy "Cluster" }}
  {{- end }}

  {{- if or ._CTX.ipFamilies .Values.ipFamilies }}
    {{- nindent 0 "" -}}ipFamilies:
    {{- toYaml ._CTX.ipFamilies | nindent 0 }}
    {{- toYaml .Values.ipFamilies | nindent 0 }}
  {{- end }}

  {{- if or (mustHas ._CTX.ipFamilyPolicy $__ipFamilyPolicyList) (mustHas .Values.ipFamilyPolicy $__ipFamilyPolicyList) }}
    {{- nindent 0 "" -}}ipFamilyPolicy: {{ coalesce ._CTX.ipFamilyPolicy .Values.ipFamilyPolicy "SingleStack" }}
  {{- end }}

  {{- if or ._CTX.loadBalancerClass .Values.loadBalancerClass }}
    {{- nindent 0 "" -}}loadBalancerClass: {{ coalesce ._CTX.loadBalancerClass .Values.loadBalancerClass }}
  {{- end }}

  {{- if or (mustRegexMatch $__regexIP ._CTX.loadBalancerIP) (mustRegexMatch $__regexIP .Values.loadBalancerIP) }}
    {{- nindent 0 "" -}}loadBalancerIP: {{ coalesce ._CTX.loadBalancerIP .Values.loadBalancerIP }}
  {{- end }}

  {{- if or ._CTX.loadBalancerSourceRanges .Values.loadBalancerSourceRanges }}
    {{- $__loadBalancerSourceRanges := list }}

    {{- if ._CTX.loadBalancerSourceRanges }}
      {{- if kindIs "slice" ._CTX.loadBalancerSourceRanges }}
        {{- range ._CTX.loadBalancerSourceRanges }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__loadBalancerSourceRanges = mustAppend $__loadBalancerSourceRanges . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" ._CTX.loadBalancerSourceRanges }}
        {{- range (mustRegexSplit "\\s+" ._CTX.loadBalancerSourceRanges -1) }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__loadBalancerSourceRanges = mustAppend $__loadBalancerSourceRanges . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .loadBalancerSourceRanges not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.loadBalancerSourceRanges }}
      {{- if kindIs "slice" .Values.loadBalancerSourceRanges }}
        {{- range .Values.loadBalancerSourceRanges }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__loadBalancerSourceRanges = mustAppend $__loadBalancerSourceRanges . }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" .Values.loadBalancerSourceRanges }}
        {{- range (mustRegexSplit "\\s+" .Values.loadBalancerSourceRanges -1) }}
          {{- if mustRegexMatch $__regexIP . }}
            {{- $__loadBalancerSourceRanges = mustAppend $__loadBalancerSourceRanges . }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .Values.loadBalancerSourceRanges not support" }}
      {{- end }}
    {{- end }}

    {{- if (mustCompact (mustUniq $__loadBalancerSourceRanges)) }}
      {{- nindent 0 "" -}}loadBalancerSourceRanges:
      {{- toYaml (mustCompact (mustUniq $__loadBalancerSourceRanges)) | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- if or (kindIs "bool" ._CTX.publishNotReadyAddresses) (kindIs "bool" .Values.publishNotReadyAddresses) }}
    {{- nindent 0 "" -}}publishNotReadyAddresses: {{ coalesce (toString ._CTX.publishNotReadyAddresses) (toString .Values.publishNotReadyAddresses) }}
  {{- end }}

  {{- if or ._CTX.ports .Values.ports }}
    {{- $__ports := list }}

    {{- if ._CTX.ports }}
      {{- if kindIs "slice" ._CTX.ports }}
        {{- range ._CTX.ports }}
          {{- $_ := set . "type" $._CTX.type }}
          {{- $__ports = mustAppend $__ports . }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .ports not support" }}
      {{- end }}
    {{- end }}
    {{- if .Values.ports }}
      {{- if kindIs "slice" .Values.ports }}
        {{- range .Values.ports }}
          {{- $_ := set . "type" $.Values.type }}
          {{- $__ports = mustAppend $__ports . }}
        {{- end }}
      {{- else }}
        {{- fail "service.ServiceSpec: .ports not support" }}
      {{- end }}
    {{- end }}

    {{- if (mustCompact (mustUniq $__ports)) }}
      {{- $__portsList := list }}

      {{- range $__ports }}
        {{- $__portsList = mustAppend $__portsList (include "definitions.ServicePort" . | fromYaml) }}
      {{- end }}

      {{- if $__portsList }}
        {{- nindent 0 "" -}}ports:
        {{- toYaml $__portsList | nindent 0 }}
      {{- end }}
    {{- end }}

  {{- end }}

  {{- nindent 0 "" -}}selector:
    {{- include "definitions.LabelSelector" . | indent 2 }}

  {{- if or (mustHas ._CTX.sessionAffinity $__sessionAffinityList) (mustHas .Values.sessionAffinity $__sessionAffinityList) }}
    {{- nindent 0 "" -}}sessionAffinity: {{ coalesce ._CTX.sessionAffinity .Values.sessionAffinity "None" }}
  {{- end }}

  {{- if or ._CTX.sessionAffinityConfig .Values.sessionAffinityConfig }}
    {{- nindent 0 "" -}}sessionAffinityConfig:
      {{- include "definitions.SessionAffinityConfig" (coalesce ._CTX.sessionAffinityConfig .Values.sessionAffinityConfig) | indent 2 }}
  {{- end }}

  {{- if or (mustHas ._CTX.type $__typeList) (mustHas .Values.type $__typeList) }}
    {{- nindent 0 "" -}}type: {{ coalesce ._CTX.type .Values.type "ClusterIP" }}
  {{- end }}
{{- end }}
