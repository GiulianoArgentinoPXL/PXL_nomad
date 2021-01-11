# Table of contents

**How was this developed?**

- [Prometheus](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/nomad_jobs/Prometheus.hcl)
- [Alertmanager](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/nomad_jobs/alertmanager.hcl)
- [Grafana](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/nomad_jobs/grafana.hcl)
- [Node exporter](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/nomad_jobs/nodeExporter)
- [Consul exporter](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/nomad_jobs/consulExporter.hcl)
- Sources

# How was this developed?

## General info

First of all we need to add a telemetry stanza to our [server.hcl.j2](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/ansible/roles/software/nomad/templates/server.hcl.j2) file in Nomad. This will allow us to collect metrics. It will convert the metrics to a format Prometheus can use if you enable *prometheus_metrics*.

```
telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
```

## Prometheus

The Prometheus UI will be accessible on port 9090. Here you can check all the available metrics.

## Alertmanager

Alertmanager will receive metrics from Prometheus so that when a certain metric has a specific value, it will trigger an alert if you configure it this way. It has support for a wide variety of client applications; for example the Prometheus server.

## Grafana

The default login of this web interface is admin/admin.
Grafana will be used to set up dashboards, to make it easy and make it have a clean interface, we made use of an existing [template](https://github.com/GiulianoArgentinoPXL/PXL_nomad/blob/team19/Prometheus/Grafana-dashboard-prometheus-node-exporter.json). 
The widgets are very customizable so when you don't like a specific widget, you can either edit or remove it to your personal preference. 

[Link to all kinds of different dashboards](https://grafana.com/grafana/dashboards)

## Node exporter

A node exporter is needed so that every single node where the node exporter job is running, is able to send metrics to the desired destination, which is in our case Prometheus.

## Consul exporter

This exporter has the same purpose as the node exporter, but this is used for the Consul server.

Every exporter has the same purpose, we can use this to scrape/collect data from whatever we want, and send it to the desired destionation.

## Sources

- [Prometheus Nomad metrics](https://learn.hashicorp.com/tutorials/nomad/prometheus-metrics)
- [Grafana dashboards](https://grafana.com/grafana/dashboards)
