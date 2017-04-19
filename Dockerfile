FROM alpine

ENV PHP_MEMORY_LIMIT 512M

RUN apk add --no-cache \
    bash \
    vim \
    strace \
    nodejs \
    ruby \
    php5 \
    python \
    perl \
    go \
    g++ \
    openjdk8 && \
    sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php5/php.ini

ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV PATH $PATH:/usr/lib/jvm/default-jvm/jre/bin:/usr/lib/jvm/default-jvm/bin
