package main
import (
	"log"
	"net/http"
	"github.com/prometheus/client_golang/prometheus/promhttp"
"github.com/prometheus/client_golang/prometheus"
)

func main() {
	//http.Handle("/metrics", promhttp.Handler())
	reg := prometheus.NewRegistry()
	http.Handle("/metrics", promhttp.HandlerFor(reg, promhttp.HandlerOpts{}))
	log.Fatal(http.ListenAndServe(":8089", nil))
	//promhttp.InstrumentHandlerCounter()	
}
