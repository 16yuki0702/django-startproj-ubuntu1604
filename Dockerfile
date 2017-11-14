FROM ubuntu:16.04

MAINTAINER 16yuki0702

RUN apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y \
	git \
	vim \
	curl \
	sudo \
	apt-transport-https \
	lsb-release \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	language-pack-ja-base \
	language-pack-ja \
	nginx \
	supervisor \
	mysql-client \
	libmysqlclient-dev && \
	pip3 install -U pip setuptools && \
	rm -rf /var/lib/apt/lists/*

RUN pip3 install uwsgi
RUN mkdir -p /home/docker/uwsgi/log && \
	mkdir -p /home/docker/uwsgi/app

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisor.conf /etc/supervisor/conf.d/
COPY uwsgi.ini /home/docker/uwsgi
COPY uwsgi_params /home/docker/uwsgi
COPY requirement.txt /home/docker/

RUN pip3 install -r /home/docker/requirement.txt
RUN django-admin.py startproject proj /home/docker/uwsgi/app/

COPY settings.py /home/docker/uwsgi/app/proj/

RUN cd /home/docker/uwsgi/app/ && \
	virtualenv appenv && \
	/bin/bash -c "source /home/docker/uwsgi/app/appenv/bin/activate && \
	pip3 install -r /home/docker/requirement.txt"

#mosquitto
RUN apt-get update && \
	apt-get install -y mosquitto mosquitto-clients

#gcloud
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
	echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
	apt-get update && \
	sudo apt-get install -y google-cloud-sdk

ENV LANG=ja_JP.UTF-8

#vim
RUN apt-get install -y wget libncurses-dev && \
	cd /usr/local/src/ && \
	wget http://tamacom.com/global/global-6.5.6.tar.gz && \
	tar zxvf global-6.5.6.tar.gz && \
	cd global-6.5.6 && \
	./configure && \
	make && \
	make install && \
	mkdir -p ~/.vim/plugin/ && \
	cp /usr/local/share/gtags/gtags.conf /etc/ && \
	cp /usr/local/share/gtags/gtags.vim ~/.vim/plugin/gtags.vim && \
	pip install pygments && \
	sed -i -e 's/\*min\.css/\*min\.css,\*.mo/g' /etc/gtags.conf && \
	sed -i -e 's/\/usr\/bin\/python/\/usr\/bin\/env python3/g' /usr/local/share/gtags/script/pygments_parser.py && \
	cd /home/docker/uwsgi/app/ && \
	gtags --gtagslabel=pygments -v
COPY vimrc /root/.vimrc

EXPOSE 80
CMD ["supervisord", "-n"]
