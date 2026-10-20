# Changelog

## kobblestone 0.1.1

Operator version: `0.2.0`

- Fix the operator pod failing to start with `container has runAsNonRoot and image has non-numeric user`. The pod now
  runs as UID/GID `1654` (the `app` user of the .NET base image) by default (`podSecurityContext.runAsUser`/`runAsGroup`).

## kobblestone 0.1.0

Operator version: `0.2.0`

- Initial chart: operator Deployment, ServiceAccount, ClusterRole/ClusterRoleBinding, Service for the auto-sleep webhook,
  and the 11 Kobblestone CRDs.
- CRDs are installed and upgraded with the release and kept on uninstall by default (`crds.install`, `crds.keep`).
- The operator listens on port `8080` (the image default) instead of `80` as in `kobblestone.yaml`, so it can run as
  non-root with all capabilities dropped.
