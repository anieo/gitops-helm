{{- define "namespace" -}}
{{- if and (.namespace) (or (eq .create_namespace nil) (eq .create_namespace true)) }}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ .namespace }}
{{- end }}
{{- end -}}
#######################################
{{- define "sync.policy" -}}
syncPolicy:
  automated:
  {{- if or (eq .heal true) (eq .heal nil) }}
      selfHeal: true
  {{- end }}
  {{- if or (eq .prune true) (eq .prune nil) }}
      prune: true
  {{- end }}
  syncOptions:     
  {{- if .create_namespace }}
      - CreateNamespace=true
  {{- end }}
      
{{- end -}}
#########################
{{- define "application" }}
{{- template "namespace" (dict "namespace" .namespace "create_namespace" .create_namespace ) }}

---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .name }} 
  namespace: argocd
spec:
  destination:
    namespace: {{ .namespace }}
    server: {{ .server | default "https://kubernetes.default.svc" }} 
  project: {{ .project | default "base" }}
{{ include "sync.policy" . | indent 2}}
  source: 
    repoURL: {{ .repo }}
    targetRevision: {{ .version }} 
    {{- if .chart }}
    chart: {{.chart }}
    {{- end }}
    {{- if .path }}
    path: {{.path }}
    {{- end }}
    helm:
      releaseName: {{ .name }}
{{- end -}}
######################################
{{- define "kafka.ui.clusters" -}}
{{- with . -}}
{{- range $cluster, $value := . }}
  - name: {{ $cluster }}
    bootstrapServers: {{ $cluster }}-kafka-bootstrap:9092
{{- end -}}
{{- end -}}
{{- end -}}
######################################
{{- define "vector.sources" -}}
{{- with . -}}
{{/*{{- printf "\n" }}*/}}
{{toYaml . }}
{{- end -}}
{{- end -}}
######################################
{{- define "vector.services" -}}
{{- with . -}}
{{- range $service := . }}
{{$service.name}}:
  type: kafka
  inputs:
{{toYaml $service.sources | indent 4}}
  bootstrap_servers: test-kafka-brokers.kafka.svc.cluster.local:9092
  topic: {{$service.topic}}
  compression: none
  encoding:
    codec: {{$service.format}}
{{- end -}}
{{- end -}}
{{- end -}}
