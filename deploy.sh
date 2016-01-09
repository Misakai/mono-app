#!/bin/bash 

# Configuration
# -------------
# APP_BUCKET: The name of the bucket that contains the file to download
# APP_FILE: The path to the file inside the bucket
# APP_ENTRY: The mono entry-point
# AWS_ACCESS_KEY: The access key to use for S3
# AWS_SECRET_KEY: The secret key to use for S3

# More on MONO, including environment options: http://mono.wikia.com/wiki/Man_mono


if [[ -z $APP_SECRET_KEY]]
    # Download directly
    wget http://s3.amazonaws.com/$APP_BUCKET/$APP_FILE
else
    # Move S3 Configuration file
    cp .s3cfg ~/.s3cfg

    # Download the package
    s3cmd get s3://$APP_BUCKET/$APP_FILE
fi

# Get the application archive
if [[ -z $APP_ARCHIVE ]]; then
	APP_ARCHIVE=$(find /app -name "*.zip")
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