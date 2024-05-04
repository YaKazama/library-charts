{{- /*
  涉及到 IP 的选项，暂时只支持 IPv4
*/ -}}
{{- define "service.ServiceSpec" -}}
  {{- /*
    后续有很多地方需要用到它，但它的排序在最后，故此处先预处理
  */ -}}
  {{- $__type := include "base.string" (coalesce .Context.type .Values.type) }}

  {{- $__allocateLoadBalancerNodePorts := include "base.bool.false" (pluck "allocateLoadBalancerNodePorts" .Context .Values) }}
  {{- if $__allocateLoadBalancerNodePorts }}
    {{- nindent 0 "" -}}allocateLoadBalancerNodePorts: {{ $__allocateLoadBalancerNodePorts }}
  {{- end }}

  {{- $__typeClusterIPsAllowed := list "ClusterIP" "NodePort" "LoadBalancer" }}
  {{- /*
    ports 需要用到 clusterIP 作为 targetPort 的判断条件，故此处先预处理
  */ -}}
  {{- $__clusterIP := include "base.string.empty" (dict "s" .Values.clusterIP "empty" true) }}
  {{- if not $__clusterIP }}
    {{- $__clusterIP = include "base.string.empty" (dict "s" .Context.clusterIP "empty" true) }}
  {{- end }}
  {{- if or (empty $__type) (mustHas $__type $__typeClusterIPsAllowed) }}
    {{- $__clusterIPAllowed := list "\"\"" "None" }}
    {{- $__regexClusterIP := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
    {{- if $__clusterIP }}
      {{- if not (mustHas $__clusterIP $__clusterIPAllowed) }}
        {{- if not (mustRegexMatch $__regexClusterIP $__clusterIP) }}
          {{- fail "service.ServiceSpec: clusterIP invalid" }}
        {{- end }}
      {{- end }}
      {{- nindent 0 "" -}}clusterIP: {{ $__clusterIP }}
    {{- end }}

    {{- $__clusterIPsSrc := pluck "clusterIPs" .Context .Values }}
    {{- /*
      依次判断空字符串, None, IP 地址
    */ -}}
    {{- if mustHas "" $__clusterIPsSrc }}
      {{- $__clusterIPsSrc = list "" }}
    {{- else if (mustHas "None" $__clusterIPsSrc) }}
      {{- $__clusterIPsSrc = list "None" }}
    {{- else }}
      {{- $__clusterIPsSrc = $__clusterIPsSrc | mustUniq | mustCompact }}
    {{- end }}
    {{- /*
      - 此处，如果 clusterIP = "\"\"" 则重置为 ""
        - "\"\"" 由 base.string.empty 产生
      - clusterIPs[0] 需要与 clusterIP 相同
    */ -}}
    {{- if eq $__clusterIP "\"\"" }}
      {{- $__clusterIP = "" }}
    {{- end }}
    {{- if $__clusterIPsSrc }}
      {{- $__val := list }}
      {{- $__valTmp := index $__clusterIPsSrc 0 }}
      {{- if kindIs "slice" $__valTmp }}
        {{- $__val = concat $__val $__valTmp }}
      {{- else if kindIs "string" $__valTmp }}
        {{- $__val = mustAppend $__val $__valTmp }}
      {{- end }}
      {{- if not (eq (index $__val 0) $__clusterIP) }}
        {{- $__clusterIPsSrc = list $__clusterIP }}
      {{- end }}
      {{- $__regexClusterIPs := "^$|\"\"|^None|((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
      {{- $__clusterIPs := include "base.fmt.slice" (dict "s" $__clusterIPsSrc "c" $__regexClusterIPs "empty" true) }}
      {{- if $__clusterIPs }}
        {{- nindent 0 "" -}}clusterIPs:
        {{- $__clusterIPs | nindent 0 }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- $__regexExternalIPs := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
  {{- $__externalIPsSrc := pluck "externalIPs" .Context .Values }}
  {{- $__externalIPs := include "base.fmt.slice" (dict "s" ($__externalIPsSrc | mustUniq | mustCompact) "c" $__regexExternalIPs) }}
  {{- if $__externalIPs }}
    {{- nindent 0 "" -}}externalIPs:
    {{- $__externalIPs | nindent 0 }}
  {{- end }}

  {{- $__externalName := include "base.string" (coalesce .Context.externalName .Values.externalName) }}
  {{- if $__externalName }}
    {{- nindent 0 "" -}}externalName: {{ $__externalName | lower }}
  {{- end }}

  {{- $__externalTrafficPolicyAllowed := list "Local" "Cluster" }}
  {{- $__externalTrafficPolicy := include "base.string" (coalesce .Context.externalTrafficPolicy .Values.externalTrafficPolicy) }}
  {{- if mustHas $__externalTrafficPolicy $__externalTrafficPolicyAllowed }}
    {{- nindent 0 "" -}}externalTrafficPolicy: {{ $__externalTrafficPolicy }}
  {{- end }}

  {{- $__healthCheckNodePort := include "base.int" (coalesce .Context.healthCheckNodePort .Values.healthCheckNodePort) }}
  {{- if $__healthCheckNodePort }}
    {{- nindent 0 "" -}}healthCheckNodePort: {{ $__healthCheckNodePort }}
  {{- end }}

  {{- $__internalTrafficPolicyAllowed := list "Local" "Cluster" }}
  {{- $__internalTrafficPolicy := include "base.string" (coalesce .Context.internalTrafficPolicy .Values.internalTrafficPolicy) }}
  {{- if mustHas $__internalTrafficPolicy $__internalTrafficPolicyAllowed }}
    {{- nindent 0 "" -}}internalTrafficPolicy: {{ $__internalTrafficPolicy }}
  {{- end }}

  {{- $__regexIpFamilies := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
  {{- $__ipFamiliesSrc := pluck "ipFamilies" .Context .Values }}
  {{- $__ipFamilies := include "base.fmt.slice" (dict "s" ($__ipFamiliesSrc | mustUniq | mustCompact) "c" $__regexIpFamilies) }}
  {{- if $__ipFamilies }}
    {{- nindent 0 "" -}}ipFamilies:
    {{- $__ipFamilies | nindent 0 }}
  {{- end }}

  {{- $__ipFamilyPolicyAllowed := list "SingleStack" "PreferDualStack" "RequireDualStack" }}
  {{- $__ipFamilyPolicy := include "base.string" (coalesce .Context.ipFamilyPolicy .Values.ipFamilyPolicy) }}
  {{- if mustHas $__ipFamilyPolicy $__ipFamilyPolicyAllowed }}
    {{- nindent 0 "" -}}ipFamilyPolicy: {{ $__ipFamilyPolicy }}
  {{- end }}

  {{- $__typeLoadBalancerClassAllowed := list "LoadBalancer" }}
  {{- if mustHas $__type $__typeLoadBalancerClassAllowed }}
    {{- $__loadBalancerClass := include "base.string" (coalesce .Context.loadBalancerClass .Values.loadBalancerClass) }}
    {{- if $__loadBalancerClass }}
      {{- nindent 0 "" -}}loadBalancerClass: {{ $__loadBalancerClass }}
    {{- end }}

    {{- $__regexLoadBalancerIP := "^$|\"\"|^None|((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
    {{- $__loadBalancerIP := include "base.string" (coalesce .Context.loadBalancerIP .Values.loadBalancerIP) }}
    {{- $__loadBalancerIP = include "base.fmt" (dict "s" $__loadBalancerIP "r" $__regexLoadBalancerIP) }}
    {{- if $__loadBalancerIP }}
      {{- nindent 0 "" -}}loadBalancerIP:
      {{- $__loadBalancerIP | nindent 0 }}
    {{- end }}
  {{- end }}

  {{- $__regexLoadBalancerSourceRanges := "^((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}(\\/\\d+)?$" }}
  {{- $__loadBalancerSourceRangesSrc := pluck "loadBalancerSourceRanges" .Context .Values }}
  {{- $__loadBalancerSourceRanges := include "base.fmt.slice" (dict "s" ($__loadBalancerSourceRangesSrc | mustUniq | mustCompact) "c" $__regexLoadBalancerSourceRanges) }}
  {{- if $__loadBalancerSourceRanges }}
    {{- nindent 0 "" -}}loadBalancerSourceRanges:
    {{- $__loadBalancerSourceRanges | nindent 0 }}
  {{- end }}

  {{- $__clean := list }}
  {{- $__portsSrc := pluck "ports" .Context .Values }}
  {{- range ($__portsSrc | mustUniq | mustCompact) }}
    {{- if kindIs "string" . }}
      {{- $__regexSplit :="\\s+|\\s*[\\|,]\\s*" }}
      {{- $__val := mustRegexSplit $__regexSplit . -1 }}
      {{- range $__val }}
        {{- $__regexSplit :=":+" }}
        {{- $__val := mustRegexSplit $__regexSplit . -1 }}
        {{- if eq (len $__val) 2 }}
          {{- $__clean = mustAppend $__clean (dict "clusterIP" $__clusterIP "type" $__type "name" (mustLast $__val) "port" (mustFirst $__val)) }}
        {{- else if eq (len $__val) 3 }}
          {{- $__clean = mustAppend $__clean (dict "clusterIP" $__clusterIP "type" $__type "name" (index $__val 1) "port" (mustFirst $__val) "protocol" (mustLast $__val | upper)) }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean (mustMerge . (dict "clusterIP" $__clusterIP "type" $__type)) }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "string" . }}
          {{- $__regexSplit :="\\s+|\\s*[\\|,]\\s*" }}
          {{- $__val := mustRegexSplit $__regexSplit . -1 }}
          {{- range $__val }}
            {{- $__regexSplit :=":+" }}
            {{- $__val := mustRegexSplit $__regexSplit . -1 }}
            {{- if eq (len $__val) 2 }}
              {{- $__clean = mustAppend $__clean (dict "clusterIP" $__clusterIP "type" $__type "name" (mustLast $__val) "port" (mustFirst $__val)) }}
            {{- else if eq (len $__val) 3 }}
              {{- $__clean = mustAppend $__clean (dict "clusterIP" $__clusterIP "type" $__type "name" (index $__val 1) "port" (mustFirst $__val) "protocol" (mustLast $__val | upper)) }}
            {{- end }}
          {{- end }}
        {{- else if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean (mustMerge . (dict "clusterIP" $__clusterIP "type" $__type)) }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- $__val := list }}
  {{- range ($__clean | mustUniq | mustCompact) }}
    {{- if kindIs "map" . }}
      {{- $__val = mustAppend $__val (dict .port .) }}
    {{- end }}
  {{- end }}
  {{- $__ports := list }}
  {{- range $k, $v := include "base.map.merge" (dict "s" ($__val | mustUniq | mustCompact) "merge" true) | fromYaml }}
    {{- $__ports = mustAppend $__ports (include "definitions.ServicePort" $v | fromYaml) }}
  {{- end }}
  {{- $__ports = $__ports | mustUniq | mustCompact }}
  {{- if $__ports }}
    {{- nindent 0 "" -}}ports:
    {{- toYaml $__ports | nindent 0 }}
  {{- end }}

  {{- $__publishNotReadyAddresses := include "base.bool" (coalesce .Context.publishNotReadyAddresses .Values.publishNotReadyAddresses) }}
  {{- if $__publishNotReadyAddresses }}
    {{- nindent 0 "" -}}publishNotReadyAddresses: {{ $__publishNotReadyAddresses }}
  {{- end }}

  {{- $__typeSelectorAllowed := list "ClusterIP" "NodePort" "LoadBalancer" }}
  {{- if or (empty $__type) (mustHas $__type $__typeSelectorAllowed) }}
    {{- $__selector := dict }}
    {{- $__selectorSrc := pluck "selector" .Context .Values }}
    {{- range ($__selectorSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__selector = mustMerge $__selector . }}
      {{- end }}
    {{- end }}
    {{- /*
      追加 labels 到 selector ，受 ignoreLabels 参数影响
    */ -}}
    {{- $__ignoreLabels := false }}
    {{- if eq ._kind "Namespace" }}
      {{- $__ignoreLabels = include "base.bool" (coalesce .Context.ignoreLabels .Values.ignoreLabels) }}
    {{- end }}
    {{- if not $__ignoreLabels }}
      {{- $__selector = mustMerge $__selector (include "base.labels" . | fromYaml) }}
    {{- end }}
    {{- if $__selector }}
      {{- nindent 0 "" -}}selector:
        {{- toYaml $__selector | nindent 2 }}
    {{- end }}
  {{- end }}

  {{- $__sessionAffinityAllowed := list "ClientIP" "None" }}
  {{- $__sessionAffinity := include "base.string" (coalesce .Context.sessionAffinity .Values.sessionAffinity) }}
  {{- if mustHas $__sessionAffinity $__sessionAffinityAllowed }}
    {{- nindent 0 "" -}}sessionAffinity: {{ $__sessionAffinity }}

    {{- if eq $__sessionAffinity "ClientIP" }}
      {{- $__clean := dict "sessionAffinity" $__sessionAffinity }}
      {{- $__sessionAffinityConfigSrc := pluck "sessionAffinityConfig" .Context .Values }}
      {{- range ($__sessionAffinityConfigSrc | mustUniq | mustCompact) }}
        {{- if kindIs "map" . }}
          {{- $__clean = mustMerge $__clean . }}
        {{- end }}
      {{- end }}
      {{- $__sessionAffinityConfig := include "definitions.SessionAffinityConfig" $__clean | fromYaml }}
      {{- if $__sessionAffinityConfig }}
        {{- nindent 0 "" -}}sessionAffinityConfig:
          {{- toYaml $__sessionAffinityConfig | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- $__typeAllowed := list "ExternalName" "ClusterIP" "NodePort" "LoadBalancer" }}
  {{- if mustHas $__type $__typeAllowed }}
    {{- nindent 0 "" -}}type: {{ $__type }}
  {{- end }}
{{- end }}
