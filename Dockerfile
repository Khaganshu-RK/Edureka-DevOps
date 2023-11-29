FROM php:7.4-apache
WORKDIR /var/www/html
COPY website/. .
CMD ["apache2-foreground"]