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
s3cmd -q get s3://$APP_BUCKET/$APP_FILE

# Get the application archive
if [[ -z $APP_ARCHIVE ]]; then
	APP_ARCHIVE=$(find /app -name "*.zip")
fi

# Make sure we have certificates we need
mozroots --import --machine --sync
certmgr -ssl -m https://go.microsoft.com
certmgr -ssl -m https://nugetgallery.blob.core.windows.net
certmgr -ssl -m https://nuget.org
certmgr -ssl -m https://slack.com

# Unzip the package and delete the zip file
unzip -qq -o $APP_ARCHIVE -d /app
rm $APP_ARCHIVE

# Ahead of time compilation
if [[ $MONO_ENABLE_AOT ]]; then
	mono --aot -O=all ${APP_ENTRY}
fi


# Run the application
mono --gc=sgen ${APP_ENTRY} 