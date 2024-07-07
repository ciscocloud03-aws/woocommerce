FROM wordpress:latest

USER root

# 모든 파일을 /tmp 디렉토리로 복사합니다.
COPY . /tmp

RUN cd /tmp && cp -rf wp-config.php /var/www/html/ \
    && cp -rf woocommerce/ /var/www/html/wp-content/plugins/woocommerce

# WordPress와 WooCommerce의 권한을 설정합니다.
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce \
    && chmod -R 755 /var/www/html/wp-content/plugins/woocommerce 

EXPOSE 80
