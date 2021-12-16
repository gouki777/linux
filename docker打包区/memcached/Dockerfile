FROM debian:stretch-20201209-slim

#ENV MEMCACHED_VERSION=1.5.8 \
#    MEMCACHED_SHA1=8db4363728edfce6c665c181f2237c7ea8ba3ea8

ENV MEMCACHED_VERSION=1.6.10 \
    MEMCACHED_SHA1=cb5b9fe77a2a59cc6cc7103a415bc07df9ddc6ec \
    ###启动变量
    #1. 最大连接数 #
    connections=4096 \
    #2. 启动线程数 #
    threads=2 \
    #3. 最大占用内存数 #
    memory=2048 \
    #4. 单key最大占用MB #
    mem="4m" 

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN set -ex \
    && groupadd --system --gid 11211 memcache && useradd --system --gid memcache --uid 11211 memcache \
### up time + tencent.debian ##########
    && ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone \
    && sed -i 's#[a-z]\+.debian.org#mirrors.cloud.tencent.com#g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install busybox telnet net-tools -y \
    && ln -s /bin/busybox /bin/ps \
    && ln -s /bin/busybox /bin/top


RUN set -x \
	\
	&& buildDeps=' \
		ca-certificates \
		dpkg-dev \
		gcc \
		libc6-dev \
		libevent-dev \
		libsasl2-dev \
		make \
		perl \
		wget \
	' \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& wget -O memcached.tar.gz "https://memcached.org/files/memcached-$MEMCACHED_VERSION.tar.gz" \
	&& echo "$MEMCACHED_SHA1  memcached.tar.gz" | sha1sum -c - \
	&& mkdir -p /usr/src/memcached \
	&& tar -xzf memcached.tar.gz -C /usr/src/memcached --strip-components=1 \
	&& rm memcached.tar.gz \
	\
	&& cd /usr/src/memcached \
	\
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& enableExtstore="$( \
# https://github.com/docker-library/memcached/pull/38
		case "$gnuArch" in \
# https://github.com/memcached/memcached/issues/381 "--enable-extstore on s390x (IBM System Z mainframe architecture) fails tests"
			s390x-*) ;; \
			*) echo '--enable-extstore' ;; \
		esac \
	)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-sasl \
		$enableExtstore \
	&& make -j "$(nproc)" \
	\
# TODO https://github.com/memcached/memcached/issues/382 "t/chunked-extstore.t is flaky on arm32v6"
	&& make test \
	&& make install \
	\
	&& cd / && rm -rf /usr/src/memcached \
	\
	&& apt-mark manual \
		libevent-2.0-5 \
		libsasl2-2 \
	&& apt-get purge -y --auto-remove $buildDeps \
	\
	&& memcached -V

COPY start.sh /

USER root
EXPOSE 11211
CMD ["bash", "/start.sh"]
