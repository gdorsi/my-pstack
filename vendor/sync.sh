#!/usr/bin/env bash
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
root=$(dirname "$here")

usage() { echo "usage: vendor/sync.sh [--update [<upstream>]]" >&2; exit 2; }
die() { echo "error: $*" >&2; exit 1; }

update=0
only=""
case $# in
  0) ;;
  1) [ "$1" = --update ] || usage; update=1 ;;
  2) { [ "$1" = --update ] && [ -n "$2" ]; } || usage; update=1; only=$2 ;;
  *) usage ;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

set_once() {
  [ -z "${!1}" ] || die "$id: duplicate '$1' line"
  printf -v "$1" %s "$2"
}

safe_relpath() {
  [[ $1 =~ ^[A-Za-z0-9._][A-Za-z0-9._/-]*$ ]] && [[ /$1/ != */../* ]]
}

parse_manifest() {
  local key value extra
  manifest=$1
  id=$(basename "$(dirname "$manifest")")
  repo="" commit="" path="" license="" names=()
  while read -r key value extra; do
    case "$key" in
      ""|"#"*) ;;
      repo|commit|path|license) set_once "$key" "$value" ;;
      skill)
        [[ $value =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "$id: bad skill name '$value'"
        names+=("$value") ;;
      *) die "$id: unknown manifest line '$key $value $extra'" ;;
    esac
  done < "$manifest"

  [ -n "$repo" ] || die "$id: manifest has no repo line"
  [[ $commit =~ ^[0-9a-f]{40}$ ]] || die "$id: manifest commit is not a full 40-char sha"
  safe_relpath "$path" || die "$id: manifest path '$path' is missing or not a relative path inside the upstream"
  [ -z "$license" ] || safe_relpath "$license" || die "$id: manifest license '$license' is not a relative path inside the upstream"
  [ "${#names[@]}" -gt 0 ] || die "$id: manifest lists no skills"
}

check_owners() {
  local dups
  dups=$(awk '
    $1 == "skill" { n = split(FILENAME, parts, "/"); owners[$2] = owners[$2] " " parts[n - 1]; count[$2]++ }
    END { for (name in count) if (count[name] > 1) print "error: skill " name " is listed by" owners[name] }
  ' "$@")
  [ -z "$dups" ] || { echo "$dups" >&2; exit 1; }
}

check_upstream() {
  local src=$1 sha=$2 dir name line vendored bad=0
  local upstream=()
  for dir in "$src"/*/; do
    [ -f "$dir/SKILL.md" ] && upstream+=("$(basename "$dir")")
  done

  for vendored in "${names[@]}"; do
    for name in "${upstream[@]}"; do
      grep -qxF "skill $name" "$manifest" && continue
      while IFS= read -r line; do
        echo "dangling name: ${line#"$root"/} is not in the manifest"
        bad=1
      done < <(grep -rnoF --include='*.md' -e "\`$name\`" -e "\`/$name\`" "$root/skills/$vendored" || true)
    done
  done

  for name in "${names[@]}"; do
    awk 'NR == 1 && $0 == "---" { infm = 1; next } infm && $0 == "---" { exit } infm' "$root/skills/$name/SKILL.md" |
      grep -qxF 'disable-model-invocation: true' || {
        echo "model-invocable: skills/$name/SKILL.md lacks disable-model-invocation: true"
        bad=1
      }
    [ -n "$license" ] || [ -f "$root/skills/$name/LICENSE" ] || {
      echo "unlicensed: skills/$name"
      bad=1
    }
  done

  if [ "$bad" = 0 ]; then
    echo "ok: $id ${#names[@]} skill(s) @ ${sha:0:7}"
  else
    fail=1
  fi
}

sync_upstream() {
  parse_manifest "$1"
  local up=$tmp/$id ref=$commit name file sha
  if [ "$update" = 1 ] && { [ -z "$only" ] || [ "$only" = "$id" ]; }; then
    ref=HEAD
  fi

  echo "fetching $repo @ $ref"
  git init -q "$up"
  # A shallow fetch by sha works on GitHub only because it allows fetching any reachable sha.
  git -C "$up" fetch -q --depth 1 "$repo" "$ref"
  git -C "$up" -c advice.detachedHead=false checkout -q FETCH_HEAD
  sha=$(git -C "$up" rev-parse HEAD)

  for name in "${names[@]}"; do
    [ -f "$up/$path/$name/SKILL.md" ] || die "$id: manifest lists skill '$name' but $repo @ ${sha:0:7} has no $path/$name/SKILL.md"
  done

  for name in "${names[@]}"; do
    echo "copying skills/$name"
    rsync -a --delete "$up/$path/$name/" "$root/skills/$name/"
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

  if [ -n "$license" ]; then
    echo "copying $license"
    cp "$up/$license" "$here/$id/LICENSE"
  fi

  if [ "$ref" = HEAD ]; then
    echo "pinning $id to $sha"
    sed "s/^commit .*/commit $sha/" "$manifest" > "$tmp/manifest"
    mv "$tmp/manifest" "$manifest"
  fi

  check_upstream "$up/$path" "$sha"
}

check_paths() {
  local file dir ref
  while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      [ -e "$dir/$ref" ] || { echo "broken path: ${file#"$root"/} -> $ref"; fail=1; }
    done < <(grep -oE '(\.\./)+[A-Za-z0-9_@./-]*' "$file" | sed -E 's/[.,;:)`]+$//' || true)
  done < <(find "$root/skills" -name '*.md' -print0)
}

manifests=("$here"/*/manifest)
known=0
for m in "${manifests[@]}"; do
  parse_manifest "$m"
  [ "$id" != "$only" ] || known=1
done
if [ -n "$only" ] && [ "$known" = 0 ]; then
  echo "usage: no vendor/$only/manifest" >&2
  exit 2
fi
check_owners "${manifests[@]}"

for m in "${manifests[@]}"; do
  sync_upstream "$m"
done
check_paths

exit "$fail"
