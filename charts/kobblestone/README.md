# Kobblestone Helm chart

Installs the [Kobblestone](https://kobblestone.io) operator, which runs Minecraft servers, proxies, routing, backups and
bots on Kubernetes through custom resources.

> [!WARNING]
> Kobblestone is **alpha and highly experimental**. All resources are `v1alpha1`, and fields and behavior can change
> between releases.

## Install

```sh
helm repo add kobblestone https://kobblestoneio.github.io/charts
helm install kobblestone kobblestone/kobblestone --namespace kobblestone-system --create-namespace
```

Or straight from the OCI registry:

```sh
helm install kobblestone oci://ghcr.io/kobblestoneio/charts/kobblestone \
  --namespace kobblestone-system --create-namespace
```

## CRDs

The chart installs **and upgrades** the Kobblestone CRDs as part of the release (they are templates, not Helm's
install-only `crds/` directory). By default they carry `helm.sh/resource-policy: keep`, so `helm uninstall` leaves them
and all your `Server`s, `Backup`s etc. in place. To remove everything:

```sh
helm uninstall kobblestone -n kobblestone-system
kubectl get crd -o name | grep kobblestone.io | xargs kubectl delete
```

Set `crds.install=false` to manage the CRDs yourself.

## Values

| Key | Default | Description |
| --- | --- | --- |
| `crds.install` | `true` | Install and upgrade the CRDs with the release. |
| `crds.keep` | `true` | Keep the CRDs on `helm uninstall`. |
| `image.repository` | `ghcr.io/kobblestoneio/kobblestone` | Operator image. |
| `image.tag` | `""` | Defaults to the chart's `appVersion`. |
| `image.digest` | `""` | Pin the image by digest; takes precedence over the tag. |
| `image.pullPolicy` | `IfNotPresent` | |
| `imagePullSecrets` | `[]` | |
| `replicaCount` | `1` | Only the elected leader reconciles; extra replicas are standbys. |
| `serviceAccount.create` | `true` | |
| `serviceAccount.name` | `""` | Generated from the release name if empty. |
| `serviceAccount.annotations` | `{}` | |
| `rbac.create` | `true` | Create the operator's ClusterRole and ClusterRoleBinding. |
| `containerPort` | `8080` | Port of the operator's HTTP server (auto-sleep webhook). |
| `service.enabled` | `true` | Expose the operator's HTTP server inside the cluster. |
| `service.type` | `ClusterIP` | |
| `service.port` | `80` | |
| `extraEnv` | `[]` | Extra environment variables for the operator container. |
| `resources` | requests `50m`/`64Mi`, limits `500m`/`500Mi` | |
| `podSecurityContext` | non-root, `RuntimeDefault` seccomp | |
| `securityContext` | no privilege escalation, all capabilities dropped | |
| `livenessProbe` / `readinessProbe` | `{}` | |
| `extraVolumes` / `extraVolumeMounts` | `[]` | |
| `podAnnotations` / `podLabels` | `{}` | |
| `nodeSelector` / `tolerations` / `affinity` | empty | |
| `priorityClassName` | `""` | |
| `terminationGracePeriodSeconds` | `10` | |
| `revisionHistoryLimit` | `3` | |

## Migrating from `kobblestone.yaml`

If Kobblestone was installed with `kubectl apply -f .../kobblestone.yaml`, the CRDs already exist without Helm ownership
and the install fails. Either delete the old operator resources (keeping the CRDs) and adopt the CRDs into the release:

```sh
for crd in $(kubectl get crd -o name | grep kobblestone.io); do
  kubectl annotate "$crd" meta.helm.sh/release-name=kobblestone meta.helm.sh/release-namespace=kobblestone-system --overwrite
  kubectl label "$crd" app.kubernetes.io/managed-by=Helm --overwrite
done
kubectl delete deployment,service -n kobblestone-system -l operator=kobblestone
kubectl delete clusterrole kobblestone-operator-role
kubectl delete clusterrolebinding kobblestone-operator-role-binding
```

or install with `--set crds.install=false` and keep applying the CRDs yourself.
