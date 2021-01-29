FROM alpine/helm:2.17.0
RUN apk --no-cache add git
COPY package.sh /package.sh
COPY helm-chart/ /helm-chart/
RUN chmod +x /package.sh
ENTRYPOINT ["/package.sh"]