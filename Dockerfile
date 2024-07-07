FROM wordpress:latest

USER root

# 모든 파일을 /workspace 디렉토리로 복사합니다.
COPY . /workspace

# 작업 디렉토리를 /workspace로 설정합니다.
WORKDIR /workspace

# 디버깅을 위한 출력 추가
RUN echo "Starting copy of wp-config.php and woocommerce plugin"

# WordPress의 wp-config.php 파일을 적절한 위치로 복사합니다.
RUN cp -f /workspace/wp-config.php /var/www/html/ \
    && echo "Copied wp-config.php" \
    && cp -rf /workspace/woocommerce /var/www/html/wp-content/plugins/woocommerce \
    && echo "Copied woocommerce plugin"

USER www-data

# WordPress와 WooCommerce의 권한을 설정합니다.
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce \
    && chmod -R 755 /var/www/html/wp-content/plugins/woocommerce \
    && echo "Set permissions for woocommerce plugin"

EXPOSE 80
