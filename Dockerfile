# Based on qor-nginx project

ARG IMAGE_REPOSITORY=docker.io/library
ARG IMAGE_VERSION=bookworm-slim

FROM $IMAGE_REPOSITORY/debian:$IMAGE_VERSION AS debian-base

ARG DEB="php8.2" \
    PHP_VERSION="8.2" \
    CONT_USER=nginx_user \
    CONT_UID=1001 \
    SERVICE_NAME="4get" \
    DIRECTORY_PATH="/app/www/4get"

ENV DEB=$DEB \
    PHP_VERSION=$PHP_VERSION \
    CONT_USER=$CONT_USER \
    CONT_UID=$CONT_UID \
    DEBIAN_FRONTEND=noninteractive \
    SERVICE_NAME=$SERVICE_NAME \
    DIRECTORY_PATH=$DIRECTORY_PATH

WORKDIR /app

COPY --chmod=755 ./remove-junk.sh /app/scripts/remove-junk.sh

RUN apt update \
    && apt upgrade -y \
    && apt install --no-install-recommends -y \
        git \
        curl \
        adduser \
    && addgroup \
        --system \
        --gid ${CONT_UID} \
        ${CONT_USER} \
    && adduser \
        --home "/var/lib/mysql" \
        --shell "/bin/sh" \
        --uid ${CONT_UID} \
        --ingroup ${CONT_USER} \
        --disabled-password \
        ${CONT_USER} \
    && apt install --no-install-recommends -y \
        curl \
        tini \
        nginx \
        openssl \
        imagemagick \
        ca-certificates \
        ${DEB} \
        ${DEB}-mbstring \
        ${DEB}-dom \
        ${DEB}-imagick \
        ${DEB}-curl \
        ${DEB}-apcu \
    && mkdir -p \
        /app/run \
        /app/www \
        /app/scripts \
        /app/logs/fpm \
        /app/logs/nginx \
        /app/configs/fpm \
        /app/temp/session \
        /app/temp/opcache \
    # Hardcoded: https://salsa.debian.org/nginx-team/nginx/-/blob/debian/1.26.0-2/debian/rules#L32
        /var/lib/nginx \
    && mv /etc/nginx /app/configs/nginx \
    && touch \
        /app/logs/fpm/php-error.log \
        /app/logs/fpm/fpm-error.log \
        /app/logs/fpm/fpm-access.log \
    && git clone https://git.lolcat.ca/lolcat/4get.git /app/www/4get \
    && rm -rf /app/www/4get/.git \
    && rm -rf /var/cache/apt \
    # Frees up around 300MB
    && /app/scripts/remove-junk.sh \
    && rm /app/scripts/remove-junk.sh

COPY ./php.ini /app/configs/fpm/php.ini
COPY ./fpm.conf /app/configs/fpm/php-fpm.conf
COPY ./www.conf /app/configs/fpm/pool.d/www.conf
COPY ./nginx.conf /app/configs/nginx/nginx.conf

WORKDIR /app/www/4get
RUN chown -Rf $CONT_USER:$CONT_USER \
    /app \
    /var/lib/nginx

COPY --chmod=755 ./docker-entrypoint.sh /app/scripts/docker-entrypoint.sh

WORKDIR /app
USER $CONT_USER

ENV TINI_SUBREAPER=1 \
    PHP_SHORT_OPEN_TAG="Off" \
    PHP_OUTPUT_BUFFERING=4096 \
    PHP_DISABLE_FUNCTIONS="" \
    PHP_DISABLE_CLASSES="" \
    PHP_IGNORE_USER_ABORT="Off" \
    PHP_REALPATH_CACHE_SIZE="4096k" \
    PHP_REALPATH_CACHE_TTL=120 \
    PHP_ZEND_ENABLE_GC="On" \
    PHP_ZEND_MULTIBYTE="Off" \
    PHP_ZEND_EXCEPTION_IGNORE_ARGS="On" \
    PHP_EXPOSE_PHP="Off" \
    PHP_MAX_EXECUTION_TIME=0 \
    PHP_MAX_INPUT_TIME=-1 \
    PHP_MEMORY_LIMIT="256M" \
    PHP_IGNORE_REPEATED_ERRORS="Off" \
    PHP_IGNORE_REPEATED_SOURCE="Off" \
    PHP_POST_MAX_DATA_SIZE="8M" \
    PHP_DEFAULT_CHARSET="UTF-8" \
    PHP_FASTCGI_LOGGING=1 \
    PHP_FILE_UPLOADS="On" \
    PHP_UPLOAD_MAX_FILESIZE="100M" \
    PHP_ALLOW_URL_FOPEN="Off" \
    PHP_ALLOW_URL_INCLUDE="Off" \
    PHP_DEFAULT_SOCKET_TIMEOUT=60 \
    PHP_DATE_TIMEZONE="Europe/Warsaw" \
    PHP_INTL_DEFAULT_LOCALE="" \
    PHP_PDO_ODBC_CONNECTION_POOLING="strict" \
    PHP_SESSION_COOKIE_DOMAIN="" \
    PHP_SESSION_COOKIE_SAMESITE="Strict" \
    PHP_MBSTRING_LANGUAGE="" \
    FPM_LISTEN_ADDRESS="/app/run/php-fpm.sock" \
    FPM_ALLOWED_CLIENTS="127.0.0.1" \
    FPM_CLEAR_ENV="yes" \
    FPM_PROCESS_MANAGER="static" \
    FPM_PM_MAX_CHILDREN=4 \
    FPM_PM_START_SERVERS=2 \
    FPM_PM_MIN_SPARE_SERVERS=1 \
    FPM_PM_MAX_SPARE_SERVERS=1 \
    FPM_SENDMAIL_PATH="/usr/bin/sendmail -t -i" \
    FPM_FASTCGI_LOGGING="yes" \
    FPM_LOG_ERRORS="on" \
    FPM_LOG_LEVEL="warn" \
    FPM_LOG_LIMIT=2048 \
    FPM_EMERGENCY_RESTART_THRESHOLD= \
    FPM_LOG_BUFFERING=""

ENTRYPOINT ["/app/scripts/docker-entrypoint.sh"]
