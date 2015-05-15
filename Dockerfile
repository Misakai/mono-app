FROM misakai/mono:4.0.1
MAINTAINER Roman Atachiants "roman@misakai.com"

# S3FS Version
ENV S3FS_VERSION="1.78"

# Make sure we have S3 & S3FS
RUN apt-get update  -qq \
	&& apt-get install -y s3cmd libgdiplus

# Make sure we have S3 & S3FS
WORKDIR /deploy
RUN apt-get update -qq \
	&& apt-get install -y build-essential libmount1 libblkid1 libfuse-dev fuse-utils libcurl4-openssl-dev libxml2-dev mime-support makedev automake libtool wget tar \
	&& wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v$S3FS_VERSION.tar.gz -O /usr/src/v$S3FS_VERSION.tar.gz \
	&& tar xvz -C /usr/src -f /usr/src/v$S3FS_VERSION.tar.gz \
	&& cd /usr/src/s3fs-fuse-$S3FS_VERSION \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr \
	&& make \
	&& make install \
	&& mkdir /data \
	&& chmod 777 /data \
	&& apt-get remove -y --purge --force-yes build-essential libfuse-dev libcurl4-openssl-dev libxml2-dev mime-support automake libtool wget \
	&& apt-get autoremove -y --force-yes \
	&& apt-get install -y s3cmd libgdiplus libcurl3 libxml2 \
	&& rm -rf /deploy


# Application will be in app folder
WORKDIR /app
ADD . /app

# HTTP & HTTPS Ports
EXPOSE 80
EXPOSE 443

CMD ["/bin/bash", "/app/deploy.sh"]