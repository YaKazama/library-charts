{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#secret-v1-core
  - https://kubernetes.io/docs/concepts/configuration/secret/
  descr:
  - type = Opaque 或 kubernetes.io/service-account-token 可以创建空 secret
    - type = kubernetes.io/service-account-token 必需要 annotaions 包括 kubernetes.io/service-account.name
      - 若定义了 annotations , 同时又出现了 serviceAccountName , 则 serviceAccountName 的值会覆盖 annotations 中的值
      - 参考："base.annotations"
*/ -}}
{{- define "configStorage.Secret" -}}
  {{- $_ := set . "_kind" "Secret" }}

  {{- nindent 0 "" -}}apiVersion: v1
  {{- nindent 0 "" -}}kind: {{ ._kind }}
  {{- nindent 0 "" -}}metadata:
    {{- include "definitions.ObjectMeta" . | trim | nindent 2 }}

  {{- $__immutable := include "base.bool" (coalesce .Context.immutable .Values.immutable) }}
  {{- if $__immutable }}
    {{- nindent 0 "" -}}immutable: {{ $__immutable }}
  {{- end }}

  {{- /*
    for type
  */ -}}
  {{- $__typeAllowed := list "Opaque" "kubernetes.io/service-account-token" "kubernetes.io/dockercfg" "kubernetes.io/dockerconfigjson" "kubernetes.io/basic-auth" "kubernetes.io/ssh-auth" "kubernetes.io/tls" "bootstrap.kubernetes.io/token" }}
  {{- $__type := include "base.string" (coalesce .Context.type .Values.type "Opaque") }}
  {{- if mustHas $__type $__typeAllowed }}
    {{- nindent 0 "" -}}type: {{ $__type }}
  {{- end }}

  {{- /*
    for data and stringData
  */ -}}
  {{- $__dataSrc := pluck "data" .Context .Values }}
  {{- $__dataFilesSrc := pluck "dataFiles" .Context .Values }}
  {{- $__data := include "configStorage.Secret.data.parser" (dict "dataSrc" $__dataSrc "dataFilesSrc" $__dataFilesSrc "type" $__type "key" "data" "Files" .Files) | fromYaml }}
  {{- if $__data }}
    {{- toYaml $__data | nindent 0 }}
  {{- end }}

  {{- $__stringDataSrc := pluck "stringData" .Context .Values }}
  {{- $__stringDataFilesSrc := pluck "stringDataFiles" .Context .Values }}
  {{- $__stringData := include "configStorage.Secret.data.parser" (dict "dataSrc" $__stringDataSrc "dataFilesSrc" $__stringDataFilesSrc "type" $__type "key" "stringData" "Files" .Files) | fromYaml }}
  {{- if $__stringData }}
    {{- toYaml $__stringData | nindent 0 }}
  {{- end }}
{{- end }}


