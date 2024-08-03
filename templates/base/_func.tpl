{{- /*
  遍历嵌套的字典，从值列表中选择键。参考： dig

  variables:
  - m: Map 源数据
  - k: 以分隔符分隔的键字符串
    - 分隔符："."、":"
  - default: 默认值，默认返回空符字串
*/ -}}
{{- define "base.map.getVal" -}}
  {{- $__regexSplit := "\\.|\\:" }}

  {{- $__keyList := mustRegexSplit $__regexSplit .k -1 }}
  {{- $__keyCount := len $__keyList }}
  {{- $__firstKey := first $__keyList }}

  {{- if hasKey .m $__firstKey }}
    {{- if eq $__keyCount 1 }}
      {{- get .m $__firstKey | toYaml }}
    {{- else }}
      {{- include "base.map.getVal" (dict "m" (get .m $__firstKey) "k" (join "." (mustRest $__keyList))) }}
    {{- end }}
  {{- else }}
    {{- coalesce .default "" }}
  {{- end }}
{{- end }}



{{- /*
  将其他类型转为字符串。include 的所有输出都是字符串

  TODO:
  - 是否将其进行分拆？
    - 不同类型的数据分别进行检查，如果 values.yaml 中输入的内容不是指定格式则报错
      - 对齐 API 文档中的类型
    - 拆分后的内容，参考：
      - base.check.bool
      - base.check.int
      - base.check.string

  descr:
  - float64 => int
    - 如果超长，则会变为 int 类型的最大值
  - bool
    - "true"
    - "false"
  - string
    - 1. 判断是否以 "0" 开头
      - 是，使用正则表达式去掉开头的所有 "0" 值直到第一个非 "0" 值
    - 2. 使用 atoi 将其转为 int 类型
*/ -}}
{{- define "base.toa" -}}
  {{- $__val := . }}

  {{- if kindIs "invalid" . }}
    {{- $__val = "" }}
  {{- else if kindIs "float64" . }}
    {{- $__val = int . }}
  {{- else if kindIs "bool" . }}
    {{- if . }}
      {{- $__val = "true" }}
    {{- else }}
      {{- $__val = "false" }}
    {{- end }}
  {{- else if kindIs "string" . }}
    {{- if mustRegexMatch "^\\d+$" ($__clean := (mustRegexReplaceAll "^0+" . "")) }}
      {{- $__val = atoi $__clean }}
      {{- if eq $__val 9223372036854775807 }}
        {{- $__val = $__clean }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- if $__val }}
    {{- $__val }}
  {{- end }}
{{- end }}


{{- /*
  检查 map 类型。传入的是一个 map 类型的数据 (object) 或 nil

  descr:
  - 是
    - true  => toYaml 后的结果
    - false => 不作任何处理
  - 否 => 打印报错信息
  - nil => nil
*/ -}}
{{- define "base.map" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if kindIs "map" . }}
      {{- if . }}
        {{- toYaml . }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.map: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  传入一个包含 map 的列表，返回一个按 key 合并后的 map 。

  variables:
  - s: slice 包含一个或多个 map
  - k: string 合并标识，即按此值进行合并，会作为新的 map 的键
  descr:
  - 返回 map
  - 如果源 map 中没有 k 对应的键，则会被丢弃
*/ -}}
{{- define "base.map.merge.single" -}}
  {{- with . }}
    {{- $__key := .k }}

    {{- $__val := dict }}
    {{- range .s }}
      {{- if hasKey . $__key }}
        {{- $__val = mustMerge $__val (dict (get . $__key) .) }}
      {{- end }}
    {{- end }}

    {{- toYaml $__val | nindent 0 }}
  {{- end }}
{{- end }}


