# Misakai.MonoApp
A simple way of deploying a .NET application inside a docker container. The simple deploy script pulls the code from an S3 bucket on startup.

In order to configure the docker container, set the following environment variables
```bash
APP_BUCKET: The name of the bucket that contains the file to download
APP_FILE: The path to the file inside the bucket
APP_ENTRY: The mono entry-point
AWS_ACCESS_KEY: The access key to use for S3
AWS_SECRET_KEY: The secret key to use for S3
```

# Mesos + Marathon

When this is used with Mesos and Marathon, you can also accomplish following things:
* **update**: you can update the application code simply by using a *rolling restart* of the application. Since the docker container will be restarted, this will trigger a fetch to your S3 bucket (which by the way should be versioned) and by doing so it will update the application code to the most recent version. If you are using versioned S3 bucket, you'll also have the way to roll-back the deployments by simply replacing the object in S3
* **restart on failure**: Marathon allows us to restart the application on failure, given that the healthchecks are properly configured.
