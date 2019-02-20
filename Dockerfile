FROM node:10.12.0-alpine as builder

LABEL maintainer-team="SEE-OID"
LABEL maintainer-email="see-oid@square-enix.com"

ARG GIT_BRANCH
ARG GIT_COMMIT
ARG DEPLOYMENT

ENV WORKDIR /usr/src/app
WORKDIR $WORKDIR
RUN mkdir -p $WORKDIR

COPY ./src ./public
COPY ./nginx.conf ./nginx.conf
COPY ./http_lang.pm ./http_lang.pm

FROM nginx:alpine-perl

RUN apk add --no-cache nano spawn-fcgi fcgiwrap wget curl

# COPY ./dockerconfig/htaccess /etc/nginx/.htaccess
COPY --from=builder /usr/src/app/nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /usr/src/app/public /var/www/html/
COPY --from=builder /usr/src/app/http_lang.pm /usr/lib/perl5/core_perl/http_lang.pm

ENV PORT 8080
