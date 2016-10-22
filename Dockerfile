FROM debian:jessie
MAINTAINER Paul Smith <p@ulsmith.net>

## Install base packages
RUN apt-get update && \
    apt-get -yq install \
		apache2 \
		php5 \
		libapache2-mod-php5 \
		curl \
		ca-certificates \
		php5-curl \
		php5-json \
		php5-odbc \
		php5-sqlite \
		php5-mysql \
		php5-mcrypt && \
	apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archive/*.deb

RUN /usr/sbin/php5enmod mcrypt && a2enmod rewrite && mkdir /bootstrap

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
ADD start.sh /bootstrap/start.sh
RUN chmod 755 /bootstrap/start.sh && chown -R www-data:www-data /var/www/html

EXPOSE 80
ENTRYPOINT ["/bootstrap/start.sh"]
