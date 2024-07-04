# 베이스 이미지를 지정합니다.
FROM wordpress:latest

# 필요한 패키지를 설치합니다.
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/* && apt-get intsall -y git

# WooCommerce 플러그인을 다운로드하고 압축을 풉니다.
RUN git clone

# WordPress의 wp-config.php 파일을 복사하여 설정합니다.
COPY wp-config.php /var/www/html/

# WordPress와 WooCommerce의 권한을 설정합니다.
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/woocommerce \
    && chmod -R 755 /var/www/html/wp-content/plugins/woocommerce

EXPOSE 80