# Changelog

## kobblestone 0.3.1

Operator version: `0.4.1`

- Update the operator to [v0.4.1](https://github.com/kobblestoneio/kobblestone/blob/main/CHANGELOG/CHANGELOG-0.4.md#v041):
  `Command`s are sent to a server one at a time, so concurrent commands no longer get each other's output on Vanilla
  servers, and `CommandGroup`s report name conflicts with existing `Command`s. The CRDs and the ClusterRole are
  unchanged.

## kobblestone 0.3.0

Operator version: `0.4.0`

- Update the operator to [v0.4.0](https://github.com/kobblestoneio/kobblestone/blob/main/CHANGELOG/CHANGELOG-0.4.md#v040).
  **Breaking:** Kubernetes 1.32 or newer is required (`kubeVersion: ">=1.32.0-0"`): the CRDs declare `selectableFields`.
  `Server`s and `Network`s created with an earlier operator version have to be re-created, because their `Secret`s
  have no owner (they report `SecretConflict`). See the operator's upgrade notes.
- Add the `FileBrowser` CRD: file access to `Server`s, `Backup`s and `BackupRepo`s through a web interface, SFTP,
  WebDAV and a REST API.
- Update the CRDs: configurable resources for every container (e.g. `Server` `spec.pod.proxyResources`, `Account`
  `spec.authorization.pod.resources`), `job.nodeSelector` and `job.ttlSecondsAfterFailure` for `Backup`s and
  `Restore`s, `authorization.ttlSecondsAfterFailure` and `status.lastFailure` for `Account`s, and the replica counts
  of `Router`s in `status`.
- Update the operator's ClusterRole for `FileBrowser`s: the operator now manages `Deployment`s, `NetworkPolicy`s,
  `HTTPRoute`s and `TCPRoute`s for them, deletes `Pod`s, reads `PersistentVolumeClaim`s and lists
  `BackupRepo`s.

## kobblestone 0.2.0

Operator version: `0.3.0`

- Update the operator to [v0.3.0](https://github.com/kobblestoneio/kobblestone/blob/main/CHANGELOG/CHANGELOG-0.3.md#v030).
  **Breaking:** the `Network` CRD changed incompatibly. A `Network` now creates and manages its servers from
  `spec.serverTemplate` and `spec.servers`; existing `Network` resources have to be rewritten before upgrading. See the
  operator's upgrade notes.
- Update the `Server` CRD: new field `spec.forwarding` to accept players forwarded by a Velocity proxy.
- Update the operator's ClusterRole: the operator now manages `ConfigMap`s (forwarding configuration of servers),
  watches the `Deployment`s of networks and creates, updates and deletes `Server`s.

## kobblestone 0.1.2

Operator version: `0.2.1`

- Update the operator to [v0.2.1](https://github.com/kobblestoneio/kobblestone/blob/main/CHANGELOG/CHANGELOG-0.2.md#v021).
- Update the `Bot` CRD: volume names starting with `kobblestone-` are now documented as reserved.

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
