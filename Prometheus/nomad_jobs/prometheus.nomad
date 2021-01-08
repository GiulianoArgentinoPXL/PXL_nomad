job "prometheus" {
    datacenters = ["dc1"]
    type = "service"

    group "prometheus" {
        network {
            port "prometheus_port" {
                to = 9090
                static = 9090
            }
        }
        service {
            name = "prometheus"
            port = "prometheus_port"
            tags = [
                "metrics"
            ]
        }

        task "prometheus" {
            driver = "docker"
            config {
                image ="prom/prometheus:latest"
                ports = ["prometheus_port"]
                logging {
                    type = "journald"
                    config {
                        tag = "PROMETHEUS"
                    }
                }
            }
			resources {
			  memory = 100
        }
    }
  }
}