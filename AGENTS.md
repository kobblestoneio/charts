# Kobblestone Helm charts

Helm chart for the Kobblestone operator (`github.com/kobblestoneio/kobblestone`), in `charts/kobblestone`. Changes are
recorded in `CHANGELOG.md`; CI (`.github/workflows`) runs chart-testing (`ct.yaml`) and releases.

## CRDs and RBAC

- `files/crds/*.yaml` and `files/rbac/operator-role.yaml` are **not edited by hand**. Sync them from the operator release
  named by `appVersion` in `Chart.yaml`, with `hack/sync-operator.sh`. CI runs `hack/sync-operator.sh --check`.
  `OPERATOR_REF=<branch>` syncs from a branch while developing; never release a chart synced that way.
- CRDs are rendered as regular templates (`templates/crds.yaml`), not from `crds/`, so `helm upgrade` updates them.
  This also means `helm uninstall` **deletes** them, and with them every Kobblestone resource on the cluster, unless
  `crds.keep: true` (the default) added `helm.sh/resource-policy: keep`.

## Uninstalling on a cluster with real resources

Before `helm uninstall`, confirm that every CRD in `helm get manifest <release>` carries
`helm.sh/resource-policy: keep` (Helm checks the release manifest, not the live object). Then the uninstall only removes
the operator Deployment, Service, ServiceAccount and ClusterRole/Binding.

## Reinstalling after local operator development

Local operator runs and `kubectl apply` of the operator manifest take over fields of the CRDs. Installing the chart
afterwards then fails with `conflict with "kubectl-client-side-apply" ... .spec.versions`. Install with
`--take-ownership` (or force the server-side-apply conflicts), and check that the CRD versions match `appVersion`.
CRDs added by newer local builds (not in the chart) stay on the cluster.
