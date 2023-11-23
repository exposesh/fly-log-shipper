#!/bin/bash
set -euo pipefail

mkdir -p /var/secrets/
echo "$GOOGLE_APPLICATION_CREDENTIALS" > /var/secrets/GOOGLE_APPLICATION_CREDENTIALS.json
template() { eval $'cat <<_EOF\n'"$(awk '1;END{print"_EOF"}')"; }
sponge() { cat <<<"$(cat)" >"$1"; }
filter() { for i in "$@"; do template <"$i" | sponge "$i" || rm "$i"; done; }
filter /etc/vector/sinks/*.toml 2>&-
echo 'Configured sinks:'
find /etc/vector/sinks -type f -exec basename -s '.toml' {} \;

exec vector -c /etc/vector/vector.toml -C /etc/vector/sinks
