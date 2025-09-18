{{/*
Helper Templates for Kompass Insights
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "zesty-k8s.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zesty-k8s.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Chart.Name }}
      {{- .Chart.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Chart.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "zesty-k8s.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a version as used by the chart and image tag.
*/}}
{{- define "zesty-k8s.version" -}}
  {{ default .Chart.AppVersion .Values.image.tag  }}
{{- end }}


{{/*
Create a name for the SA.
*/}}
{{- define "zesty-k8s.serviceAccountName" -}}
  {{ printf "%s-sa" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the PVC.
*/}}
{{- define "zesty-k8s.pvcname" -}}
  {{ printf "%s-db-pvc" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the external-secret.
*/}}
{{- define "zesty-k8s.externalSecret.awsCred" -}}
  {{ printf "%s-aws-cluster-secret" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the ConfigMap.
*/}}
{{- define "zesty-k8s.configmap" -}}
  {{ printf "%s-cm" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the ClusterRole.
*/}}
{{- define "zesty-k8s.clusterrole" -}}
  {{ printf "%s-clusterRole" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the ClusterRoleBinding.
*/}}
{{- define "zesty-k8s.clusterrolebinding" -}}
  {{ printf "%s-clusterRoleBinding" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the Role.
*/}}
{{- define "zesty-k8s.role" -}}
  {{ printf "%s-role" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the RoleBinding.
*/}}
{{- define "zesty-k8s.rolebinding" -}}
  {{ printf "%s-roleBinding" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
Create a name for the Service.
*/}}
{{- define "zesty-k8s.svc" -}}
  {{ printf "%s-svc" (include "zesty-k8s.fullname" .) }}
{{- end -}}

{{/*
All of the relevant verbs.
*/}}
{{- define "zesty-k8s.verbs" -}}
verbs:
  - get
  - list
  {{- if .Values.admission.enabled }}
  - patch
  {{- end }}
  - watch
{{- end -}}

{{- define "zesty-k8s.labels" -}}
helm.sh/chart: {{ include "zesty-k8s.chart" . }}
{{ include "zesty-k8s.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zesty-k8s.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zesty-k8s.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "zesty-k8s.victoriaMetrics.endpoint" -}}
    {{- if and .Values.global .Values.global.victoriaMetricsRemoteUrl }}
        {{- .Values.global.victoriaMetricsRemoteUrl -}}
    {{- else -}}
        http://kompass-victoria-metrics:8428
    {{- end }}
{{- end }}

{{- define "zesty-k8s.victoriaMetrics.name" -}}
    {{- if and .Values.global .Values.global.victoriaMetricsNameOverride }}
        {{- .Values.global.victoriaMetricsNameOverride -}}
    {{- else -}}
        kompass-victoria-metrics
    {{- end }}
{{- end }}

{{- define "zesty-k8s.exposedMetrics.port" -}}
{{- default "9003" .Values.insights.metrics.port }}
{{- end }}

{{- define "zesty-k8s.recommendations.fullname" -}}
 {{ printf "%s-recommendations" (include "zesty-k8s.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}