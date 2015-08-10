FROM misakai/mono:4.0.3
MAINTAINER Roman Atachiants "roman@misakai.com"

# Make sure we have S3 & additional libraries
RUN apt-get update -qq \
	&& apt-get install -y s3cmd libgdiplus libcurl3 libxml2 wget
	
# Build ZeroMQ
ENV V_LIBSODIUM=libsodium-1.0.3
ENV V_ZEROMQ=zeromq-4.1.2
ENV SETUP_TOOLS="autoconf automake build-essential pkg-config"
RUN apt-get update -qq && apt-get install -y $SETUP_TOOLS \
	&& mkdir /tmp/zmq \
	&& cd /tmp/zmq \
	&& wget https://download.libsodium.org/libsodium/releases/${V_LIBSODIUM}.tar.gz \
	&& tar -xvf ${V_LIBSODIUM}.tar.gz \
	&& cd ${V_LIBSODIUM} \
	&& ./configure \
	&& make \
	&& make install \
	&& cd /tmp/zmq \
	&& wget http://download.zeromq.org/${V_ZEROMQ}.tar.gz \
	&& tar -xvf ${V_ZEROMQ}.tar.gz \
	&& cd ${V_ZEROMQ} \
	&& ./configure \
	&& make \
	&& make install \
	&& apt-get remove -y --purge $SETUP_TOOLS \
	&& apt-get autoremove -y \
	&& rm -rf /tmp/zmq/

# Application will be in app folder
WORKDIR /app
ADD . /app

# HTTP & HTTPS Ports
# EXPOSE 80
# EXPOSE 443

CMD ["/bin/bash", "/app/deploy.sh"]