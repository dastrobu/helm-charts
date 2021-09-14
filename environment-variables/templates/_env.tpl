{{/*
Render environment variables in topological sorted order.
*/}}
{{- define "environment-variables.env.v1" -}}
    {{- $env := . | default dict -}}

    {{- if not ( kindIs "map" $env ) -}}
      {{- fail (printf "expected a map but got %s, value is:\n%s" (kindOf $env) ( $env | toYaml ) ) }}
    {{- end -}}

    {{- $graph := dict -}}

    {{- range $name, $var := $env -}}
        {{- if $var -}}
            {{- if not $var.dependentOn -}}
                {{- $_ := set $graph $name ( list ) -}}
            {{- else if kindIs "string" $var.dependentOn -}}
                {{- $_ := set $graph $name ( list $var.dependentOn ) -}}
            {{- else if kindIs "slice" $var.dependentOn -}}
                {{- $_ := set $graph $name $var.dependentOn -}}
            {{- else -}}
              {{- fail (printf "bad value for dependentOn:\n%s" ( $var.dependentOn | toYaml ) ) }}
            {{- end -}}
        {{- end -}}
    {{- end -}}

    {{- $args := dict "graph" $graph "out" list -}}
    {{- include "environment-variables.kahn.v1" $args -}}

    {{- $envList := list }}
    {{- range $name := $args.out -}}
        {{- $envItem := omit ( get $env $name ) "dependentOn" -}}
        {{- $envItem = set $envItem "name" $name -}}
        {{- $envList = append $envList $envItem -}}
    {{- end -}}

    {{- if not ( empty $envList ) -}}
        {{- $envList | toYaml -}}
    {{- end -}}
{{- end }}