{{- /*
  将列表中的 map 元素按照 key 合并，返回 map 类型
  与 base.map.merge 相比，更为复杂

  src: [map[key1:map[a:a b:b]] map:[key1:[map[a:a]]] map:[key2:[map[c:c]]]]
  return: map[key1:[map[a:a b:b] map[a:a]] key2:[map[c:c]]]

  variables:
  - s: slice 需要处理的列表，其中的值为 map 类型
  - merge: 是否合并子 map
    - 合并，则返回一个合并后的子 map
    - 不合并，则会将所有子 map 放到一个列表中
  descr:
  - merge=false 可用于处理 IngressRules (ingress.rules), IngressTLS (ingress.spec.tls)
  - merge=true 可用于处理 ServiceSpec (service.spec.ports)
*/ -}}
{{- define "base.map.merge" -}}
  {{- $__s := .s }}
  {{- $__merge := false }}
  {{- if .merge }}
    {{- $__merge = true }}
  {{- end }}

  {{- $__val := dict }}
  {{- range .s }}
    {{- if kindIs "map" . }}
      {{- range $k, $v := . }}
        {{- if not (hasKey $__val $k) }}
          {{- if kindIs "map" $v }}
            {{- if $__merge }}
              {{- $__val = mustMerge $__val (dict $k $v) }}
            {{- else }}
              {{- $__val = mustMerge $__val (dict $k (list $v)) }}
            {{- end }}
          {{- else if kindIs "slice" $v }}
            {{- if $__merge }}
              {{- range $v }}
                {{- $__val = mustMerge $__val . }}
              {{- end }}
            {{- else }}
              {{- $__val = mustMerge $__val (dict $k $v) }}
            {{- end }}
          {{- end }}
        {{- else }}
          {{- $__valTmp := list }}
          {{- if kindIs "map" $v }}
            {{- $__valTmp = mustAppend $__valTmp $v }}
          {{- else if kindIs "slice" $v }}
            {{- $__valTmp = concat $__valTmp $v }}
          {{- end }}

          {{- if $__merge }}
            {{- $__valMerge := dict }}
            {{- range $__valTmp }}
              {{- $__valMerge = mustMerge (get $__val $k) . }}
            {{- end }}
            {{- $_ := set $__val $k $__valMerge }}
          {{- else }}
            {{- $_ := set $__val $k (concat (get $__val $k) $__valTmp) }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- toYaml $__val | nindent 0 }}
{{- end }}


