{{- define "definitions.VolumeDevice" -}}
  {{- with . }}
    {{- $__name := "" }}
    {{- $__path := "" }}

    {{- if kindIs "string" . }}
      {{- $__regexSplit := ":" }}

      {{- $__val := mustRegexSplit $__regexSplit . -1 }}
      {{- if eq (len $__val) 2 }}
        {{- $__name = mustFirst $__val }}
        {{- $__path = mustLast $__val }}
      {{- end }}
    {{- else if kindIs "map" . }}
      {{- $__val := dict }}
      {{- $__clean := list }}

      {{- if and .name .devicePath }}
        {{- $__val = mustMerge $__val (dict .name .devicePath) }}
      {{- end }}
      {{- range $k, $v := (omit . "name" "devicePath") }}
        {{- $__val = mustMerge $__val (dict $k $v) }}
      {{- end }}

      {{- range $k, $v := $__val }}
        {{- $__name = $k }}
        {{- $__path = $v }}
      {{- end }}
    {{- else if kindIs "slice" . }}
      {{- range . }}
        {{- if kindIs "string" . }}
          {{- $__regexSplit := ":" }}

          {{- $__val := mustRegexSplit $__regexSplit . -1 }}
          {{- if eq (len $__val) 2 }}
            {{- $__name = mustFirst $__val }}
            {{- $__path = mustLast $__val }}
          {{- end }}
        {{- else if kindIs "map" . }}
          {{- $__val := dict }}
          {{- $__clean := list }}

          {{- if and .name .devicePath }}
            {{- $__val = mustMerge $__val (dict .name .devicePath) }}
          {{- end }}
          {{- range $k, $v := (omit . "name" "devicePath") }}
            {{- $__val = mustMerge $__val (dict $k $v) }}
          {{- end }}

          {{- range $k, $v := $__val }}
            {{- $__name = $k }}
            {{- $__path = $v }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if and $__name $__path }}
      {{- nindent 0 "" -}}devicePath: {{ $__path }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}
  {{- end }}
{{- end }}
