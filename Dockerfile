FROM miskai/mono:3.12.0
MAINTAINER Roman Atachiants "roman@misakai.com"

# Application will be in app folder
WORKDIR /app
ADD . /app

# HTTP & HTTPS Ports
EXPOSE 80
EXPOSE 443

CMD ["/bin/bash", "/app/deploy.sh"]