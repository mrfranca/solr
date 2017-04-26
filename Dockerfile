FROM ubuntu:latest

MAINTAINER Marcelo França <marcelo.franca.neves@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV SOLR_USER solr

RUN apt-get update && apt-get install -y python-software-properties software-properties-common wget net-tools unzip zip vim supervisor sudo lsof curl ssh
RUN curl -L -b "oraclelicense=a" http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.tar.gz -O
RUN wget http://archive.apache.org/dist/lucene/solr/6.4.2/solr-6.4.2.zip
RUN apt-get clean autoclean && apt-get autoremove -y

RUN unzip solr-6.4.2.zip -d /opt/
RUN tar xzvf jdk-8u121-linux-x64.tar.gz -C /opt/
RUN rm -f solr-6.4.2.zip
RUN rm -f jdk-8u121-linux-x64.tar.gz
RUN ln -s /opt/jdk1.8.0_121 /opt/jdk8
RUN ln -s /opt/solr-6.4.2 /opt/solr


COPY solr.in.sh /etc/default/solr.in.sh
COPY solr.xml /opt/solr
COPY sshd_config /etc/ssh/sshd_config
COPY solr /usr/bin/solr
RUN /etc/init.d/ssh start

RUN echo "solr ALL=(ALL:ALL) ALL" >> /etc/sudoers
RUN useradd -m -s /bin/bash $SOLR_USER  && (echo 123mudar ; echo 123mudar) | passwd $SOLR_USER
RUN gpasswd -a $SOLR_USER sudo && usermod -d /opt/solr-6.4.2 $SOLR_USER
RUN cp /etc/skel/.bash* /opt/solr-6.4.2/
RUN chown $SOLR_USER. /opt/solr-6.4.2 -R && chown $SOLR_USER. /opt/jdk1.8.0_121 -R 

RUN echo export JAVA_HOME="/opt/jdk8" >> /etc/profile

ENV JAVA_HOME /opt/jdk8
ENV PATH /opt/jdk8/bin:$PATH
ENV TERM xterm

WORKDIR /opt/solr

EXPOSE 8983 22

CMD ["/usr/bin/sudo", "/usr/bin/solr"]
