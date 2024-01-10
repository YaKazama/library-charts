{{- define "definitions.HTTPGetAction" -}}
  {{- with . }}
    {{- $__host := include "base.string" .host }}
    {{- if $__host }}
      {{- nindent 0 "" -}}host: {{ $__host }}
    {{- end }}

    {{- $__clean := dict }}
    {{- if kindIs "map" .httpHeaders }}
      {{- if and .httpHeaders.name .httpHeaders.value }}
        {{- $__clean = mustMerge $__clean (dict .httpHeaders.name .httpHeaders.value) }}
        {{- $_ := unset .httpHeaders "name" }}
        {{- $_ := unset .httpHeaders "value" }}
      {{- end }}
      {{- range $k, $v := .httpHeaders }}
        {{- $__clean = mustMerge $__clean (dict $k $v) }}
      {{- end }}
    {{- else if kindIs "slice" .httpHeaders }}
      {{- range .httpHeaders }}
        {{- if kindIs "map" . }}
          {{- if and .name .value }}
            {{- $__clean = mustMerge $__clean (dict .name .value) }}
            {{- $_ := unset . "name" }}
            {{- $_ := unset . "value" }}
          {{- end }}
          {{- range $k, $v := . }}
            {{- $__clean = mustMerge $__clean (dict $k $v) }}
          {{- end }}
        {{- else if kindIs "string" . }}
          {{- $__regexSplit := ":" }}
          {{- $__val := mustRegexSplit $__regexSplit . -1 }}
          {{- if eq (len $__val) 2 }}
            {{- $__clean = mustMerge $__clean (dict (mustFirst $__val) (mustLast $__val)) }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "string" .httpHeaders }}
      {{- $__regexSplit := ":" }}
      {{- $__val := mustRegexSplit $__regexSplit .httpHeaders -1 }}
      {{- if eq (len $__val) 2 }}
        {{- $__clean = mustMerge $__clean (dict (mustFirst $__val) (mustLast $__val)) }}
      {{- end }}
    {{- end }}
    {{- $__httpHeaders := list }}
    {{- range $k, $v := $__clean }}
      {{- $__httpHeaders = mustAppend $__httpHeaders (include "definitions.HTTPHeader" (dict "name" $k "value" $v) | fromYaml) }}
    {{- end }}
    {{- $__httpHeaders = $__httpHeaders | mustUniq | mustCompact }}
    {{- if $__httpHeaders }}
      {{- nindent 0 "" -}}httpHeaders:
        {{- toYaml $__httpHeaders | nindent 0 }}
    {{- end }}

    {{- $__path := include "base.string" .path }}
    {{- if $__path }}
      {{- nindent 0 "" -}}path: {{ $__path }}
    {{- end }}

    {{- $__port := include "base.int.scope" (list .port 1 65535) }}
    {{- if $__port }}
      {{- nindent 0 "" -}}port: {{ $__port }}
    {{- end }}

    {{- $__scheme := include "base.string" .scheme }}
    {{- if $__scheme }}
      {{- nindent 0 "" -}}scheme: {{ $__scheme | upper }}
    {{- end }}
  {{- end }}
{{- end }}
