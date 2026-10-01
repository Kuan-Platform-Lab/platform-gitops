{{- define "bs.name" -}}{{ .Release.Name }}{{- end -}}
{{- define "bs.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
