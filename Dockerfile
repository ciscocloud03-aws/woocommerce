FROM wordpress:latest

USER root

# 모든 파일을 /tmp 디렉토리로 복사합니다.
COPY . /tmp

RUN cp -rf /tmp/wp-config.php /var/www/html/ \
    && cp -rf /tmp/woocommerce /var/www/html/wp-content/plugins/ && chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce /var/www/html/wp-config.php \
    && chmod -R 755 /var/www/html/wp-content/plugins/woocommerce && ls -l /var/www/html/wp-content/plugins 

USER www-data

EXPOSE 80
