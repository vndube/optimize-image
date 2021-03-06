FROM registry.access.redhat.com/ubi8/ubi:8.0
MAINTAINER Red Hat Training <training@redhat.com>
# DocumentRoot for Apache

LABEL io.k8s.description="A basic Apache HTTP Server parent image, ONBUILD" \
      io.k8s.display-name="Apache HTTP Server" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="apache,httpd"

ENV DOCROOT=/var/www/html

RUN yum install -y --disableplugin=subscription-manager httpd && \
    yum clean all --disableplugin=subscription-manager -y && \
    rm -rf /run/httpd && mkdir /run/httpd  && \
    echo "Hello from the httpd-parent container!" > ${DOCROOT}/index.html  && \
    adduser ex288-sa --system && \
    sed -i "s/Listen 80/Listen 8080/g" /etc/httpd/conf/httpd.conf && \
    sed -i "s/#ServerName www.example.com:80/ServerName 0.0.0.0:8080/g" /etc/httpd/conf/httpd.conf && \
    chown -R ex288-sa:0 /var/log/httpd /var/run/httpd /etc/httpd/run /etc/httpd/logs /run/httpd && \
    chmod -R 755 /var/log/httpd /var/run/httpd /etc/httpd/run /etc/httpd/logs /run/httpd 

    #chgrp -R 0 /var/log/httpd /var/run/httpd /etc/httpd/run /etc/httpd/logs /run/httpd && \
    #chmod -R g=u /var/log/httpd /var/run/httpd /etc/httpd/run /etc/httpd/logs /run/httpd 

	
# Allows child images to inject their own content into DocumentRoot
ONBUILD COPY src/ ${DOCROOT}/

EXPOSE 8080

#D This stuff is needed to ensure a clean start

COPY ./start-apache.sh /run/httpd/.

#USER 1001

# Run as the root user
USER ex288-sa

# Launch httpd
#CMD /usr/sbin/httpd -DFOREGROUND
CMD /run/httpd/start-apache.sh


