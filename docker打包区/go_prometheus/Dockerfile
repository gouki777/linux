FROM golang:1.10-alpine3.8 as small
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories 
RUN apk add --no-cache --virtual .build-deps git
RUN go get -u -v github.com/prometheus/client_golang/prometheus
RUN go get -v -u github.com/prometheus/client_golang/prometheus/promhttp
COPY prometheus_http.go /
RUN apk del .build-deps
RUN go build /prometheus_http.go
CMD ["/go/prometheus_http"]
