#!/bin/bash

set -o nounset
set -o errexit

DIR=$(pwd)
BUILDDIR=$DIR/build
VENDORDIR=$DIR/vendor
NGINX_DIR=nginx
NGINX_VERSION=1.6.2
NGINX_CONF_FILE="$(pwd)/etc/nginx.conf"

nginx_setup_environment () {
    if [ ! -d $BUILDDIR ]; then
        mkdir $BUILDDIR > /dev/null 2>&1
        mkdir $BUILDDIR/$NGINX_DIR > /dev/null 2>&1
    fi

    if [ ! -d $VENDORDIR ]; then
        mkdir $VENDORDIR > /dev/null 2>&1
    fi
}

nginx_download () {
    if [ ! -d "$VENDORDIR/nginx-$NGINX_VERSION" ]; then
        pushd $VENDORDIR > /dev/null 2>&1
        curl -s -L -O "http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
        tar xzf "nginx-$NGINX_VERSION.tar.gz"
        popd > /dev/null 2>&1
    else
        printf "NGINX already downloaded\n"
    fi
}

nginx_configure () {
    if [ -d "$VENDORDIR/nginx-$NGINX_VERSION" ]; then
        pushd "$VENDORDIR/nginx-$NGINX_VERSION" > /dev/null 2>&1
        CFLAGS="-g -O0"                       \
        ./configure                           \
            --with-debug                      \
            --prefix=$(pwd)/../../build/nginx \
            --conf-path=conf/nginx.conf       \
            --error-log-path=logs/error.log   \
            --http-log-path=logs/access.log   \
            --add-module=../../modules/hello-world \
            --add-module=../../modules/engine \
            --add-module=../../modules/ngx_devel_kit \
            --add-module=../../modules/echo-nginx-module \
            --add-module=../../modules/form-input-nginx-module
            # --add-module=../../modules/lua-nginx-module
        popd > /dev/null 2>&1
    else
        printf "NGINX is not yet downloaded\n"
    fi
}

nginx_distclean () {
    rm -rf $BUILDDIR $VENDORDIR
}

nginx_build () {
    if [ -d "$VENDORDIR/nginx-$NGINX_VERSION" ]; then
        pushd "$VENDORDIR/nginx-$NGINX_VERSION" > /dev/null 2>&1
        make
        make install
        popd > /dev/null 2>&1
        # add link to config
        ln -sf $(pwd)/etc/nginx.conf $BUILDDIR/nginx/conf/nginx.conf
    else
        printf "NGINX is not yet downloaded\n"
    fi
}

nginx_clean () {
    if [ -d "$VENDORDIR/nginx-$NGINX_VERSION" ]; then
        pushd "$VENDORDIR/nginx-$NGINX_VERSION" > /dev/null 2>&1
        make clean
        popd > /dev/null 2>&1
    else
        printf "NGINX is not yet downloaded\n"
    fi
}

nginx_start () {
    if [ -x "$BUILDDIR/nginx/sbin/nginx" ]; then
         $BUILDDIR/nginx/sbin/nginx
    else
        printf "NGINX is not yet builded\n"
    fi
}

nginx_stop () {
    if [ -x "$BUILDDIR/nginx/sbin/nginx" ]; then
         $BUILDDIR/nginx/sbin/nginx -s quit
    else
        printf "NGINX is not yet builded\n"
    fi
}

nginx_restart () {
    if [ -x "$BUILDDIR/nginx/sbin/nginx" ]; then
         nginx_stop
         sleep 3
         nginx_start 
    else
        printf "NGINX is not yet builded\n"
    fi
}

if [[ "$#" -eq 1 ]]; then
    if [[ "$1" == "distclean" ]]; then
        nginx_distclean
    elif [[ "$1" == "download" ]]; then
        nginx_download
    elif [[ "$1" == "configure" ]]; then
        nginx_configure
    elif [[ "$1" == "build" ]]; then
        nginx_build
    elif [[ "$1" == "clean" ]]; then
        nginx_clean
    elif [[ "$1" == "start" ]]; then
        nginx_start
    elif [[ "$1" == "stop" ]]; then
        nginx_stop
    elif [[ "$1" == "restart" ]]; then
        nginx_restart
    else
        echo "Unhandled option"
    fi
else
    nginx_setup_environment
    nginx_download
    nginx_configure
    nginx_build
fi

