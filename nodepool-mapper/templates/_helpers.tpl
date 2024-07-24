{{/*
Expand the name of the chart.
*/}}
{{- define "nodepool-mapper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nodepool-mapper.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nodepool-mapper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a namespace name used by the chart.
*/}}
{{- define "nodepool-mapper.namespace" -}}
{{ default .Release.Namespace .Values.namespaceOverride }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "nodepool-mapper.labels" -}}
helm.sh/chart: {{ include "nodepool-mapper.chart" . }}
{{ include "nodepool-mapper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nodepool-mapper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nodepool-mapper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nodepool-mapper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nodepool-mapper.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
All of the relevant verbs
*/}}
{{- define "nodepool-mapper.verbs" -}}
verbs:
  - get
  - list
{{- end -}}
