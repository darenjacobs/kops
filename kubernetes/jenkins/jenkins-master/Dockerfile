from jenkins/jenkins:lts
USER root

RUN apt-get update && apt-get install -y maven git vim tzdata
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/default-jvm
RUN cp /usr/share/zoneinfo/America/New_York /etc/localtime
RUN echo "America/New_York" > /etc/timezone
ENV JAVA_HOME /usr/lib/jvm/default-jvm/jre
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
USER jenkins
