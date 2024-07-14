FROM wordpress:latest

# 기본 사용자 설정
USER root

# 작업 디렉토리 설정
WORKDIR /tmp

# 모든 파일을 /tmp 디렉토리로 복사합니다.
COPY --chown=www-data:www-data . .

# 필요한 파일만 /var/www/html 디렉토리로 복사하고 권한 설정
RUN cp -rf wp-config.php /var/www/html/ \
    && cp -rf .htaccess /var/www/html/ \
    && cp -rf woocommerce /var/www/html/wp-content/plugins/ \
    && chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce /var/www/html/wp-config.php /var/www/html/.htaccess \
    && chmod -R 755 /var/www/html/wp-content/plugins/woocommerce \
    && rm -rf /tmp/* \
    && ls -l /var/www/html/wp-content/plugins

# 기본 사용자로 전환
USER www-data

# 포트 노출
EXPOSE 80
