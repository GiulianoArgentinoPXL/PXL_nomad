job "prometheus" {
    datacenters = ["dc1"]
    type = "service"

    group "prometheus" {
	network {
            port "prometheus_ui" {
                to = 9090
                static = 9090
            }
	}

    	task "prometheus" {
	    template {
            change_mode = "noop"
            destination = "local/rules.yml"
            data = <<EOH
---
groups:
- name: prometheus_alerts
  rules:
  - alert: Webserver down
    expr: absent(up{job="webserver"})
    for: 10s
    labels:
      severity: critical
    annotations:
      description: "Our webserver is down."
EOH 
      	    }
      	    template {
                change_mode = "noop"
        	destination = "local/prometheus.yml"
        	data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s
alerting:
 alertmanagers:
 - consul_sd_configs:
   - server: '10.0.0.10:8500'
     services: ['alertmanager']
rule_files:
 - "/etc/alertmanager/rules.yml"
scrape_configs:
  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '10.0.0.10:8500'
      services: ['nomad-client', 'nomad']
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '(.*)http(.*)'
      action: keep
    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
  - job_name: 'metrics'

    consul_sd_configs:
    - server: '10.0.0.10:8500'
      services: []
    relabel_configs:
    - source_labels: ['__meta_consul_tags']
      regex: '.*,metrics,.*'
      action: keep
    - source_labels: [__meta_consul_service]
      target_label: job
    scrape_interval: 5s
    metrics_path: /metrics
    params:
      format: ['prometheus']
EOH
      	    }
      driver = "docker"
      config {
        image = "prom/prometheus:latest"
        force_pull = true
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "local/rules.yml:/etc/alertmanager/rules.yml"
        ]

        ports = ["prometheus_ui"]
        logging {
          type = "journald"
          config {
            tag = "PROMETHEUS"
          }
        }
      }

      service {
        name = "prometheus"
        tags = ["prometheus"]
        port = "prometheus_ui"
      }
    }
  }
}
