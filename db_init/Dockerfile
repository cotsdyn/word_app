FROM ubuntu

WORKDIR /opt

COPY database .

RUN apt update && apt install -y mysql-client

CMD /bin/sh ./mysql-setup.sh && echo 'DB init OK'
