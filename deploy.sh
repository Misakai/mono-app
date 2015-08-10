#!/bin/bash 

# Configuration
# -------------
# APP_BUCKET: The name of the bucket that contains the file to download
# APP_FILE: The path to the file inside the bucket
# APP_ENTRY: The mono entry-point
# AWS_ACCESS_KEY: The access key to use for S3
# AWS_SECRET_KEY: The secret key to use for S3

# More on MONO, including environment options: http://mono.wikia.com/wiki/Man_mono

# Move S3 Configuration file
cp .s3cfg ~/.s3cfg

# Download the package
s3cmd get s3://$APP_BUCKET/$APP_FILE

# Get the application archive
if [[ -z $APP_ARCHIVE ]]; then
	APP_ARCHIVE=$(find /app -name "*.zip")
fi

# If requested, compile ZeroMQ
if [[ -z $ZMQ_PATH && $ENABLE_ZMQ]]; then
	ZMQ_LIBSODIUM=libsodium-1.0.3
	ZMQ_ZEROMQ=zeromq-4.1.2
	ZMQ_SETUP="autoconf automake build-essential pkg-config"
	ZMQ_PATH=/app/amd64
	ZMQ_TEMP=/tmp/zmq
	
	apt-get update -qq && apt-get install -y $ZMQ_SETUP
	mkdir $ZMQ_TEMP && cd $ZMQ_TEMP
	wget https://download.libsodium.org/libsodium/releases/${ZMQ_LIBSODIUM}.tar.gz
	tar -xvf ${ZMQ_LIBSODIUM}.tar.gz
	cd ${ZMQ_LIBSODIUM}
	./configure && make && make install
	cd $ZMQ_TEMP
	wget http://download.zeromq.org/${ZMQ_ZEROMQ}.tar.gz
	tar -xvf ${ZMQ_ZEROMQ}.tar.gz
	cd ${ZMQ_ZEROMQ}
	./configure && make && make install
	cp $ZMQ_TEMP/lib/* $ZMQ_PATH 
fi

# Make sure we have certificates we need
mozroots --import --machine --sync

# Unzip the package and delete the zip file
unzip -qq -o $APP_ARCHIVE -d /app
rm $APP_ARCHIVE

# Optionally enable ahead-of-time compilation
if [[ $MONO_ENABLE_AOT ]]; then
	mono --aot -O=all ${APP_ENTRY}
fi

# Use specific garbage collector
if [[ -z  $MONO_USE_GC ]]; then
	MONO_USE_GC=sgen
fi

# Set maximum threads per CPU 
if [[ -z $MONO_THREADS_PER_CPU ]]; then
	MONO_THREADS_PER_CPU=100
fi

# Run the application
mono --server --gc=$MONO_USE_GC ${APP_ENTRY} 