FROM wordpress:latest

# 필요한 패키지를 설치합니다.
RUN apt-get update \
    && rm -rf /var/lib/apt/lists/*

# 모든 파일을 /workspace 디렉토리로 복사합니다.
COPY . /workspace

# 작업 디렉토리를 /workspace로 설정합니다.
WORKDIR /workspace

# WordPress의 wp-config.php 파일을 적절한 위치로 복사합니다.
RUN cp -f wp-config.php /var/www/html/ && cp -rf woocommerce /var/www/html/wp-content/plugins/woocommerce

# 기존의 .htaccess 파일을 삭제하고 새로운 파일을 복사합니다.
RUN rm -f /var/www/html/.htaccess && cp .htaccess /var/www/html/.htaccess

# WordPress와 WooCommerce의 권한을 설정합니다.
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce \
    && find /var/www -type d -exec chmod 755 {} \;

WORKDIR /var/www/html

USER www-data

EXPOSE 80