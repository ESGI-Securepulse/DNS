# Changelog — DNS

## [Unreleased]

### Corrigé
- **Dockerfile** : `RUN mkdir -p /etc/coredns` échouait systématiquement
  (`exec: "/bin/sh": stat /bin/sh: no such file or directory`) — l'image
  `coredns/coredns` est distroless (pas de shell), toute instruction `RUN`
  y échoue. Retiré ; `COPY` crée les répertoires de destination manquants
  tout seul, le `mkdir` préalable n'était pas nécessaire.
- **Corefile** : erreur de parsing au démarrage
  (`plugin/file: unknown property 'fallthrough'`) — le plugin `file` de
  l'image `coredns/coredns:1.11.3` ne supporte pas la sous-directive
  `fallthrough` (confirmé en testant plusieurs syntaxes), empêchant tout
  démarrage de CoreDNS. La zone statique (`file` + `db.securepulse.fr`,
  destinée à servir SOA/NS/MX devant les enregistrements dynamiques etcd en
  fallthrough) a été retirée du Corefile ; seul le plugin `etcd` sert
  désormais la zone `securepulse.fr` (SOA/NS auto-générés par le plugin).
  `db.securepulse.fr` est conservé dans le repo à titre de référence/
  documentation mais n'est plus chargé. Limitation connue : le MX explicite
  (`10 mail.securepulse.fr`) n'est plus servi — sans impact sur la
  découverte de service (tout repose sur les enregistrements A dynamiques).

Ces deux bugs empêchaient CoreDNS de démarrer *du tout* — non détectés
avant les tests d'intégration Docker multi-repos (LB-Syo), ce repo n'ayant
jamais été testé en conditions réelles jusqu'ici.

### Ajouté
- `deploy/` : déploiement réel (un site = un serveur dédié), distinct du
  banc de test mono-hôte (`docker-compose.yml`/`tests/`). L'image
  `coredns/coredns` étant distroless (pas de shell), le templating de
  l'endpoint etcd ne peut pas se faire au démarrage du conteneur comme
  ailleurs dans le projet (`envsubst` en entrypoint) : `Corefile.tpl` est
  rendu côté hôte de déploiement par `deploy/generate-config.sh`, puis
  monté par-dessus celui baké dans l'image (pas de rebuild par site).
  `deploy/deploy.sh <site>` lance le conteneur avec la config du site.
