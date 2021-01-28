FROM alpine/helm:2.14.0
COPY package.sh /package.sh
ENTRYPOINT ["/package.sh"]