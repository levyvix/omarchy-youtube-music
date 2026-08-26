#!/bin/bash

set -euo pipefail

plugin_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

mkdir "$test_dir/Plugin"
cp "$plugin_dir/Panel.qml" "$test_dir/Plugin/Panel.qml"
cp "$plugin_dir/tests/bar-color-shell.qml" "$test_dir/shell.qml"
ln -s /usr/share/omarchy/shell/Commons "$test_dir/Commons"
ln -s /usr/share/omarchy/shell/Ui "$test_dir/Ui"

output=$(timeout 5s quickshell -p "$test_dir" 2>&1 || true)

if grep -q "TEST_PASS" <<<"$output"; then
  exit 0
fi

printf '%s\n' "$output"
exit 1
