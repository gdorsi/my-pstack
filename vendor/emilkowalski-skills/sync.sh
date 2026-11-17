#!/usr/bin/env bash
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(cd "$here/../.." && pwd)
manifest=$here/manifest

update=0
case "${1:-}" in
  "") ;;
  --update) update=1 ;;
  *) echo "usage: sync.sh [--update]" >&2; exit 2 ;;
esac

repo=""
commit=""
names=()
while read -r key value extra; do
  case "$key" in
    ""|"#"*) ;;
    repo) repo=$value ;;
    commit) commit=$value ;;
    skill) names+=("$value") ;;
    *) echo "error: unknown manifest line '$key $value $extra'" >&2; exit 1 ;;
  esac
done < "$manifest"

[ -n "$repo" ] || { echo "error: manifest has no repo line" >&2; exit 1; }
[[ $commit =~ ^[0-9a-f]{40}$ ]] || { echo "error: manifest commit is not a full 40-char sha" >&2; exit 1; }
[ "${#names[@]}" -gt 0 ] || { echo "error: manifest lists no skills" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
up=$tmp/upstream

ref=$commit
[ "$update" = 1 ] && ref=HEAD
echo "fetching $repo @ $ref"
git init -q "$up"
# A shallow fetch by sha works on GitHub only because it allows fetching any reachable sha.
git -C "$up" fetch -q --depth 1 "$repo" "$ref"
git -C "$up" -c advice.detachedHead=false checkout -q FETCH_HEAD
sha=$(git -C "$up" rev-parse HEAD)

for name in "${names[@]}"; do
  [ -f "$up/skills/$name/SKILL.md" ] || {
    echo "error: manifest lists skill '$name' but $repo @ ${sha:0:7} has no skills/$name/SKILL.md" >&2
    exit 1
  }
done

for name in "${names[@]}"; do
  echo "copying skills/$name"
  rsync -a --delete "$up/skills/$name/" "$root/skills/$name/"
done

for name in "${names[@]}"; do
  file=$root/skills/$name/SKILL.md
  awk '
    NR == 1 && $0 == "---" { infm = 1; print; next }
    infm && /^disable-model-invocation:/ { print "disable-model-invocation: true"; seen = 1; next }
    infm && $0 == "---" { if (!seen) print "disable-model-invocation: true"; infm = 0 }
    { print }
  ' "$file" > "$tmp/SKILL.md"
  mv "$tmp/SKILL.md" "$file"
done

echo "copying LICENSE"
cp "$up/LICENSE" "$here/LICENSE"

if [ "$update" = 1 ]; then
  echo "pinning manifest to $sha"
  sed "s/^commit .*/commit $sha/" "$manifest" > "$tmp/manifest"
  mv "$tmp/manifest" "$manifest"
fi

check() {
  local fail=0 file dir ref line name vendored
  local upstream=()
  for dir in "$up"/skills/*/; do
    upstream+=("$(basename "$dir")")
  done

  while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      [ -e "$dir/$ref" ] || { echo "broken path: ${file#"$root"/} -> $ref"; fail=1; }
    done < <(grep -oE '(\.\./)+[A-Za-z0-9_@./-]*' "$file" | sed -E 's/[.,;:)`]+$//' || true)
  done < <(find "$root/skills" -name '*.md' -print0)

  for vendored in "${names[@]}"; do
    for name in "${upstream[@]}"; do
      grep -qxF "skill $name" "$manifest" && continue
      while IFS= read -r line; do
        echo "dangling name: ${line#"$root"/} is not in the manifest"
        fail=1
      done < <(grep -rnoF --include='*.md' -e "\`$name\`" -e "\`/$name\`" "$root/skills/$vendored" || true)
    done
  done

  for name in "${names[@]}"; do
    awk 'NR == 1 && $0 == "---" { infm = 1; next } infm && $0 == "---" { exit } infm' "$root/skills/$name/SKILL.md" |
      grep -qxF 'disable-model-invocation: true' || {
        echo "model-invocable: skills/$name/SKILL.md lacks disable-model-invocation: true"
        fail=1
      }
  done

  [ "$fail" = 0 ] || return 1
  echo "ok: ${#names[@]} skills @ ${sha:0:7}"
}

check
