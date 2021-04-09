FROM debian:latest
MAINTAINER Ludovic MAILLET <Ludo.goodlinux@gmail.com>


#localtime zone
ENV TZ=Europe/Paris  SVG=/mnt/svg/

EXPOSE 8080 443
#If you want to save the Domoticz DataBase outside of the container
VOLUME /docker/domoticz/ /mnt/svg/

RUN apt-get update \ 
     && apt-get -f -y install libcurl4 unzip wget curl cron tzdata python3 libpython3-stdlib git libudev-dev libusb-dev \ 
     && cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ >  /etc/timezone  \ 
     && mkdir /opt/domoticz		\
     && cd /opt/domoticz		\
     && wget -O domoticz_release.tgz "https://releases.domoticz.com/releases/release/domoticz_linux_x86_64.tgz"		\
     && tar xvfz domoticz_release.tgz		\
     && rm domoticz_release.tgz		\
     && touch /opt/domoticz/domoticz.db	 \ 
     && chmod 644 /opt/domoticz/domoticz.db	 	 \ 
     &&  echo  "#!/usr/bin/env bash"					> /usr/bin/startdomo.sh  \
     &&  echo  "exec cron&"					>> /usr/bin/startdomo.sh  \
     &&  echo  "exec /opt/domoticz/domoticz -daemon&"	>> /usr/bin/startdomo.sh  \
     &&  echo  "exec /bin/sh -c bash"						>> /usr/bin/startdomo.sh  \
     && chmod a+x /usr/bin/startdomo.sh   \
     &&  echo echo "cp /opt/domoticz/domoticz.db " '$SVG'"\Base Domoticz "'$(date +%F)'".db" > /usr/local/bin/svgDomo.sh    \
     && chmod a+x /usr/local/bin/* 	 \
     &&  echo '00     5       */1       *       *       /usr/local/bin/svgDomo.sh' > /etc/cron.weekly/svgDomo.sh \
     && chmod a+x /etc/cron.weekly/svgDomo.sh                \
     && mkdir /opt/domoticz/plugins		\
     && cd /opt/domoticz/plugins		\
     && git clone https://github.com/guillaumezin/DomoticzLinky
	 
	 

# Lancement du daemon cron
CMD /bin/sh -c /usr/bin/startdomo.sh