{{- /*
  检查 bool 类型。传入的是一个非空字符串

  descr:
  - 是
    - true  => "true"
    - false => 不作任何处理
  - 否 => 打印报错信息
  - nil => nil
*/ -}}
{{- define "base.bool" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if kindIs "bool" . }}
      {{- if . }}
        {{- "true" }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.bool: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  功能与 base.bool 相同，但允许使用 false 值。传入的是一个 slice ( list )

  descr:
  - 是
    - true  => "true"
    - false => "false"
  - 否 => 打印报错信息
  - 传入的列表可以由内置的 pluck 函数生成
*/ -}}
{{- define "base.bool.false" -}}
  {{- range . }}
    {{- if kindIs "bool" . }}
      {{- if . }}
        {{- "true" }}
      {{- else }}
        {{- "false" }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.bool.false: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 float64 / int / int64 类型。传入的是一个数字或数字字符串

  descr:
  - 是 =>
    - 空 => 不作任何处理
    - 非空 => int .
  - 否 => 打印报错信息
  - nil => nil
  - 0 被视为无效，即为空
*/ -}}
{{- define "base.int" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if or (kindIs "float64" .) (kindIs "int" .) (kindIs "int64" .) }}
      {{- if . }}
        {{- int . }}
      {{- end }}
    {{- else if kindIs "string" . }}
      {{- if mustRegexMatch "^[+-]?[1-9]\\d*$" . }}
        {{- $__val := atoi . }}
        {{- if $__val }}
          {{- $__val }}
        {{- end }}
      {{- else }}
        {{- fail (print "base.int: invalid! Values: " .) }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.int: not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  功能与 base.int 相同，但允许使用 0 值。传入的是一个 slice ( list )

  descr:
  - 传入的列表可以由内置的 pluck 函数生成
  - 数字字符串被视为合法
*/ -}}
{{- define "base.int.zero" -}}
  {{- range . }}
    {{- if not (kindIs "invalid" .) }}
      {{- if or (kindIs "float64" .) (kindIs "int" .) (kindIs "int64" .) }}
        {{- int . }}
      {{- else if kindIs "string" . }}
        {{- if mustRegexMatch "^[+-]?\\d+$" . }}
          {{- /*
            atoi 似乎不是必需的
          */ -}}
          {{- atoi . }}
        {{- else }}
          {{- fail (printf "base.int.zero: invalid! Values: " .) }}
        {{- end }}
      {{- else }}
        {{- fail (print "base.int.zero: not support! Values: " .) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  功能与 base.int.zero 相同，但范围是自定义的。传入的是一个 slice (list)

  variables:
  - slice
    - s: 需要检查的值
    - start: 范围起始值，最小值包括此值
    - end: 范围结束值，最大值包括此值
  descr:
  - 格式: [int, start, end]
    - 匹配范围: start <= s <= end
  - 数字字符串被视为合法
  - 返回 s 的值或打印报错信息
*/ -}}
{{- define "base.int.scope" -}}
  {{- $__s := include "base.int.zero" (index . 0 | list) }}
  {{- $__start := include "base.int.zero" (index . 1 | list) }}
  {{- $__end := include "base.int.zero" (index . 2 | list) }}

  {{- if not (or (kindIs "invalid" $__s) (empty $__s)) }}
    {{- if and (ge (int $__s) (int $__start)) (le (int $__s) (int $__end)) }}
      {{- int $__s }}
    {{- else }}
      {{- fail (printf "base.int.scope: invalid. Values: %s Scope: [%s, %s]" (toString $__s) (toString $__start) (toString $__end)) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 float64 类型。传入的是一个 float64 或 float64 字符串

  descr:
  - 是 =>
    - 空 => 不作任何处理
    - 非空 => int .
  - 否 => 打印报错信息
  - nil => nil
*/ -}}
{{- define "base.float" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if kindIs "float64" . }}
      {{- if . }}
        {{- float64 . }}
      {{- end }}
    {{- else if kindIs "string" . }}
      {{- if mustRegexMatch "^[+-]?[1-9]\\d*\\.\\d+$" . }}
        {{- . }}
      {{- else }}
        {{- fail (print "base.float: invalid! Values: " .) }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.float: not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  功能与 base.float 相同，但允许使用 0 值。传入的是一个 slice ( list )

  descr:
  - 传入的列表可以由内置的 pluck 函数生成
  - 数字字符串被视为合法
*/ -}}
{{- define "base.float.zero" -}}
  {{- range . }}
    {{- if not (kindIs "invalid" .) }}
      {{- if kindIs "float64" . }}
        {{- float64 . }}
      {{- else if kindIs "string" . }}
        {{- if mustRegexMatch "^[+-]?\\d+\\.\\d+$" . }}
          {{- . | trim }}
        {{- else }}
          {{- fail (printf "base.float.zero: invalid! Values: " .) }}
        {{- end }}
      {{- else }}
        {{- fail (print "base.float.zero: not support! Values: " .) }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  功能与 base.int.scope 相同，但范围是自定义的。传入的是一个 slice (list)

  variables:
  - slice
    - s: 需要检查的值
    - start: 范围起始值，最小值包括此值
    - end: 范围结束值，最大值包括此值
  descr:
  - 格式: [int, start, end]
    - 匹配范围: start <= s <= end
  - 数字字符串被视为合法
  - 返回 s 的值或打印报错信息
*/ -}}
{{- define "base.float.scope" -}}
  {{- $__s := include "base.float.zero" (index . 0 | list) }}
  {{- $__start := include "base.float.zero" (index . 1 | list) }}
  {{- $__end := include "base.float.zero" (index . 2 | list) }}

  {{- if not (or (kindIs "invalid" $__s) (empty $__s)) }}
    {{- if and (ge (float64 $__s) (float64 $__start)) (le (float64 $__s) (float64 $__end)) }}
      {{- float64 $__s }}
    {{- else }}
      {{- fail (printf "base.float.scope: invalid. Values: %s Scope: [%s, %s]" (toString $__s) (toString $__start) (toString $__end)) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 string 类型。传入的是一个非空字符串

  descr:
  - 是 => 去掉开头 "0" 值和前后空格的字符串
  - 否 => 打印报错信息
*/ -}}
{{- define "base.string" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if kindIs "string" . }}
      {{- mustRegexReplaceAll "^0+" . "" | trim }}
    {{- else }}
      {{- fail (print "base.string: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 string 类型。传入的是一个非空字符串

  descr:
  - 是 => 去掉前后空格的字符串，
    - 若字符串全为 "0+"，则会去重并返回 "0"，适用于 UID="0000" 这种情况
    - 若字符串以 "^0+" 开头，则只保留一个 "0"，适用于 UMASK="022" 这种情况
  - 否 => 打印报错信息
*/ -}}
{{- define "base.string.zero" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if kindIs "string" . }}
      {{- if mustRegexMatch "^0+$" . }}
        {{- "0" }}
      {{- else }}
        {{- mustRegexReplaceAll "^0+" . "0" | trim }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.string: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 string 类型。传入的是一个非空字符串，允许显示指定空字符串 ""
  variables:
  - s: 需要检查的字符串
  - empty: 是否允许出现空字符串 ""
  descr:
  - 非空字符串
    - 是 => 去掉开头 "0" 值和前后空格的字符串
    - 否 => 打印报错信息
*/ -}}
{{- define "base.string.empty" -}}
  {{- if not (kindIs "invalid" .s) }}
    {{- if kindIs "string" .s }}
      {{- if and .empty (not .s) }}
        {{- "" | quote }}
      {{- else }}
        {{- mustRegexReplaceAll "^0+" .s "" | trim }}
      {{- end }}
    {{- else }}
      {{- fail (print "base.string: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 octal 类型。传入的是一个非空字符串

  descr:
  - 使用正则进行检查
*/ -}}
{{- define "base.octal" -}}
  {{- if not (kindIs "invalid" .) }}
    {{- if mustRegexMatch "^0[0124]{3}$" (toString .) }}
      {{- . }}
    {{- else }}
      {{- fail (print "base.octal: type not support! Values: " .) }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  检查 nil

  descr:
  - 返回字符串 true / nil
*/ -}}
{{- define "base.nil" -}}
  {{- if kindIs "invalid" . }}
    {{- "true" }}
  {{- end }}
{{- end }}


