FROM coredns/coredns:1.11.3
# Pas de RUN ici : l'image coredns/coredns est distroless (pas de /bin/sh),
# toute instruction RUN échoue. COPY crée les répertoires de destination
# manquants tout seul, un mkdir préalable n'est pas nécessaire.
COPY Corefile /Corefile
COPY db.securepulse.fr /etc/coredns/db.securepulse.fr
EXPOSE 53/udp 53/tcp
CMD ["-conf", "/Corefile"]
