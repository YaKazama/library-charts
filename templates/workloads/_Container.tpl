{{- /*
  reference:
  - https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#container-v1-core
*/ -}}
{{- define "workloads.Container" -}}
  {{- with .container }}
    {{- $__regexSplit := "\\s+" }}
    {{- $__args := include "base.fmt.slice" (dict "s" (list .args) "r" $__regexSplit "sliceRedirect" true) }}
    {{- if $__args }}
      {{- nindent 0 "" -}}args:
      {{- $__args | indent 0 }}
    {{- end }}

    {{- $__regexSplit := "\\s+" }}
    {{- $__command := include "base.fmt.slice" (dict "s" (list .command) "r" $__regexSplit "sliceRedirect" true) }}
    {{- if $__command }}
      {{- nindent 0 "" -}}command:
      {{- $__command | indent 0 }}
    {{- end }}

    {{- $__envSrc := pluck "env" . $.Context $.Values }}
    {{- $__envFilesSrc := pluck "envFiles" . $.Context $.Values }}
    {{- $__env := include "workloads.Container.env" (dict "envFilesSrc" $__envFilesSrc "envSrc" $__envSrc "Files" $.Files) }}
    {{- if $__env }}
      {{- nindent 0 "" -}}env:
      {{- $__env | indent 0 }}
    {{- end }}

    {{- $__envFromSrc := pluck "envFrom" . $.Context $.Values }}
    {{- $__envFromFilesSrc := pluck "envFromFiles" . $.Context $.Values }}
    {{- $__envFrom := include "workloads.Container.envFrom" (dict "envFromFilesSrc" $__envFromFilesSrc "envFromSrc" $__envFromSrc "Files" $.Files) }}
    {{- if $__envFrom }}
      {{- nindent 0 "" -}}envFrom:
      {{- $__envFrom | indent 0 }}
    {{- end }}

    {{- $__imageSrc := pluck "image" . $.Context $.Values }}
    {{- $__imageFilesSrc := pluck "imageFiles" . $.Context $.Values }}
    {{- /*
      imageDisableOverwrite: map ，用于控制在 initContainers 中是否读取 $.Values.image
      - image: bool, true/false 是否加载 $.Values.image
      - repository: bool, true/false 是否加载 $.Values.image.repository
      - tag: bool, true/false 是否加载 $.Values.image.tag
    */ -}}
    {{- if and $.isInitContainer $.imageDisableOverwrite }}
      {{- $__val := mustDeepCopy $.Values }}
      {{- if $__val.image }}
        {{- if $.imageDisableOverwrite.repository }}
          {{- $_ := unset $__val.image "repository" }}
        {{- end }}
        {{- if $.imageDisableOverwrite.tag }}
          {{- $_ := unset $__val.image "tag" }}
        {{- end }}
        {{- if $.imageDisableOverwrite.image }}
          {{- $_ := unset $__val "image" }}
        {{- end }}
      {{- end }}
      {{- $__imageSrc = pluck "image" . $.Context $__val }}
    {{- end }}
    {{- $__image := include "workloads.Container.image" (dict "imageFilesSrc" $__imageFilesSrc "imageSrc" $__imageSrc "Files" $.Files) }}
    {{- if $__image }}
      {{- nindent 0 "" -}}image: {{ $__image }}

      {{- $__regexImageLatest := ".*:latest$" }}
      {{- $__isLatest := mustRegexMatch $__regexImageLatest $__image }}
      {{- $__defaultImagePullPolicy := "Always" }}
      {{- if not $__isLatest }}
        {{- $__defaultImagePullPolicy = "IfNotPresent" }}
      {{- end }}
      {{- $__imagePullPolicyAllowed := list "Always" "Never" "IfNotPresent" }}
      {{- $__imagePullPolicy := include "base.string" (coalesce .imagePullPolicy $.Context.imagePullPolicy $.Values.imagePullPolicy) }}
      {{- if mustHas $__imagePullPolicy $__imagePullPolicyAllowed }}
        {{- nindent 0 "" -}}imagePullPolicy: {{ coalesce $__imagePullPolicy $__defaultImagePullPolicy }}
      {{- end }}
    {{- end }}

    {{- $__clean := dict }}
    {{- $__lifecycleSrc := pluck "lifecycle" . $.Context $.Values }}
    {{- range ($__lifecycleSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}
    {{- $__lifecycle := include "definitions.Lifecycle" (pick $__clean "postStart" "preStop") | fromYaml }}
    {{- if $__lifecycle }}
      {{- nindent 0 "" -}}lifecycle:
        {{- toYaml $__lifecycle | nindent 2 }}
    {{- end }}

    {{- $__livenessProbeSrc := pluck "livenessProbe" . $.Context $.Values }}
    {{- $__clean := dict "__probeType" "livenessProbe" }}
    {{- range ($__livenessProbeSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}
    {{- $__livenessProbe := include "definitions.Probe" $__clean | fromYaml }}
    {{- if $__livenessProbe }}
      {{- nindent 0 "" -}}livenessProbe:
        {{- toYaml $__livenessProbe | nindent 2 }}
    {{- end }}


    {{- $__name := coalesce .name (printf "%s-%s" (include "base.fullname" $) (randAlphaNum 5)) }}
    {{- if $__name }}
      {{- nindent 0 "" -}}name: {{ $__name }}
    {{- end }}

    {{- $__clean := list }}
    {{- if kindIs "string" .ports }}
      {{- $__regexSplit := "\\s+|\\s*[\\|\\:,]\\s*" }}
      {{- range (mustRegexSplit $__regexSplit .ports -1 | mustUniq | mustCompact) }}
        {{- $__clean = mustAppend $__clean (dict "containerPort" .) }}
      {{- end }}
    {{- else if or (kindIs "int" .ports) (kindIs "float64" .ports) }}
      {{- $__clean = mustAppend $__clean (dict "containerPort" .ports) }}
    {{- else if kindIs "map" .ports }}
      {{- $__clean = mustAppend $__clean .ports }}
    {{- else if kindIs "slice" .ports }}
      {{- range (.ports | mustUniq | mustCompact) }}
        {{- if kindIs "string" . }}
          {{- $__regexSplit := "\\s+|\\s*[\\|\\:,]\\s*" }}
          {{- range (mustRegexSplit $__regexSplit . -1 | mustUniq | mustCompact) }}
            {{- $__clean = mustAppend $__clean (dict "containerPort" .) }}
          {{- end }}
        {{- else if or (kindIs "int" .) (kindIs "float64" .) }}
          {{- $__clean = mustAppend $__clean (dict "containerPort" .) }}
        {{- else if kindIs "map" . }}
          {{- $__clean = mustAppend $__clean . }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__ports := list }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- $__ports = mustAppend $__ports (include "definitions.ContainerPort" . | fromYaml) }}
    {{- end }}
    {{- $__ports = $__ports | mustUniq | mustCompact }}
    {{- if $__ports }}
      {{- nindent 0 "" -}}ports:
      {{- toYaml $__ports | nindent 0 }}
    {{- end }}

    {{- $__readinessProbeSrc := pluck "readinessProbe" . $.Context $.Values }}
    {{- $__clean := dict "__probeType" "readinessProbe" }}
    {{- range ($__readinessProbeSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}
    {{- $__readinessProbe := include "definitions.Probe" $__clean | fromYaml }}
    {{- if $__readinessProbe }}
      {{- nindent 0 "" -}}readinessProbe:
        {{- toYaml $__readinessProbe | nindent 2 }}
    {{- end }}

    {{- $__resourceNameAllowed := list "cpu" "memory" }}
    {{- $__restartPolicyAllowed := list "NotRequired" "RestartContainer" }}
    {{- $__clean := list }}
    {{- $__resizePolicySrc := pluck "resizePolicy" . $.Context $.Values }}
    {{- range ($__resizePolicySrc | mustUniq | mustCompact) }}
      {{- if kindIs "string" . }}
        {{- $__clean = mustAppend $__clean . }}
      {{- else if kindIs "map" . }}
        {{- with . }}
          {{- if and .resourceName .restartPolicy }}
            {{- $__clean = mustAppend $__clean (dict .resourceName .restartPolicy) }}
          {{- end }}
          {{- if and .name .policy }}
            {{- $__clean = mustAppend $__clean (dict .name .policy) }}
          {{- end }}
          {{- range $k, $v := (omit . "resourceName" "restartPolicy" "name" "policy") }}
            {{- if and (mustHas $k $__resourceNameAllowed) (mustHas $v $__restartPolicyAllowed) }}
              {{- $__clean = mustAppend $__clean (dict $k $v) }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "string" . }}
            {{- $__clean = mustAppend $__clean . }}
          {{- else if kindIs "map" . }}
            {{- with . }}
              {{- if and .resourceName .restartPolicy }}
                {{- $__clean = mustAppend $__clean (dict .resourceName .restartPolicy) }}
              {{- end }}
              {{- if and .name .policy }}
                {{- $__clean = mustAppend $__clean (dict .name .policy) }}
              {{- end }}
              {{- range $k, $v := (omit . "resourceName" "restartPolicy" "name" "policy") }}
                {{- if and (mustHas $k $__resourceNameAllowed) (mustHas $v $__restartPolicyAllowed) }}
                  {{- $__clean = mustAppend $__clean (dict $k $v) }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__val := dict }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- with (include "definitions.ContainerResizePolicy" . | fromYaml) }}
        {{- $__val = mustMerge $__val (dict .resourceName .restartPolicy) }}
      {{- end }}
    {{- end }}
    {{- $__resizePolicy := list }}
    {{- range $k, $v := $__val }}
      {{- $__resizePolicy = mustAppend $__resizePolicy (dict "resourceName" $k "restartPolicy" $v) }}
    {{- end }}
    {{- $__resizePolicy = $__resizePolicy | mustUniq |mustCompact }}
    {{- if $__resizePolicy }}
      {{- nindent 0 "" -}}resizePolicy:
      {{- toYaml $__resizePolicy | nindent 0 }}
    {{- end }}

    {{- $__clean := dict }}
    {{- $__resourcesSrc := pluck "resources" . $.Context $.Values }}
    {{- range ($__resourcesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}
    {{- $__resourcesFilesSrc := pluck "resourcesFiles" . $.Context $.Values }}
    {{- range ($__resourcesFilesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__regexSplit := "\\.|\\:" }}
        {{- range $f, $p := . }}
          {{- $__val := $.Files.Get $f | fromYaml }}
          {{- if $__val }}
            {{- range (mustRegexSplit $__regexSplit $p -1) }}
              {{- $__val = dig . "" $__val }}
            {{- end }}
          {{- end }}
          {{- if $__val }}
            {{- $__clean = mustMerge $__clean $__val }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "workloads.Container: resourcesFiles not support, please use map" }}
      {{- end }}
    {{- end }}
    {{- $__resources := include "definitions.ResourceRequirements" $__clean | fromYaml }}
    {{- if $__resources }}
      {{- nindent 0 "" -}}resources:
        {{- toYaml $__resources | nindent 2 }}
    {{- end }}

    {{- $__restartPolicy := include "base.string" .restartPolicy }}
    {{- if and $__restartPolicy $.isInitContainer }}
      {{- nindent 0 "" -}}restartPolicy: Always
    {{- end }}

    {{- $__securityContextSrc := pluck "securityContext" . $.Context $.Values }}
    {{- $__clean := dict }}
    {{- range ($__securityContextSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}
    {{- $__securityContext := include "definitions.SecurityContext" $__clean | fromYaml }}
    {{- if $__securityContext }}
      {{- nindent 0 "" -}}securityContext:
        {{- toYaml $__securityContext | nindent 2 }}
    {{- end }}

    {{- $__startupProbeSrc := pluck "startupProbe" . $.Context $.Values }}
    {{- $__clean := dict "__probeType" "startupProbe" }}
    {{- range ($__startupProbeSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustMerge $__clean . }}
      {{- end }}
    {{- end }}
    {{- $__startupProbe := include "definitions.Probe" $__clean | fromYaml }}
    {{- if $__startupProbe }}
      {{- nindent 0 "" -}}startupProbe:
        {{- toYaml $__startupProbe | nindent 2 }}
    {{- end }}

    {{- $__stdin := include "base.bool" (coalesce .stdin $.Context.stdin $.Values.stdin) }}
    {{- if $__stdin }}
      {{- nindent 0 "" -}}stdin: {{ $__stdin }}
    {{- end }}

    {{- $__stdinOnce := include "base.bool" (coalesce .stdinOnce $.Context.stdinOnce $.Values.stdinOnce) }}
    {{- if $__stdinOnce }}
      {{- nindent 0 "" -}}stdinOnce: {{ $__stdinOnce }}
    {{- end }}

    {{- $__terminationMessagePath := include "base.string" .terminationMessagePath }}
    {{- if isAbs $__terminationMessagePath }}
      {{- nindent 0 "" -}}terminationMessagePath: {{ $__terminationMessagePath }}
    {{- end }}

    {{- $__terminationMessagePolicy := include "base.string" .terminationMessagePolicy }}
    {{- if $__terminationMessagePolicy }}
      {{- nindent 0 "" -}}terminationMessagePolicy: {{ $__terminationMessagePolicy }}
    {{- end }}

    {{- $__tty := include "base.bool" (coalesce .tty $.Context.tty $.Values.tty) }}
    {{- if $__tty }}
      {{- nindent 0 "" -}}tty: {{ $__tty }}
    {{- end }}

    {{- $__clean := list }}
    {{- $__volumeDevicesSrc := pluck "volumeDevices" . $.Context $.Values }}
    {{- range ($__volumeDevicesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "string" . }}
        {{- $__regexSplit := "\\s+" }}
        {{- $__val := mustRegexSplit $__regexSplit . -1 }}
        {{- range ($__val | mustUniq | mustCompact) }}
          {{- $__clean = mustAppend $__clean . }}
        {{- end }}
      {{- else if kindIs "map" . }}
        {{- with . }}
          {{- if and .name .devicePath }}
            {{- $__clean = mustAppend $__clean (dict .name .devicePath) }}
          {{- end }}
          {{- range $k, $v := (omit . "name" "devicePath") }}
            {{- $__clean = mustAppend $__clean (dict $k $v) }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "string" . }}
            {{- $__regexSplit := "\\s+" }}
            {{- $__val := mustRegexSplit $__regexSplit . -1 }}
            {{- range ($__val | mustUniq | mustCompact) }}
              {{- $__clean = mustAppend $__clean . }}
            {{- end }}
          {{- else if kindIs "map" . }}
            {{- with . }}
              {{- if and .name .devicePath }}
                {{- $__clean = mustAppend $__clean (dict .name .devicePath) }}
              {{- end }}
              {{- range $k, $v := (omit . "name" "devicePath") }}
                {{- $__clean = mustAppend $__clean (dict $k $v) }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__val := dict }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- with (include "definitions.VolumeDevice" . | fromYaml) }}
        {{- $__val = mustMerge $__val (dict .name .devicePath) }}
      {{- end }}
    {{- end }}
    {{- $__volumeDevices := list }}
    {{- range $k, $v := $__val }}
      {{- $__volumeDevices = mustAppend $__volumeDevices (dict "name" $k "devicePath" $v) }}
    {{- end }}
    {{- $__volumeDevices = $__volumeDevices | mustUniq |mustCompact }}
    {{- if $__volumeDevices }}
      {{- nindent 0 "" -}}volumeDevices:
      {{- toYaml $__volumeDevices | nindent 0 }}
    {{- end }}

    {{- $__clean := list }}
    {{- $__volumeMountsSrc := pluck "volumeMounts" . $.Context $.Values }}
    {{- range $__volumeMountsSrc }}
      {{- if kindIs "string" . }}
        {{- $__regexSplit := "\\s+|\\s*[\\|,]\\s*" }}
        {{- $__valVolmeMounts := mustRegexSplit $__regexSplit . -1 }}
        {{- range ($__valVolmeMounts | mustUniq | mustCompact) }}
          {{- $__regexSplit := ":+" }}
          {{- $__val := mustRegexSplit $__regexSplit . -1 }}
          {{- if eq (len $__val) 2 }}
            {{- $__clean = mustAppend $__clean (dict "name" (mustFirst $__val) "mountPath" (mustLast $__val)) }}
          {{- else if eq (len $__val) 3 }}
            {{- $__clean = mustAppend $__clean (dict "name" (mustFirst $__val) "mountPath" (index $__val 1) "subPath" (mustLast $__val)) }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "map" . }}
        {{- with . }}
          {{- if or .mountPath .mountPropagation .name .readOnly .subPath .subPathExpr }}
            {{- $__clean = mustAppend $__clean (pick . "mountPath" "mountPropagation" "name" "readOnly" "subPath" "subPathExpr") }}
          {{- end }}
          {{- range $k, $v := (omit . "mountPath" "mountPropagation" "name" "readOnly" "subPath" "subPathExpr") }}
            {{- $__clean = mustAppend $__clean (dict "name" $k "mountPath" $v) }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if kindIs "string" . }}
            {{- $__regexSplit := "\\s+|\\s*[\\|,]\\s*" }}
            {{- $__valVolmeMounts := mustRegexSplit $__regexSplit . -1 }}
            {{- range ($__valVolmeMounts | mustUniq | mustCompact) }}
              {{- $__regexSplit := ":+" }}
              {{- $__val := mustRegexSplit $__regexSplit . -1 }}
              {{- if eq (len $__val) 2 }}
                {{- $__clean = mustAppend $__clean (dict "name" (mustFirst $__val) "mountPath" (mustLast $__val)) }}
              {{- else if eq (len $__val) 3 }}
                {{- $__clean = mustAppend $__clean (dict "name" (mustFirst $__val) "mountPath" (index $__val 1) "subPath" (mustLast $__val)) }}
              {{- end }}
            {{- end }}
          {{- else if kindIs "map" . }}
            {{- with . }}
              {{- if or .mountPath .mountPropagation .name .readOnly .subPath .subPathExpr }}
                {{- $__clean = mustAppend $__clean (pick . "mountPath" "mountPropagation" "name" "readOnly" "subPath" "subPathExpr") }}
              {{- end }}
              {{- range $k, $v := (omit . "mountPath" "mountPropagation" "name" "readOnly" "subPath" "subPathExpr") }}
                {{- $__clean = mustAppend $__clean (dict "name" $k "mountPath" $v) }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- $__val := list }}
    {{- $__keys := list }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- if not (mustHas .mountPath $__keys) }}
        {{- $__keys = mustAppend $__keys .mountPath }}
        {{- $__val = mustAppend $__val . }}
      {{- end }}
    {{- end }}
    {{- $__volumeMounts := list }}
    {{- range ($__val | mustUniq | mustCompact) }}
      {{- $__volumeMounts = mustAppend $__volumeMounts (include "definitions.VolumeMount" . | fromYaml) }}
    {{- end }}
    {{- $__volumeMounts = $__volumeMounts | mustUniq | mustCompact }}
    {{- if $__volumeMounts }}
      {{- nindent 0 "" -}}volumeMounts:
      {{- toYaml $__volumeMounts | nindent 0 }}
    {{- end }}


    {{- $__workingDir := include "base.string" (coalesce .workingDir $.Context.workingDir $.Values.workingDir) }}
    {{- if isAbs $__workingDir }}
      {{- nindent 0 "" -}}workingDir: {{ coalesce $__workingDir "/" }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  解析 env

  descr:
  - envFilesSrc: 所有出现的 envFiles 组成的列表，包括以下三个
    - $.Values.envFilesSrc $.Context.envFilesSrc .envFilesSrc
  - envSrc: 所有出现的 envFiles 组成的列表，包括以下三个
    - $.Values.env $.Context.env .env
  - Files: 父域中的 Files (父域中的 Files 也是从上一个父域中传入的)
*/ -}}
{{- define "workloads.Container.env" -}}
  {{- with .}}
    {{- $__clean := list }}

    {{- range (.envSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- if and .name .value }}
          {{- $__clean = mustAppend $__clean (dict "name" .name "value" .value) }}
        {{- else if and .name .valueFrom (empty .value) }}
          {{- $__clean = mustAppend $__clean (dict "name" .name "valueFrom" .valueFrom) }}
        {{- end }}
        {{- range $k, $v := (omit . "name" "value" "valueFrom") }}
          {{- if kindIs "string" $v }}
            {{- $__clean = mustAppend $__clean (dict "name" $k "value" $v) }}
          {{- else if kindIs "map" $v }}
            {{- $__clean = mustAppend $__clean (dict "name" $k "valueFrom" $v) }}
          {{- end }}
        {{- end }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- if and .name .value }}
            {{- $__clean = mustAppend $__clean (dict "name" .name "value" .value) }}
          {{- else if and .name .valueFrom (empty .value) }}
            {{- $__clean = mustAppend $__clean (dict "name" .name "valueFrom" .valueFrom) }}
          {{- end }}
          {{- range $k, $v := (omit . "name" "value" "valueFrom") }}
            {{- if kindIs "string" $v }}
              {{- $__clean = mustAppend $__clean (dict "name" $k "value" $v) }}
            {{- else if kindIs "map" $v }}
              {{- $__clean = mustAppend $__clean (dict "name" $k "valueFrom" $v) }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "workloads.Container.env: env not support, please use map or slice" }}
      {{- end }}
    {{- end }}

    {{- range (.envFilesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__regexSplit := "\\.|\\:" }}
        {{- if .r }}
          {{- $__regexSplit = .r }}
        {{- end }}

        {{- range $f, $p := . }}
          {{- $__val := $.Files.Get $f | fromYaml }}
          {{- $__keys := mustRegexSplit $__regexSplit $p -1 | mustUniq | mustCompact }}
          {{- if $__val }}
            {{- range $__keys }}
              {{- $__val = dig . "" $__val }}
            {{- end }}
          {{- end }}

          {{- if $__val }}
            {{- if kindIs "string" $__val }}
              {{- $__clean = mustMerge $__clean (dict "name" (mustLast $__keys) "value" $__val) }}
            {{- else if kindIs "map" $__val }}
              {{- with $__val }}
                {{- if and .name .value }}
                  {{- $__clean = mustAppend $__clean (dict "name" .name "value" .value) }}
                {{- else if and .name .valueFrom (empty .value) }}
                  {{- $__clean = mustAppend $__clean (dict "name" .name "valueFrom" .valueFrom) }}
                {{- end }}
                {{- range $k, $v := (omit . "name" "value" "valueFrom") }}
                  {{- if kindIs "string" $v }}
                    {{- $__clean = mustAppend $__clean (dict "name" $k "value" $v) }}
                  {{- else if kindIs "map" $v }}
                    {{- $__clean = mustAppend $__clean (dict "name" $k "valueFrom" $v) }}
                  {{- end }}
                {{- end }}
              {{- end }}
            {{- else if kindIs "slice" $__val }}
              {{- range $__val }}
                {{- if and .name .value }}
                  {{- $__clean = mustAppend $__clean (dict "name" .name "value" .value) }}
                {{- else if and .name .valueFrom (empty .value) }}
                  {{- $__clean = mustAppend $__clean (dict "name" .name "valueFrom" .valueFrom) }}
                {{- end }}
                {{- range $k, $v := (omit . "name" "value" "valueFrom") }}
                  {{- if kindIs "string" $v }}
                    {{- $__clean = mustAppend $__clean (dict "name" $k "value" $v) }}
                  {{- else if kindIs "map" $v }}
                    {{- $__clean = mustAppend $__clean (dict "name" $k "valueFrom" $v) }}
                  {{- end }}
                {{- end }}
              {{- end }}

            {{- end }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "workloads.Container.env: envFiles not support, please use map." }}
      {{- end }}
    {{- end }}

    {{- $__env := list }}
    {{- $__val := list }}
    {{- range $_, $v := (include "base.map.merge.single" (dict "s" $__clean "k" "name") | fromYaml) }}
      {{- $__val = mustAppend $__val $v }}
    {{- end }}
    {{- range ($__val | mustUniq | mustCompact) }}
      {{- $__env = mustAppend $__env (include "definitions.EnvVar" . | fromYaml) }}
    {{- end }}
    {{- if $__env }}
      {{- toYaml $__env | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  解析 envFrom

  descr:
  - envFromFilesSrc: 所有出现的 envFromFiles 组成的列表，包括以下三个
    - $.Values.envFromFilesSrc $.Context.envFromFilesSrc .envFromFilesSrc
  - envFromSrc: 所有出现的 envFromFiles 组成的列表，包括以下三个
    - $.Values.envFrom $.Context.envFrom .envFrom
  - Files: 父域中的 Files (父域中的 Files 也是从上一个父域中传入的)
*/ -}}
{{- define "workloads.Container.envFrom" -}}
  {{- with . }}
    {{- $__clean := list }}

    {{- range (.envFromSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__clean = mustAppend $__clean (pick . "configMapRef" "prefix" "secretRef") }}
      {{- else if kindIs "slice" . }}
        {{- range . }}
          {{- $__clean = mustAppend $__clean (pick . "configMapRef" "prefix" "secretRef") }}
        {{- end }}
      {{- else }}
        {{- fail "workloads.Container.envFrom: envFrom not support, please use map or slice" }}
      {{- end }}
    {{- end }}

    {{- range (.envFromFilesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- $__regexSplit := "\\.|\\:" }}
        {{- if .r }}
          {{- $__regexSplit = .r }}
        {{- end }}

        {{- range $f, $p := . }}
          {{- $__val := $.Files.Get $f | fromYaml }}
          {{- $__keys := mustRegexSplit $__regexSplit $p -1 | mustUniq | mustCompact }}
          {{- if $__val }}
            {{- range $__keys }}
              {{- $__val = dig . "" $__val }}
            {{- end }}
          {{- end }}

          {{- if $__val }}
            {{- if kindIs "map" $__val }}
              {{- $__clean = mustAppend $__clean (pick $__val "configMapRef" "prefix" "secretRef") }}
            {{- else if kindIs "slice" $__val }}
              {{- range $__val }}
                {{- $__clean = mustAppend $__clean (pick . "configMapRef" "prefix" "secretRef") }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- else }}
        {{- fail "workloads.Container.envFrom: envFromFiles not support, please use map." }}
      {{- end }}
    {{- end }}

    {{- $__envFrom := list }}
    {{- range ($__clean | mustUniq | mustCompact) }}
      {{- $__envFrom = mustAppend $__envFrom (include "definitions.EnvFromSource" . | fromYaml) }}
    {{- end }}
    {{- if $__envFrom }}
      {{- toYaml $__envFrom | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  解析 image

  descr:
  - imageFilesSrc: 所有出现的 imageFiles 组成的列表，包括以下三个
    - .imageFilesSrc $.Context.imageFilesSrc $.Values.imageFilesSrc
  - imageSrc: 所有出现的 imageFiles 组成的列表，包括以下三个
    - .image $.Context.image $.Values.image
  - Files: 父域中的 Files (父域中的 Files 也是从上一个父域中传入的)
*/ -}}
{{- define "workloads.Container.image" -}}
  {{- with . }}
    {{- $__imageStr := dict "image" "" "repository" "" "tag" "" }}
    {{- $__repository := dict }}
    {{- $__tag := dict }}

    {{- /*
      image
    */ -}}
    {{- range (.imageSrc | mustUniq | mustCompact) }}
      {{- if kindIs "string" . }}
        {{- $_ := set $__imageStr "image" . }}
      {{- else if kindIs "map" . }}
        {{- if .repository }}
          {{- if kindIs "string" .repository }}
            {{- $_ := set $__imageStr "repository" (include "base.fmt.slice" (dict "s" (list .repository) "separators" "/")) }}
          {{- else if kindIs "map" .repository }}
            {{- $__repository = mustMerge $__repository .repository }}
          {{- end }}
        {{- end }}
        {{- if .tag }}
          {{- if kindIs "string" .tag }}
            {{- $_ := set $__imageStr "tag" (include "base.fmt.slice" (dict "s" (list .tag) "separators" "-")) }}
          {{- else if kindIs "map" .tag }}
            {{- $__tag = mustMerge $__tag .tag }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- /*
      imageFiles
    */ -}}
    {{- $__regexSplit := coalesce $.r "\\.|:+" }}
    {{- range (.imageFilesSrc | mustUniq | mustCompact) }}
      {{- if kindIs "map" . }}
        {{- range $f, $p := . }}
          {{- $__val := $.Files.Get $f | fromYaml }}
          {{- $__keys := mustRegexSplit $__regexSplit $p -1 | mustUniq | mustCompact }}
          {{- if $__val }}
            {{- range $__keys }}
              {{- $__val = dig . "" $__val }}
            {{- end }}
          {{- end }}

          {{- if $__val }}
            {{- with $__val }}
              {{- if kindIs "string" . }}
                {{- $__imageStr = mustMerge $__imageStr (dict "image" .) }}
              {{- else if kindIs "map" . }}
                {{- if .repository }}
                  {{- if kindIs "string" .repository }}
                    {{- $__imageStr = mustMerge $__imageStr (dict "repository" (include "base.fmt.slice" (dict "s" (list .repository) "separators" "/"))) }}
                  {{- else if kindIs "map" .repository }}
                    {{- $__repository = mustMerge $__repository .repository }}
                  {{- end }}
                {{- end }}
                {{- if .tag }}
                  {{- if kindIs "string" .tag }}
                    {{- $__imageStr = mustMerge $__imageStr (dict "tag" (include "base.fmt.slice" (dict "s" (list .tag) "separators" "-"))) }}
                  {{- else if kindIs "map" .tag }}
                    {{- $__tag = mustMerge $__tag .tag }}
                  {{- end }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}

    {{- /*
      repository
    */ -}}
    {{- with $__repository }}
      {{- $__val :="" }}
      {{- if or (kindIs "string" .) (kindIs "slice" .) }}
        {{- $__val = include "base.fmt.slice" (dict "s" (list .) "separators" "/") }}
      {{- else if kindIs "map" . }}
        {{- $__val = include "workloads.Container.image.parser" (dict "m" . "sequence" (list "url" "namespace" "name") "default" "" "separators" "/" "keyToLast" false) }}
      {{- end }}
      {{- $__imageStr = mustMerge $__imageStr (dict "repository" $__val) }}
    {{- end }}

    {{- /*
      tag
    */ -}}
    {{- with $__tag }}
      {{- $__val :="" }}
      {{- if or (kindIs "string" .) (kindIs "slice" .) }}
        {{- $__val = include "base.fmt.slice" (dict "s" (list .) "separators" "-") }}
      {{- else if kindIs "map" . }}
        {{- $__val = include "workloads.Container.image.parser" (dict "m" . "sequence" (list "build" "project" "commit" "dataCommit") "default" "" "separators" "-" "keyToLast" true) }}
      {{- end }}
      {{- $__imageStr = mustMerge $__imageStr (dict "tag" $__val) }}
    {{- end }}

    {{- if $__imageStr.image }}
      {{- $__imageStr.image }}
    {{- else if and $__imageStr.repository $__imageStr.tag }}
      {{- printf "%s:%s" $__imageStr.repository $__imageStr.tag }}
    {{- else }}
      {{- fail (printf "workloads.Container.image: repository or tag not found. repository: %s, tag:%s" $__repository $__tag) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  解析 images.repository image.tag

  descr:
  - m: map 需要解析的数据
  - sequence: slice 需要从数据中单独取值并移除的 key (按照传入列表的顺序依次取值). 当 .m 为 Map 时有效
  - default: string 默认值，默认为空字符串
  - separators: string 分隔符，默认为 ""
  - keyToLast: bool 是否将按 .k 列表取的值放到 $__val 列表的最后 (为 false 时会将值插入到列表的倒数第 2 个位置), 当 .m 为 Map 时有效. 默认 false
*/ -}}
{{- define "workloads.Container.image.parser" -}}
  {{- with . }}
    {{- /*
      deepCopy 解决 $ 父作用域中 .image 中的内容被 unset 操作移除的问题
    */ -}}
    {{- $__m := .m }}
    {{- $__sequence := .sequence }}
    {{- $__default := coalesce .default "" }}
    {{- $__separators := coalesce .separators "" }}
    {{- $__keyToLast := coalesce (include "base.bool" .keyToLast) false }}

    {{- if kindIs "map" $__m }}
      {{- $__clean := list }}

      {{- if $__sequence }}
        {{- range ($__sequence | mustUniq | mustCompact) }}
          {{- $__val := get $__m . }}
          {{- if hasKey $__m . }}
            {{- $_ := unset $__m . }}
          {{- end }}
          {{- /*
            namespace 可以输入字符串或列表
          */ -}}
          {{- if eq . "namespace" }}
            {{- $__regexSplit := "\\s+|\\s*[\\|\\:\\/,]\\s*" }}
            {{- $__val = include "base.fmt.slice" (dict "s" (list $__val) "separators" "/" "r" $__regexSplit) }}
          {{- end }}
          {{- $__clean = mustAppend $__clean $__val }}
        {{- end }}
      {{- end }}

      {{- /*
        - .repository 移除 url namespace name 后, 如果还有其他值, 则使用 values 函数生成的列表中的值作为 namespace 的补充拼接到 namespace 和 name 之间
        - .tag 移除 project buildId commit dataCommit 后, 如果还有其他值, 则使用 values 函数生成的列表中的值作为后缀拼接到 tag 上
        - values 函数取出的列表, 使用 sortAlpha 进行排序
      */ -}}
      {{- if $__m }}
        {{- $__val := $__m | sortAlpha | mustUniq | mustCompact }}
        {{- if $__keyToLast }}
          {{- $__clean = concat $__clean $__val }}
        {{- else }}
          {{- $__clean = mustAppend (concat (mustInitial $__clean) $__val) (mustLast $__clean) }}
        {{- end }}
      {{- end }}

      {{- join $__separators ($__clean | mustCompact) }}
    {{- else }}
      {{- $__default }}
    {{- end }}
  {{- end }}
{{- end }}