{{- define "base.slice" -}}
  {{- with . }}
    {{- . }}
  {{- end }}
{{- end }}


{{- /*
  使用正则表达式检查字符串是否合法

  variables:
  - s: 需要处理的字符串
  - r: 正则表达式
    - 若此值存在，则 s 中的字符串，需要满足此正则
*/ -}}
{{- define "base.fmt" -}}
  {{- $__val := .s }}
  {{- $__regex := .r }}

  {{- /*
    匹配正则表达式
    - 当正则表达式有值时
      - 匹配则返回 s 的值
      - 不匹配则报错
    - 当正则表达式没有值时
      - 直接返回 s 的值
  */ -}}
  {{- if not (kindIs "invalid" $__val) }}
    {{- if $__regex }}
      {{- if $__val }}
        {{- if or (kindIs "float64" $__val) (kindIs "int" $__val) (kindIs "int64" $__val) }}
          {{- $__val = $__val | int | toString }}
        {{- end }}
        {{- if mustRegexMatch $__regex $__val }}
          {{- $__val }}
        {{- else }}
          {{- fail (print "base.fmt: regex not match. Values: " $__val " Regex: " $__regex ) }}
        {{- end }}
      {{- end }}
    {{- else }}
      {{- $__val }}
    {{- end }}
  {{- end }}
{{- end }}


