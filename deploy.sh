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

# Get the application archive
if [[ -z $APP_ARCHIVE ]]; then
	APP_ARCHIVE=$(find /app -name "*.zip")
fi

# Make sure we have certificates we need
sudo mozroots --import --machine --sync
sudo certmgr -ssl -m https://go.microsoft.com
sudo certmgr -ssl -m https://nugetgallery.blob.core.windows.net
sudo certmgr -ssl -m https://nuget.org
sudo certmgr -ssl -m https://slack.com

# Unzip the package and delete the zip file
unzip -o $APP_ARCHIVE -d /app
rm $APP_ARCHIVE

# Precompile & run the application
mono --aot -O=all ${APP_ENTRY}
mono --gc=sgen ${APP_ENTRY} 