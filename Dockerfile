ARG PHP_VERSION=8.1

FROM php:${PHP_VERSION}-fpm-alpine

RUN apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
		git \
	;

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-data-full \
		icu-dev \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		intl \
		zip \
	; \
	pecl install apcu mongodb redis \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		mongodb \
		redis \
		opcache \
	; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

RUN docker-php-ext-install mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

ENV PATH="${PATH}:/root/.composer/vendor/bin"

WORKDIR /var/www/html

ARG SKELETON="symfony/skeleton"
ENV SKELETON ${SKELETON}

ARG STABILITY="stable"
ENV STABILITY ${STABILITY}

ARG SYMFONY_VERSION=""
ENV SYMFONY_VERSION ${SYMFONY_VERSION}

RUN composer create-project "${SKELETON} ${SYMFONY_VERSION}" . --stability=$STABILITY --prefer-dist --no-dev --no-progress --no-interaction; \
	composer clear-cache

RUN apk add --no-cache nodejs npm
RUN npm install -g yarn

COPY . .

RUN set -eux; \
	mkdir -p var/cache var/log; \
	composer install --prefer-dist --no-dev --no-progress --no-scripts --no-interaction; \
	composer dump-autoload --classmap-authoritative --no-dev; \
	composer symfony:dump-env prod; \
	composer run-script --no-dev post-install-cmd; \
	chmod +x bin/console; sync
