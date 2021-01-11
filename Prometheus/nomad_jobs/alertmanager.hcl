job "alertmanager" {
	datacenters = ["dc1"]
    type        = "service"

    group "alertmanager" {
        count = 1
  	    network {
  		    port "alertmanager_ui" {
    	    to = 9093
      	     static = 9093
			}
		}
        service {
	        name = "alertmanager"
            port = "alertmanager_ui"
            tags = [
      	        "metrics"
            ]
        }
	    task "alertmanager" {
            driver = "docker"
            config {
      	        image = "prom/alertmanager:latest"
                ports = ["alertmanager_ui"]
                logging {
        	        type = "journald"
                    config {
          	            tag = "ALERTMANAGER"
                    }
                }
            }
            resources {
      	        memory = 100
            }
  	    }       
    }
}