job "grafana" {
    datacenters = ["dc1"]
    type = "service"

    group "grafana" {
        count = 1
  	    network {
  		port "grafana_ui" {
    	            to = 3000
      	            static = 3000
		}
	    }
	    
	    task "grafana" {
                driver = "docker"
                config {
      	            image = "grafana/grafana:latest"
                    ports = ["grafana_ui"]
                    logging {
        	        type = "journald"
                        config {
			    tag = "GRAFANA"
			}
                    }
                }
            }

            service {
		name = "grafana"
  	    }
    }
}
