FROM ubuntu:22.04

ENV PHP_VERSION=${PHP_VERSION:-8.2}
ENV LANG=${LOCALE:-en_US.UTF-8}
ENV LANGUAGE=${LOCALE:-en_US.UTF-8}
ENV LC_ALL=${LOCALE:-en_US.UTF-8}
ENV DEBIAN_FRONTEND=noninteractive

ENV APACHE_CONF_DIR=/etc/apache2
ENV PHP_CONF_DIR=/etc/php/${PHP_VERSION}
ENV PHP_DATA_DIR=/var/lib/php

# Configure locales
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen ${LOCALE:-en_US.UTF-8} && \
    dpkg-reconfigure locales

# Install Common Tools
RUN apt-get update && \
    apt-get install -y \
    software-properties-common curl vim \
    && apt-get clean

# Add PPAs and install PHP, Apache, and Perl
RUN add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/apache2 && \
    apt-get update && \
    apt-get install -y \
    php${PHP_VERSION}-cli php${PHP_VERSION}-readline php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-zip php${PHP_VERSION}-intl php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl php${PHP_VERSION}-gd php${PHP_VERSION}-mysql \
    php-pear apache2 libapache2-mod-php${PHP_VERSION} perl \
    && apt-get clean

# install php-json, since version > 8 no need to install it
RUN [ "${PHP_VERSION%.*}" -le 8 ] && apt-get install -y php${PHP_VERSION}-json || true

# Apache and PHP configuration
RUN cp /dev/null ${APACHE_CONF_DIR}/conf-available/other-vhosts-access-log.conf && \
    a2enmod rewrite headers

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Cleanup
RUN apt-get purge -y --auto-remove software-properties-common && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Handle logs
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

# Ensure correct ownership
RUN chown www-data:www-data ${PHP_DATA_DIR} -Rf

WORKDIR /var/www/http/

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 80 443

# Default command
CMD ["/sbin/entrypoint.sh"]
