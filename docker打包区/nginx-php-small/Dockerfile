FROM php:7.1.30-fpm-stretch
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ADD sources.list /etc/apt/sources.list
RUN rm -rf /etc/apt/sources.list.d/buster.list
#RUN sed -i 's#[a-z]\+.debian.org#mirrors.aliyun.com#g' /etc/apt/sources.list
###########ngx###########
LABEL maintainer="sunyufeng <sunyy5@ifeng.com>"

# RESTY_DEB_FLAVOR build argument is used to select other
# OpenResty Debian package variants.
# For example: "-debug" or "-valgrind"
ARG RESTY_DEB_FLAVOR=""
ARG RESTY_DEB_VERSION="=1.15.8.1-1~stretch1"

LABEL resty_deb_flavor="${RESTY_DEB_FLAVOR}"
LABEL resty_deb_version="${RESTY_DEB_VERSION}"

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        gettext-base \
        gnupg2 \
        lsb-release \
        software-properties-common \
        wget \
    && wget -qO /tmp/pubkey.gpg https://openresty.org/package/pubkey.gpg \
    && DEBIAN_FRONTEND=noninteractive apt-key add /tmp/pubkey.gpg \
    && rm /tmp/pubkey.gpg \
    && DEBIAN_FRONTEND=noninteractive add-apt-repository -y "deb http://openresty.org/package/debian $(lsb_release -sc) openresty" \
    && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge \
        gnupg2 \
        lsb-release \
        software-properties-common \
        wget \
    && DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openresty${RESTY_DEB_FLAVOR}${RESTY_DEB_VERSION} \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /dev/stdout /usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/logs/error.log


# Add additional binaries into PATH for convenience
ENV PATH="$PATH:/usr/local/openresty${RESTY_DEB_FLAVOR}/luajit/bin:/usr/local/openresty${RESTY_DEB_FLAVOR}/nginx/sbin:/usr/local/openresty${RESTY_DEB_FLAVOR}/bin"
###########php###########
RUN set -ex; \
        \
        buildDeps=' \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmemcached-dev zlib1g-dev \
        openssl libssl-dev \
        git \
        supervisor \
        '; \
        apt-get update; \
        apt-get install -y $buildDeps --no-install-recommends; \
        docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install -j$(nproc) gd
RUN set -ex \
    && docker-php-ext-install pdo_mysql zip opcache \
    #&& pecl install mongodb \
    #&& pecl install redis-4.1.1 \
    #&& docker-php-ext-enable mongodb redis \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -rf /var/lib/apt/lists/*
##############php调整变量#########
ENV TIMEZONE Asia/Shanghai
ENV PHP_MEMORY_LIMIT 50M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST 100M
ENV PHP_INI_CONF /usr/local/etc/php/php.ini
ENV PHP_FPM_CONF /usr/local/etc/php-fpm.conf
##########配置文件和测试包###########
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
ADD php-fpm.conf /usr/local/etc/php-fpm.conf
ADD info.php /usr/local/openresty/nginx/html/info.php
ADD hello.php /usr/local/openresty/nginx/html/hello.php
ADD test.php /usr/local/openresty/nginx/html/test.php
ADD supervisord.conf /etc/supervisor/
#############################
RUN set -ex; \
    mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini; \
    sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" $PHP_INI_CONF; \
    sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" $PHP_INI_CONF; \
    sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" $PHP_INI_CONF; \
    sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" $PHP_INI_CONF; \
    sed -i "s|;opcache.enable=1|opcache.enable=1|g" $PHP_INI_CONF; \
    sed -i "s|;opcache.enable_cli=0|opcache.enable_cli=1|g" $PHP_INI_CONF; \
    sed -i "s|;opcache.memory_consumption=128|opcache.memory_consumption=128|g" $PHP_INI_CONF; \
    sed -i "s|;opcache.interned_strings_buffer=8|opcache.interned_strings_buffer=16|g" $PHP_INI_CONF; \
    sed -i "s|;opcache.validate_timestamps=1|opcache.validate_timestamps=0|g" $PHP_INI_CONF;
EXPOSE 80
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
