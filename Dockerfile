FROM python:3-alpine

RUN apk add --no-cache --virtual .build-dependencies gcc linux-headers geoip-dev musl-dev openssl tar \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.14.0/confd-0.14.0-linux-amd64 \
  && chmod a+x /usr/bin/confd \
  && pip install gunicorn

ENV VERSION=14e82281bec8ed0e67341317324bac719720da65

RUN mkdir /openvpn-monitor \
  && wget -O - https://github.com/furlongm/openvpn-monitor/archive/${VERSION}.tar.gz | tar -C /openvpn-monitor --strip-components=1 -zxvf - \
  && pip install /openvpn-monitor 

RUN apk del .build-dependencies

RUN mkdir -p /usr/share/GeoIP/ \
  && cd /usr/share/GeoIP/ \
  && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
  && gunzip GeoLiteCity.dat.gz \
  && mv GeoLiteCity.dat GeoIPCity.dat

RUN apk add --no-cache geoip

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /openvpn-monitor

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["gunicorn", "openvpn-monitor", "--bind", "0.0.0.0:80"]
