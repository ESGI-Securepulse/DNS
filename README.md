# DNS — CoreDNS + etcd

Sert la zone `securepulse.fr` pour toute la plateforme SecurePulse. Toutes
les résolutions (contrôle : `master.<domain>` ; mail public :
`mail.<domain>` ; découverte de service : `<service>.<site>.<domain>` /
`<service>.all.<domain>`) passent par le plugin `etcd` de CoreDNS, lu par
les enregistrements que chaque brique (LDAP, Mail, LB-Syo, storage-lucien)
publie/retire elle-même au démarrage/arrêt (`/skydns/...`).

Voir `CHANGELOG.md` pour deux bugs de démarrage corrigés lors des tests
d'intégration (Dockerfile sur image distroless, syntaxe Corefile).

## Build & test rapide

```sh
docker build -t securepulse-dns .
docker run --rm -p 15053:53/udp securepulse-dns
```

Testé en intégration dans `LB-Syo/tests/docker-compose.test.yml` (résolution
réelle de `master.securepulse.fr`, `postfix.<site>.securepulse.fr`, etc.,
via un HAProxy réel).

## Hors scope

- Délégation de zone publique réelle (API OVH) — hors scope de la
  simulation Docker, cf. rapport (choix On-Prem pour les tests).
- MX explicite — retiré suite au bug Corefile documenté dans le
  CHANGELOG (limitation connue, sans impact sur la découverte de service).
