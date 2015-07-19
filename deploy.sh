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

# Make sure our application folder is empty
if [[ -d /app ]]; then
	rm -rf /app
	mkdir /app
	cd /app
fi

# Download the package
s3cmd get s3://$APP_BUCKET/$APP_FILE

# Unzip the package
unzip -o $(find /app -name "*.zip") -d /app

# Precompile & run the application
mono --aot -O=all ${APP_ENTRY}
mono --gc=sgen ${APP_ENTRY} 