FROM centos:6.8

RUN yum install -y openssh openssh-server openssh-clients perl nc sudo sysstat wget bind bind-utils gettext

EXPOSE 22 25 465 587 110 143 993 995 80 443 8080 8443 7071

COPY install.sh /
COPY setup_dns.sh /
COPY install_override /
#COPY *.tgz /

CMD ["/bin/bash", "/install.sh", "-d"]
