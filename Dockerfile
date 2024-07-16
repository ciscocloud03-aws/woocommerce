FROM wordpress:latest

# 기본 사용자 설정
USER root

# 모든 파일을 /tmp 디렉토리로 복사합니다.
COPY --chown=www-data:www-data . /tmp

WORKDIR /var/www/html

# 필요한 파일만 /var/www/html 디렉토리로 복사하고 권한 설정
RUN cp -fp /tmp/wp-config.php /var/www/html/ \
    && cp -rfp /tmp/woocommerce /var/www/html/wp-content/plugins/ \
    && chmod 755 /var/www/html /var/www/html/wp-content/plugins/woocommerce \
    && chmod 640 /var/www/html/wp-config.php \
    && rm -rf /tmp \
    && ls -l /var/www/html/wp-content/plugins 

RUN touch /var/www/html/.htaccess && \
    echo -e '<IfModule mod_rewrite.c>\n\tRewriteEngine On \ 
    \n\tRewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}] \
    \n\tRewriteBase /\n\tRewriteRule ^index\.php$ - [L] \
    \n\tRewriteCond %{REQUEST_FILENAME} !-f \ 
    \n\tRewriteCond %{REQUEST_FILENAME} !-d\n\tRewriteRule . /index.php [L] \
    \n\n\tRewriteCond %{SERVER_PORT} 443 \ 
    \n\tRewriteRule ^(.*)$ https://www.musicin.shop/$1 [R,L]\n</IfModule>' && \
    chmod 644 /var/www/html/.htaccess

# 기본 사용자로 전환
USER www-data

# 포트 노출
EXPOSE 80
