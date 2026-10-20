# Kobblestone Helm charts

Helm charts for [Kobblestone](https://kobblestone.io), the operator that runs Minecraft the Kubernetes way.

## Usage

```sh
helm repo add kobblestone https://kobblestoneio.github.io/charts
helm repo update
helm install kobblestone kobblestone/kobblestone --namespace kobblestone-system --create-namespace
```

Charts are also published as OCI artifacts:

```sh
helm install kobblestone oci://ghcr.io/kobblestoneio/charts/kobblestone --namespace kobblestone-system --create-namespace
```

## Charts

| Chart | Description |
| --- | --- |
| [kobblestone](charts/kobblestone) | The Kobblestone operator and its CRDs. |

## Development

```sh
helm lint charts/kobblestone --strict
helm template kobblestone charts/kobblestone -n kobblestone-system
```

The CRDs and the operator's ClusterRole are not written by hand. They are copied from the operator repo's generated
manifests (`kustomize/generated`):

```sh
hack/sync-operator.sh ../kobblestone
```

### Releasing

1. Sync the CRDs and RBAC from the operator release (see above).
2. Bump `version` in the chart's `Chart.yaml`, and `appVersion` when it ships a new operator version.
3. Add an entry to [CHANGELOG.md](CHANGELOG.md) and merge to `main`. Merging alone publishes nothing.
4. Publish a GitHub release whose tag is `<chart>-<version>`, e.g. `kobblestone-0.1.0`. The version must match the
   chart's `Chart.yaml`. The [release workflow](.github/workflows/release.yaml) then attaches the packaged chart to the
   release, adds it to the Helm repo index on the `gh-pages` branch and pushes it to `ghcr.io/kobblestoneio/charts`.

Pull requests that touch a chart are linted and installed into a kind cluster by the
[lint and test workflow](.github/workflows/lint-test.yaml). Chart changes require a version bump.

## License

[Apache 2.0](LICENSE)
