# Docker Base Image

Provides a minimal debian base image with apache and php. Sets up the apache, php, curl etc, enables mcrypt and rewrite.

## Usage

To use this image, create a dockerfile, import this image and select your port, run apache forground process.
If you wish to build on this image, you can do so without teh issue of having to restart apache as it does not start apache in the base image


Create a new docker file

```Dockerfile
FROM ulsmith/debian-apache-php
MAINTAINER You <you@your.email>

# Copy your files to working directory /var/www/html
# ADD ./ /var/www/html
# RUN chmod -R 0755 /var/www/html

EXPOSE 80
CMD ["/run.sh"]
```

Then create a docker-compose file in the same dir


```yml
version: '2'
services:
  myproject:
    build: ./
    container_name: my_project
    restart: always
    networks:
      - docker-localhost
    ports:
      - 80:80
networks:
  docker-localhost:
```

Add your files into the same folder that you want to run in the server, and build and up your container

```bash
docker-compose up -d
```

This will expose port 80 on the container with your chosen files loaded into the working dir.


## Proxy It!

A better solution is to run behind a proxy, such as traefik, which will dynamically route as containers come up!


```yml
version: '2'
services:
  traefik:
    image: traefik
    container_name: docker_traefik
    command: --docker.domain=docker.localhost
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.toml:/traefik.toml
    ports:
      - "80:80"
      - "8080:8080"
    networks:
      - docker-localhost
  myproject:
    build: ./
    container_name: my_project
    restart: always
    labels:
      - "traefik.backend=myproject"
      - "traefik.frontend.rule=Host:myproject.docker.localhost"
    networks:
      - docker-localhost
networks:
  docker-localhost:
```

You will need a toml config file for traefik in the same directory for this called traefik.toml

```toml
################################################################
# Web configuration backend
################################################################
[web]
address = ":8080"
################################################################
# Docker configuration backend
################################################################
[docker]
domain = "docker.localhost"
watch = true
```

Now you will be able to go to http://docker.localhost:8080 for a traefik ui and http://myproject.docker.localhost for your project.
