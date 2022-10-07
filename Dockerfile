# Stable (Oct 4th, 2022)
FROM nginx:1.22.0-alpine

COPY start.sh /usr/local/bin/

RUN apk add --update bash \
	&& rm -rf /var/cache/apk/* \
	&& chmod +x /usr/local/bin/start.sh
	
CMD ["start.sh"]
