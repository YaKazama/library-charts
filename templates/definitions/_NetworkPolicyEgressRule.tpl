{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#networkpolicyegressrule-v1-networking-k8s-io
*/ -}}
{{- define "definitions.NetworkPolicyEgressRule" -}}
  {{- with . }}
    {{- if not (kindIs "map" .) }}
      {{- fail "not support! the type must be map." }}
    {{- end }}

    {{- /*
      .ports
    */ -}}
    {{- $__clean := list }}
    {{- $__regexSplit := "\\s+|\\s*[\\|,]\\s*" }}
    {{- $__regexCheckPorts := "^(\\d+|[a-z][a-z0-9]*[a-z])(-\\d+)?([/](TCP|tcp|UDP|udp|SCTP|sctp))?$" }}
    {{- $__protocolAllowed := list "TCP" "UDP" "SCTP" }}
    {{- if or (kindIs "int" .ports) (kindIs "float64" .ports) }}
      {{- $__clean = mustAppend $__clean (dict "port" .ports) }}
    {{- else if kindIs "string" .ports }}
      {{- range (mustRegexSplit $__regexSplit .ports -1 | mustUniq | mustCompact) }}
        {{- $__port := "" }}
        {{- $__endPort := "" }}
        {{- $__protocol := "" }}
        {{- if regexMatch $__regexCheckPorts . }}
          {{- $__val := mustRegexSplit "[/]+" . -1 }}
          {{- if has (mustLast $__val | upper) $__protocolAllowed }}
            {{- $__protocol = index $__val 1 }}
          {{- end }}
          {{- $__valPortRange := mustRegexSplit "[-]+" (mustFirst $__val) -1 }}
          {{- if eq (len $__valPortRange) 2 }}
            {{- $__port = mustFirst $__valPortRange }}
            {{- $__endPort = mustLast $__valPortRange }}
          {{- else if eq (len $__valPortRange) 1 }}
            {{- $__port = mustFirst $__valPortRange }}
          {{- end }}
        {{- end }}
        {{- $__clean = mustAppend $__clean (dict "port" $__port "endPort" $__endPort "protocol" $__protocol) }}
      {{- end }}
    {{- else if kindIs "map" .ports }}
      {{- $__clean = mustAppend $__clean (dict "port" (dig "port" "" .ports) "endPort" (dig "endPort" "" .ports) "protocol" (dig "protocol" "" .ports)) }}
    {{- else if kindIs "slice" .ports }}
      {{- range (.ports | mustUniq | mustCompact) }}
        {{- if or (kindIs "int" .) (kindIs "float64" .) }}
          {{- $__clean = mustAppend $__clean (dict "port" .) }}
        {{- else if kindIs "string" . }}
          {{- range (mustRegexSplit $__regexSplit . -1 | mustUniq | mustCompact) }}
            {{- $__port := "" }}
            {{- $__endPort := "" }}
            {{- $__protocol := "" }}
            {{- if regexMatch $__regexCheckPorts . }}
              {{- $__val := mustRegexSplit "[/]+" . -1 }}
              {{- if has (mustLast $__val | upper) $__protocolAllowed }}
                {{- $__protocol = index $__val 1 }}
              {{- end }}
              {{- $__valPortRange := mustRegexSplit "[-]+" (mustFirst $__val) -1 }}
              {{- if eq (len $__valPortRange) 2 }}
                {{- $__port = mustFirst $__valPortRange }}
                {{- $__endPort = mustLast $__valPortRange }}
              {{- else if eq (len $__valPortRange) 1 }}
                {{- $__port = mustFirst $__valPortRange }}
              {{- end }}
            {{- end }}
            {{- $__clean = mustAppend $__clean (dict "port" $__port "endPort" $__endPort "protocol" $__protocol) }}
          {{- end }}
        {{- else if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean (dict "port" (dig "port" "" .) "endPort" (dig "endPort" "" .) "protocol" (dig "protocol" "" .)) }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__ports := list }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- $__ports = mustAppend $__ports (include "definitions.NetworkPolicyPort" . | fromYaml) }}
    {{- end }}
    {{- if $__ports | mustUniq | mustCompact }}
      {{- nindent 0 "" -}}ports:
      {{- toYaml $__ports | nindent 0 }}
    {{- end }}

    {{- /*
      .to
    */ -}}
    {{- $__clean := list }}
    {{- if kindIs "slice" .to }}
      {{- $__clean = concat $__clean .to }}
    {{- else if kindIs "map" .to }}
      {{- $__clean = mustAppend $__clean .to }}
    {{- end }}
    {{- $__to := list }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- $__to = mustAppend $__to (include "definitions.NetworkPolicyPeer" . | fromYaml) }}
    {{- end }}
    {{- if $__to | mustUniq | mustCompact }}
      {{- nindent 0 "" -}}to:
      {{- toYaml $__to | nindent 0 }}
    {{- end }}

  {{- end }}
{{- end }}
