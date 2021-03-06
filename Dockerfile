# Install Operating system and dependencies
FROM ubuntu:latest AS build-env

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN mkdir /usr/src/app/
COPY . /usr/src/app/
WORKDIR /usr/src/app/
RUN flutter build web --release --web-renderer=html

# make server startup script executable and start the web server
#RUN ["chmod", "+x", "/usr/src/app/server/server.sh"]

#ENTRYPOINT ["/usr/src/app/server/server.sh"]

FROM nginx:latest
COPY --from=build-env /usr/src/app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf