FROM mhart/alpine-node:6.2.0

MAINTAINER 	Dave Finster <davefinster@me.com>

WORKDIR /usr/src/app

RUN set -x \
	&& apk add --no-cache --virtual .npm-deps python make gcc linux-headers alpine-sdk \
	&& npm install --production \
	&& apk del .npm-deps
 
EXPOSE 3000

CMD ["node", "app.js"]