{{- /*
  解析 data stringData
  variables:
  - dataSrc: slice of data or stringData
  - dataFilesSrc: slice of dataFiles or stringDataFiles
  - type: one of $__typeAllowed
  - key: one of keywords: data or stringData
  - Files: $.Files
  descr:
  - 优先级
    - data > dataFiles
    - stringData > stringDataFiles
*/ -}}
{{- define "configStorage.Secret.data.parser" -}}
  {{- with . }}
    {{- $__data := dict }}
    {{- range (.dataSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__data = mustMerge $__data . }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "map" . }}
            {{- $__data = mustMerge $__data . }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- $__dataFiles := dict }}
    {{- range (.dataFilesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- range $f, $p := . }}
          {{- $__dataFiles = mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "map" . }}
            {{- range $f, $p := . }}
              {{- $__dataFiles = mustMerge $__dataFiles (dict (base $f) ($.Files.Get $p)) }}
            {{- end }}
          {{- else if kindIs "string" . }}
            {{- $__dataFiles = mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "string" . }}
        {{- $__dataFiles = mustMerge $__dataFiles (dict (base .) ($.Files.Get .)) }}
      {{- end }}
    {{- end }}

    {{- $__dockerType := list "kubernetes.io/dockercfg" "kubernetes.io/dockerconfigjson" }}
    {{- if mustHas .type $__dockerType }}
      {{- $__clean := dict }}

      {{- $__clean = mustMerge $__clean (pick $__data "server" "username" "password" "email") }}

      {{- $__docker := dict }}
      {{- if and (hasKey $__dataFiles ".dockercfg") (eq .type "kubernetes.io/dockercfg") }}
        {{- $_ := set $__docker ".dockercfg" (get $__dataFiles ".dockercfg") }}
      {{- else if and (hasKey $__dataFiles ".dockerconfigjson") (eq .type "kubernetes.io/dockerconfigjson") }}
        {{- $_ := set $__docker ".dockerconfigjson" (get $__dataFiles ".dockerconfigjson") }}
      {{- else }}
        {{- range $f, $p := $__dataFiles }}
          {{- $__clean = mustMerge $__clean (pick ($p | fromYaml) "server" "username" "password" "email") }}
        {{- end }}
      {{- end }}

      {{- if $__clean }}
        {{- $__needKeys := list "server" "username" "password" }}
        {{- range ($__needKeys | mustUniq | mustCompact) }}
          {{- if not (hasKey $__clean .) }}
            {{- fail (printf "configStorage.Secret.data.parser: docker %s not found" .) }}
          {{- end }}
        {{- end }}

        {{- $_ := set $__clean "auth" ((printf "%s:%s" $__clean.username $__clean.password) | b64enc) }}

        {{- $__dockerAuth := dict $__clean.server (pick $__clean "username" "password" "email" "auth") }}
        {{- if eq .type "kubernetes.io/dockercfg" }}
          {{- $_ := set $__docker ".dockercfg" ($__dockerAuth | mustToJson) }}
        {{- else if eq .type "kubernetes.io/dockerconfigjson" }}
          {{- $_ := set $__docker ".dockerconfigjson" (dict "auths" $__dockerAuth | mustToJson) }}
        {{- end }}
      {{- end }}

      {{- $__data = dict }}
      {{- $__dataFiles = $__docker }}
    {{- end }}

    {{- $__basicAuthType := list "kubernetes.io/basic-auth" }}
    {{- if mustHas .type $__basicAuthType }}
      {{- $__clean := dict }}

      {{- $__clean = mustMerge $__clean (pick $__data "username" "password") }}

      {{- range $f, $p := $__dataFiles }}
        {{- $__clean = mustMerge $__clean (pick ($p | fromYaml) "username" "password") }}
      {{- end }}

      {{- if $__clean }}
        {{- $__needKeys := list "username" "password" }}
        {{- range ($__needKeys | mustUniq | mustCompact) }}
          {{- if not (hasKey $__clean .) }}
            {{- fail (printf "configStorage.Secret.data.parser: basic-auth %s not found" .) }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- $__sshAuthType := list "kubernetes.io/ssh-auth" }}
    {{- if mustHas .type $__sshAuthType }}
      {{- $__clean := dict }}

      {{- $__clean = mustMerge $__clean (pick $__data "ssh-privatekey") }}

      {{- if hasKey $__dataFiles "ssh-privatekey" }}
        {{- $__clean = pick $__dataFiles "ssh-privatekey" }}
      {{- else }}
        {{- range $f, $p := $__dataFiles }}
          {{- $__clean = mustMerge $__clean (pick ($p | fromYaml) "ssh-privatekey") }}
        {{- end }}
      {{- end }}

      {{- if $__clean }}
        {{- $__needKeys := list "ssh-privatekey" }}
        {{- range ($__needKeys | mustUniq | mustCompact) }}
          {{- if not (hasKey $__clean .) }}
            {{- fail (printf "configStorage.Secret.data.parser: ssh-auth %s not found" .) }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{- $__data = dict }}
      {{- $__dataFiles = $__clean }}
    {{- end }}

    {{- $__tlsType := list "kubernetes.io/tls" }}
    {{- if mustHas .type $__tlsType }}
      {{- $__clean := dict }}

      {{- $__clean = mustMerge $__clean (pick $__data "tls.crt" "tls.key") }}

      {{- if and (hasKey $__dataFiles "tls.crt") (hasKey $__dataFiles "tls.key") }}
        {{- $__clean = pick $__dataFiles "tls.crt" "tls.key" }}
      {{- else }}
        {{- range $f, $p := $__dataFiles }}
          {{- $__clean = mustMerge $__clean (pick ($p | fromYaml) "tls.crt" "tls.key") }}
        {{- end }}
      {{- end }}

      {{- if $__clean }}
        {{- $__needKeys := list "tls.crt" "tls.keys" }}
        {{- range ($__needKeys | mustUniq | mustCompact) }}
          {{- if not (hasKey $__clean .) }}
            {{- fail (printf "configStorage.Secret.data.parser: tls %s not found" .) }}
          {{- end }}
        {{- end }}
      {{- end }}

      {{- $__data = dict }}
      {{- $__dataFiles = $__clean }}
    {{- end }}

    {{- $__tokenType := list "bootstrap.kubernetes.io/token" }}
    {{- if mustHas .type $__tokenType }}
      {{- $__clean := dict }}

      {{- $__clean = mustMerge $__clean (pick $__data "token-id" "token-secret") }}

      {{- range $f, $p := $__dataFiles }}
        {{- $__clean = mustMerge $__clean (pick ($p | fromYaml) "token-id" "token-secret") }}
      {{- end }}

      {{- if $__clean }}
        {{- $__needKeys := list "token-id" "token-secret" }}
        {{- range ($__needKeys | mustUniq | mustCompact) }}
          {{- if not (hasKey $__clean .) }}
            {{- fail (printf "configStorage.Secret.data.parser: token %s not found" .) }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- if or $__data $__dataFiles }}
      {{- nindent 0 "" -}}{{ .key }}:
      {{- if eq .key "data" }}
        {{- range $k, $v := $__data }}
          {{- $k | nindent 2 }}: {{ toString $v | b64enc }}
        {{- end }}
        {{- range $k, $v := $__dataFiles }}
          {{- $k | nindent 2 }}: |
            {{- $v | b64enc | nindent 4 }}
        {{- end }}
      {{- else if eq .key "stringData" }}
        {{- range $k, $v := $__data }}
          {{- $k | nindent 2 }}: {{ toString $v }}
        {{- end }}
        {{- range $k, $v := $__dataFiles }}
          {{- $k | nindent 2 }}: |
            {{- $v | nindent 4 }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  获取 token-id

  variables:
  - dataSrc: slice of data or stringData
  - dataFilesSrc: slice of dataFiles or stringDataFiles
  - Files: $.Files
  descr:
  - 优先级
    - data > dataFiles
    - stringData > stringDataFiles
*/ -}}
{{- define "configStorage.Secret.getTokenID" -}}
  {{- with . }}
    {{- $__clean := dict }}
    {{- range (.dataSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}

    {{- range (.dataFilesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- range $f, $p := . }}
          {{- $__clean = mustMerge $__clean (dict (base $f) ($.Files.Get $p)) }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- $__clean = mustMerge $__clean (dict (base .) ($.Files.Get .)) }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- $__tokenID := include "base.string" (get $__clean "token-id") }}
    {{- if $__tokenID }}
      {{- printf "bootstrap-token-%s" $__tokenID }}
    {{- else }}
      {{- fail "configStorage.Secret.getTokenID: Secret[bootstrap.kubernetes.io/token] token-id not found" }}
    {{- end }}
  {{- end }}
{{- end }}
