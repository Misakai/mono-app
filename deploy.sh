#!/bin/bash 

# Configuration
# -------------
# APP_BUCKET: The name of the bucket that contains the file to download
# APP_FILE: The path to the file inside the bucket
# APP_ENTRY: The mono entry-point
# AWS_ACCESS_KEY: The access key to use for S3
# AWS_SECRET_KEY: The secret key to use for S3

# Move S3 Configuration file
cp .s3cfg ~/.s3cfg

# Download the package
s3cmd get s3://$APP_BUCKET/$APP_FILE

# Unzip the package
unzip $(find /app -name "*.zip") -d /app

# Mount the bucket in S3FS (read-write)
export AWSACCESSKEYID=$AWS_ACCESS_KEY
export AWSSECRETACCESSKEY=$AWS_SECRET_KEY
/usr/bin/s3fs -o allow_other -o use_cache=/tmp $APP_BUCKET /data

# Precompile & run the application
mono --aot -O=all ${APP_ENTRY}
mono --gc=sgen ${APP_ENTRY} 