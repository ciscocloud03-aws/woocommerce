FROM wordpress:latest

# 기본 사용자 설정
USER root

# 모든 파일을 /tmp 디렉토리로 복사합니다.
COPY --chown=www-data:www-data . /tmp

# 필요한 파일만 /var/www/html 디렉토리로 복사하고 권한 설정
RUN cp -fp /tmp/wp-config.php /var/www/html/ \
    && cp -fp /tmp/.htaccess /var/www/html/ \
    && cp -rfp /tmp/woocommerce /var/www/html/wp-content/plugins/ \
    && chmod 755 /var/www/html \
    && chmod 644 /var/www/html/.htaccess \
    && chmod 640 /var/www/html/wp-config.php \
    && rm -rf /tmp \
    && ls -l /var/www/html/wp-content/plugins

# 기본 사용자로 전환
USER www-data

WORKDIR /var/www/html

# 포트 노출
EXPOSE 80
