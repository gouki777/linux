FROM alpine:3.13.5

RUN set -ex; \
    ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    echo "http://mirrors.cloud.tencent.com/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/main" >/etc/apk/repositories && \
    echo "http://mirrors.cloud.tencent.com/alpine/v$(cat /etc/alpine-release | cut -d'.' -f1,2)/community" >>/etc/apk/repositories && \
    ###############
    apk update \
 && apk add --no-cache \
        ca-certificates \
        ruby ruby-irb ruby-etc ruby-webrick \
        tini \
 && apk add --no-cache --virtual .build-deps \
        build-base linux-headers \
        ruby-dev gnupg \
 && gem source -r https://rubygems.org/ \
 && gem source -a http://mirrors.cloud.tencent.com/rubygems/ \
 && echo 'gem: --no-document' >> /etc/gemrc \
 && gem install oj -v 3.10.18 \
 && gem install fluent-plugin-kafka -v 0.17.1 \
 && gem install fluent-plugin-multi-format-parser -v 1.0.0 \
 && gem install fluent-plugin-prometheus -v 2.0.2 \
 && gem install fluent-plugin-elasticsearch -v 5.1.0 \
 && gem install fluent-plugin-kubernetes_metadata_filter -v 2.9.1 \
 && gem install json -v 2.4.1 \
 && gem install async-http -v 0.54.0 \
 && gem install ext_monitor -v 0.1.2 \
 && gem install fluentd -v 1.14.1 \
 && gem install bigdecimal -v 1.4.4 \
# NOTE: resolv v0.2.1 includes the fix for CPU spike issue due to DNS resolver.
# This hack is needed for Ruby 2.6.7, 2.7.3 and 3.0.1. (alpine image is still kept on 2.7.3)
 && gem install resolv -v 0.2.1 \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem /usr/lib/ruby/gems/2.*/gems/fluentd-*/test

RUN mkdir -p /fluentd/log /fluentd/etc /fluentd/plugins

COPY fluent.conf /fluentd/etc/
COPY entrypoint.sh /bin/

ENV FLUENTD_CONF="fluent.conf" \
    LD_PRELOAD="" \
# NOTE: resolv v0.2.1 includes the fix for CPU spike issue due to DNS resolver.
# Forcing to load specific version of resolv (instead of bundled by default) is needed for Ruby 2.6.7, 2.7.3 and 3.0.1.
# alpine image is still kept on 2.7.3. See https://pkgs.alpinelinux.org/packages?name=ruby&branch=v3.13
    RUBYLIB="/usr/lib/ruby/gems/2.7.0/gems/resolv-0.2.1/lib"

EXPOSE 24224 5140
USER root

ENTRYPOINT ["tini",  "--", "/bin/entrypoint.sh"]
CMD ["fluentd"]
