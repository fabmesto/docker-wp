#1. Docker base image
FROM wordpress:php7.4-apache

#2. Install WP-cli and dependencies to run it
RUN apt-get update \
    && apt-get install -y \
    less \
    subversion \
    sudo \
    default-mysql-client-core \
    && curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

#3. Create the files for the testing environment
RUN \
    #3.1 Install phpunit
    curl -L https://phar.phpunit.de/phpunit-7.phar -o /tmp/phpunit \
    && chmod a+x /tmp/phpunit \
    #3.2 Install wordpress
    && cp -r /usr/src/wordpress /tmp/wordpress \
    && curl https://raw.github.com/markoheijnen/wp-mysqli/master/db.php -o /tmp/wordpress/wp-content/db.php \
    #3.3 Install the testing libraries
    && svn co --quiet https://develop.svn.wordpress.org/tags/5.3.2/tests/phpunit/includes/ /tmp/wordpress-tests-lib/includes \
    && svn co --quiet https://develop.svn.wordpress.org/tags/5.3.2/tests/phpunit/data/ /tmp/wordpress-tests-lib/data \
    #3.4 set owner and permissions
    && chown -R www-data:www-data /tmp/wordpress \
    && chown -R www-data:www-data /tmp/wordpress-tests-lib

# ext-intl
RUN \
    apt-get install -y libicu-dev \ 
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# X DEBUG PHP
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug


# Additional PHP ini configuration
COPY ./config/php.ini /usr/local/etc/php/conf.d/

CMD ["apache2-foreground"]

EXPOSE 9000

# restart DOKERFILE
# docker-compose up -d --force-recreate --build 
# bin/install-wp-tests.sh wordpress_test root somewordpress db latest true
# /tmp/phpunit