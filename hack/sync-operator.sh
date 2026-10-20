#!/usr/bin/env bash
# Syncs the CRDs and the operator ClusterRole into a chart from the Kobblestone operator release named by the chart's
# `appVersion` (git tag v<appVersion> of github.com/kobblestoneio/kobblestone).
#
# Usage:
#   hack/sync-operator.sh            Sync files/ from the operator release matching appVersion.
#   hack/sync-operator.sh --check    Fail if files/ differ from that release (used in CI).
#
# Environment:
#   CHART             Chart directory (default: charts/kobblestone).
#   OPERATOR_REPO     Git URL or local path of the operator repo (default: https://github.com/kobblestoneio/kobblestone).
#   OPERATOR_REF      Git ref to sync from instead of v<appVersion>, e.g. a branch while developing. Never release a
#                     chart synced from anything but the appVersion tag; the --check in CI will reject it.
set -euo pipefail

mode="sync"
case "${1:-}" in
  "") ;;
  --check) mode="check" ;;
  *) echo "usage: $0 [--check]" >&2; exit 2 ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chart="$repo_root/${CHART:-charts/kobblestone}"
operator_repo="${OPERATOR_REPO:-https://github.com/kobblestoneio/kobblestone}"

app_version="$(sed -n 's/^appVersion: *//p' "$chart/Chart.yaml" | tr -d "\"'\r")"
if [[ -z "$app_version" ]]; then
  echo "error: no appVersion in $chart/Chart.yaml" >&2
  exit 1
fi
ref="${OPERATOR_REF:-v$app_version}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "fetching kustomize/generated from $operator_repo@$ref"
git clone --quiet --depth 1 --branch "$ref" --filter=blob:none --sparse "$operator_repo" "$tmp/operator" 2> "$tmp/clone.log" || {
  cat "$tmp/clone.log" >&2
  echo "error: could not fetch $ref from $operator_repo (is the operator release tagged?)" >&2
  exit 1
}
git -C "$tmp/operator" sparse-checkout set kustomize/generated
generated="$tmp/operator/kustomize/generated"

# Build the expected files/ tree, normalized to LF line endings.
expected="$tmp/files"
mkdir -p "$expected/crds" "$expected/rbac"
for crd in "$generated"/*_kobblestone_io.yaml; do
  sed 's/\r$//' "$crd" > "$expected/crds/$(basename "$crd" _kobblestone_io.yaml).yaml"
done
sed 's/\r$//' "$generated/operator-role.yaml" > "$expected/rbac/operator-role.yaml"

if [[ "$mode" == "check" ]]; then
  # Compare ignoring CR at line ends, so a Windows checkout with autocrlf doesn't fail the check.
  if diff -r --strip-trailing-cr "$expected" "$chart/files"; then
    echo "ok: $chart/files matches operator $ref"
  else
    echo "error: $chart/files is out of sync with operator $ref. Run hack/sync-operator.sh and commit the result." >&2
    exit 1
  fi
  exit 0
fi

rm -rf "$chart/files/crds" "$chart/files/rbac"
cp -r "$expected/crds" "$expected/rbac" "$chart/files/"
echo "synced $(ls "$expected/crds" | wc -l | tr -d ' ') CRDs and the ClusterRole from operator $ref into $chart/files"
