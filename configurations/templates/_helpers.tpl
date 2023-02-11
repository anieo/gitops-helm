{{- define "namespace" -}}
{{- if and (.namespace) (eq .create_namespace true) }}
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
---
{{- template "namespace" (dict "namespace" .namespace "create_namespace" .create_namespace ) }}
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .name }}-solution
  namespace: argocd
spec:
  destination:
    namespace: {{ .namespace }}
    server: {{ .server | default "https://kubernetes.default.svc" }} 
  project: {{ .project | default "solution" }}
{{ include "sync.policy" . | indent 2}}
  source: 
    repoURL: {{ .repo | default "https://github.com/anieo/gitops-helm.git"}}
    targetRevision: {{ .version | default "main"}} 
    {{- if .chart }}
    chart: {{.chart }}
    {{- end }}
    {{- if .path }}
    path: {{.path }}
    {{- end }}
    helm:
      releaseName: {{ .name }}
      values: |
{{toYaml .configs | indent 8}}
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