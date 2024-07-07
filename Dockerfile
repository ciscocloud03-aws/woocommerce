# 베이스 이미지를 지정합니다.
FROM wordpress:latest

USER admin

# 모든 파일을 /workspace 디렉토리로 복사합니다.
COPY . /workspace

# 작업 디렉토리를 /workspace로 설정합니다.
WORKDIR /workspace

# WordPress의 wp-config.php 파일을 적절한 위치로 복사합니다.
RUN cp -f /workspace/wp-config.php /var/www/html/ && cp -rf /workspace/woocommerce /var/www/html/wp-content/plugins/woocommerce

# WordPress와 WooCommerce의 권한을 설정합니다.
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce \
    && chmod -R 755 /var/www/html/wp-content/plugins/woocommerce

USER www-data

EXPOSE 80