{{- /*
  variables:
  - s: 需要处理的列表，其中的值可以是指定格式的字符串或列表
    - string: a, b,c d
    - slice / list:
      - [a, b, c]
      - [{name: a}, {name: b}]
  - r: 用于分隔字符串的正则表达式，当 s 中的值为字符串时有效
    - 分隔符
      - " "
      - ","
      - "|"
      - ":"
  - c: 用于检查字符串的正则表达式，当清洗后的值为字符串时有效
  - define: 定义的模板名称，用于处理清洗后的数据
  - atoi: 是否将数字字符串转为整型
  - empty: 是否允许出现空字符串 ""
  - separators: 分隔符，用于将列表转为字符串时使用
  - unUniq: 是否列表去重. 默认为 false
    - false, 表示不去重
    - true, 表示需要去重
  - sliceRedirect: 列表是否直接展示. 默认为 false
  - tom: 是否将结果放到 map 中
    - 返回的 map 的键固定为 "__tom"
  descr:
  - 应对 string array 格式
  - 返回 join 后的字符串
*/ -}}
{{- define "base.fmt.slice" -}}
  {{- $__regexSplit := "\\s+|\\s*[\\|\\:,]\\s*" }}
  {{- $__regexCheck := "" }}
  {{- $__separators := "" }}
  {{- $__define := "base.slice" }}
  {{- $__atoi := false }}
  {{- $__empty := false }}
  {{- $__unUniq := false }}
  {{- $__sliceRedirect := false }}
  {{- $__tom := false }}

  {{- $__val := list }}
  {{- $__clean := list }}

  {{- if .r }}
    {{- $__regexSplit = .r }}
  {{- end }}
  {{- if .c }}
    {{- $__regexCheck = .c }}
  {{- end }}
  {{- if .define }}
    {{- $__define = .define }}
  {{- end }}
  {{- if .separators }}
    {{- $__separators = .separators }}
  {{- end }}
  {{- if .atoi }}
    {{- $__atoi = .atoi }}
  {{- end }}
  {{- if .empty }}
    {{- $__empty = .empty }}
  {{- end }}
  {{- if .unUniq }}
    {{- $__unUniq = .unUniq }}
  {{- end }}
  {{- if .sliceRedirect }}
    {{- $__sliceRedirect = .sliceRedirect }}
  {{- end }}
  {{- if .tom }}
    {{- $__tom = .tom }}
  {{- end }}

  {{- range .s }}
    {{- if kindIs "string" . }}
      {{- $__clean = concat $__clean (mustRegexSplit $__regexSplit . -1) }}
    {{- else if kindIs "slice" . }}
      {{- if $__sliceRedirect }}
        {{- $__clean = . }}
      {{- else }}
        {{- range . }}
          {{- if kindIs "string" . }}
            {{- $__clean = concat $__clean (mustRegexSplit $__regexSplit . -1) }}
          {{- else }}
            {{- $__clean = concat $__clean . }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- else if kindIs "map" . }}
      {{- $__clean = mustAppend $__clean . }}
    {{- else if or (kindIs "float64" .) (kindIs "int" .) (kindIs "int64" .) }}
      {{- $__clean = mustAppend $__clean . }}
    {{- end }}
  {{- end }}

  {{- range $__clean }}
    {{- if and $__regexCheck (kindIs "string" .) }}
      {{- if not (mustRegexMatch $__regexCheck .) }}
        {{- fail (printf "base.fmt.slice: invalid. Value: %s Regex: %s" . $__regexCheck) }}
      {{- end }}
    {{- end }}

    {{- $__v := include $__define . | fromYaml }}
    {{- if hasKey $__v "Error" }}
      {{- if and $__atoi (kindIs "string" .) }}
        {{- if mustRegexMatch "^\\d+$" . }}
          {{- $__v = atoi . }}
        {{- end }}
      {{- else }}
        {{- $__v = . }}
      {{- end }}
    {{- end }}
    {{- $__val = mustAppend $__val $__v }}
  {{- end }}

  {{- if not $__unUniq }}
    {{- $__val = $__val | mustUniq }}
  {{- end }}
  {{- if not $__empty }}
    {{- $__val = $__val | mustCompact }}
  {{- end }}

  {{- if $__val }}
    {{- if $__separators }}
      {{- join $__separators $__val }}
    {{- else }}
      {{- if $__empty }}
        {{- $__valTmp := list }}

        {{- range $__val }}
          {{- if . }}
            {{- $__valTmp = mustAppend $__valTmp . }}
          {{- else }}
            {{- $__valTmp = mustAppend $__valTmp "" }}
          {{- end }}
        {{- end }}

        {{- $__val = $__valTmp }}
      {{- end }}

      {{- if $__tom }}
        {{- nindent 0 "" -}}__tom:
      {{- end }}
      {{- toYaml $__val | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}
