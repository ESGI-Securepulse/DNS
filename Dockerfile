FROM coredns/coredns:1.11.3
RUN mkdir -p /etc/coredns
COPY Corefile /Corefile
COPY db.securepulse.fr /etc/coredns/db.securepulse.fr
EXPOSE 53/udp 53/tcp
CMD ["-conf", "/Corefile"]
