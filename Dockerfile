# Example docker run command
# docker run -p 10050:10050 -p 10050:10050 -p 80:80 -p 443:443 oso-rhel7-zaio
# /root/start.sh will then start the mysqldb, zabbix, and httpd services.
# Default login:password to Zabbix is Admin:zabbix

FROM oso-rhel7-ops-base:latest

RUN echo "root:redhat" | chpasswd

RUN yum clean metadata && \
    yum install -y iproute iputils pylint python-pip \
        python-requests python-django \
        openshift-tools-web-zagg \
        openshift-tools-scripts-monitoring \
        tree python-django-bash-completion httpd mod_wsgi \
        telnet bind-utils net-tools iproute && \
    yum clean all

RUN pip install djangorestframework && \
    pip install markdown && \
    pip install django-filter

RUN mkdir /tmp/metrics && chown apache.apache /tmp/metrics

# TODO: package these!!! (see trello card https://trello.com/c/SJsvV9OQ)
#       and add that RPM to this container
ADD zbxapi.py /usr/share/ansible/zbxapi.py
ADD oo_filters.py /usr/share/ansible_plugins/filter_plugins/oo_filters.py
# END TODO

ADD config.yml /root/config.yml

EXPOSE 8000
EXPOSE 8443

RUN chmod -R 777 /opt/rh/zagg
RUN chmod -R 777 /var/run/httpd
RUN chmod -R 777 /etc/httpd
RUN chmod -R 777 /var/log/httpd
RUN chmod -R 777 /tmp/metrics

# Start apache
ADD start.sh /usr/local/bin/
CMD /usr/local/bin/start.sh
