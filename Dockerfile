FROM debian:latest

# install build dependencies
RUN apt-get -qq update \
  && apt-get -qq -y install \
  libreadline-dev \
  libncurses5-dev \
  libpcre3-dev \
  libssl-dev \
  libpq-dev \
  libgd-dev \
  libgeoip-dev \
  libncurses5-dev \
  libperl-dev \
  libxslt1-dev \
  perl \
  make \
  curl \
  git-core \
  luarocks \
  vim \
  luajit \
  build-essential \
  ca-certificates \
  unzip \
  zlib1g-dev \
  lua-sec

# build/install OpenResty
ENV SRC_DIR /opt
ENV OPENRESTY_VERSION 1.9.15.1
ENV OPENRESTY_PREFIX /opt/openresty
ENV LAPIS_VERSION 1.5.1

RUN cd $SRC_DIR && curl -LO https://openresty.org/download/openresty-$OPENRESTY_VERSION.tar.gz \
 && tar xzf openresty-$OPENRESTY_VERSION.tar.gz && cd openresty-$OPENRESTY_VERSION \
 && ./configure --prefix=$OPENRESTY_PREFIX \
 --with-file-aio \
 --with-http_addition_module \
 --with-http_auth_request_module \
 --with-http_dav_module \
 --with-http_flv_module \
 --with-http_geoip_module=dynamic \
 --with-http_gunzip_module \
 --with-http_gzip_static_module \
 --with-http_image_filter_module=dynamic \
 --with-http_mp4_module \
 --with-http_postgres_module \
 --with-http_random_index_module \
 --with-http_realip_module \
 --with-http_secure_link_module \
 --with-http_slice_module \
 --with-http_ssl_module \
 --with-http_stub_status_module \
 --with-http_sub_module \
 --with-http_v2_module \
 --with-http_xslt_module=dynamic \
 --with-ipv6 \
 --with-luajit \
 --with-mail \
 --with-mail_ssl_module \
 --with-md5-asm \
 --with-pcre-jit \
 --with-sha1-asm \
 --with-stream \
 --with-stream_ssl_module \
 --with-threads \
 && make && make install \
 && rm -rf openresty-$OPENRESTY_VERSION* \
 && mkdir /app && mkdir /var/log/nginx && mkdir /tmp/log

 RUN luarocks install moonscript \
     && luarocks install pgmoon \
     && luarocks install lapis \
     && luarocks install lapis-console \
     && luarocks install lua-resty-http \
     && luarocks install luatz

 ENV LAPIS_OPENRESTY /opt/openresty/nginx/sbin/nginx

 EXPOSE 80

 WORKDIR /app
 VOLUME /app

 ENTRYPOINT ["lapis"]
 CMD ["server", "development"]
