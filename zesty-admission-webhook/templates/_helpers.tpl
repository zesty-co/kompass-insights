{{/*
Expand the name of the chart.
*/}}
{{- define "zesty-admission-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zesty-admission-controller.fullname" -}}
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
{{- define "zesty-admission-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a namespace name used by the chart.
*/}}
{{- define "zesty-admission-controller.namespace" -}}
{{ default .Release.Namespace .Values.namespaceOverride }}
{{- end -}}

{{/*
Create a service name for secrets.
*/}}
{{- define "zesty-admission-controller.serviceName" -}}
{{- printf "%s-svc" (include "zesty-admission-controller.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a config map name.
*/}}
{{- define "zesty-admission-controller.configMap" -}}
{{- printf "%s-config" (include "zesty-admission-controller.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a pdb name.
*/}}
{{- define "zesty-admission-controller.pdb" -}}
{{- printf "%s-pdb" (include "zesty-admission-controller.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a cr name.
*/}}
{{- define "zesty-admission-controller.cr" -}}
{{- printf "%s-cr" (include "zesty-admission-controller.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a sa name.
*/}}
{{- define "zesty-admission-controller.sa" -}}
{{- printf "%s-sa" (include "zesty-admission-controller.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a crb name.
*/}}
{{- define "zesty-admission-controller.crb" -}}
{{- printf "%s-crb" (include "zesty-admission-controller.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
