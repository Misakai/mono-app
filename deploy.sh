#!/bin/bash 

# Configuration
# -------------
# APP_BUCKET: The name of the bucket that contains the file to download
# APP_FILE: The path to the file inside the bucket
# APP_ENTRY: The mono entry-point
# AWS_ACCESS_KEY: The access key to use for S3
# AWS_SECRET_KEY: The secret key to use for S3

# Move S3 Configuration file
apt-get install -y s3cmd
cp .s3cfg ~/.s3cfg

# App-specific, we need libgdiplus
apt-get install -y libgdiplus

# Download the package
s3cmd get s3://$APP_BUCKET/$APP_FILE

# Unzip the file and delete the zip
unzip $(find /app -name "*.zip") -d /app
rm -rf ${APP_FILE}

# Tuning GC
export MONO_GC_PARAMS="soft-heap-limit=512m,nursery-size=128m,major=marksweep-conc,minor=split"

# Run the application
mono --aot -O=all ${APP_ENTRY}