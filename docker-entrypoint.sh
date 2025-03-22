#!/bin/sh

# Colors
cend='\033[0m'
darkorange='\033[38;5;208m'
pink='\033[38;5;197m'
purple='\033[38;5;135m'
green='\033[38;5;41m'
blue='\033[38;5;99m'

printf "%b" "$darkorange" " ______        _     _                                             \n(_____ \      | |   | |                                            \n _____) )_   _| |__ | |__  _____  ____ _   _ _____  ____ ___ _____ \n|  __  /| | | |  _ \|  _ \| ___ |/ ___) | | | ___ |/ ___)___) ___ |\n| |  \ \| |_| | |_) ) |_) ) ____| |    \ V /| ____| |  |___ | ____|\n|_|   |_|____/|____/|____/|_____)_|     \_/ |_____)_|  (___/|_____)\n" "$cend";
printf "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
printf "%b" "🗒️ " "$blue" "Setup Guide " "$cend" "- https://github.com/rubberverse/lolcat-4get \n"
printf "%b" "📁 " "$green" "GitHub Repository " "$cend" "- https://github.com/rubberverse/lolcat-4get \n"
printf "🦆 Steady pace wins the race.\n"

printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting php-fpm${PHP_VERSION} using tini\n"
tini -- /usr/sbin/php-fpm"${PHP_VERSION}" \
        --daemonize \
        --force-stderr \
        --php-ini /app/configs/fpm/php.ini \
        --fpm-config /app/configs/fpm/php-fpm.conf

printf "%b" "[✨" " $green" "entrypoint" "$cend" "] Starting NGINX using tini and leaving entrypoint\n"
exec tini -- /usr/sbin/nginx \
        -c /app/configs/nginx/nginx.conf \
        -g 'daemon off;'
