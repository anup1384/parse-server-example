{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "node-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "node-exporter.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "node-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "node-exporter.labels" -}}
app.kubernetes.io/name: {{ include "node-exporter.name" . }}
helm.sh/chart: {{ include "node-exporter.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "nodeExporter.metaLabels" -}}
{{ include "nodeExporter.labels" . }}
{{ include "nodeExporter.matchLabels" . }}
{{- end -}}

{{- define "nodeExporter.labels" -}}
kubernetes.io/cluster-service: {{ .Values.nodeExporter.clusterservice }}
addonmanager.kubernetes.io/mode: {{ .Values.nodeExporter.addonmanagermode  }}
{{- end -}}

{{- define "nodeExporter.matchLabels" -}}
k8s-app: {{ .Chart.Name }}
version: {{ .Values.nodeExporter.version  }}
{{- end -}}
