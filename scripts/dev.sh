#!/usr/bin/env bash
# Pipeline de dev GardenParty : git -> préparation -> tests -> lancement.
# Usage : ./scripts/dev.sh        (menu interactif)
#         ./scripts/dev.sh all    (tout enchaîner sans menu, cible linux)
set -euo pipefail
cd "$(dirname "$0")/.."

PLATFORMS="android,linux,web"

c_ok=$'\e[32m'; c_info=$'\e[36m'; c_warn=$'\e[33m'; c_err=$'\e[31m'; c_off=$'\e[0m'
step() { echo; echo "${c_info}==> $*${c_off}"; }
ok()   { echo "${c_ok}✔ $*${c_off}"; }
warn() { echo "${c_warn}! $*${c_off}"; }
die()  { echo "${c_err}✘ $*${c_off}"; exit 1; }
ask()  { local r; read -rp "$1 [O/n] " r; [[ -z "$r" || "$r" =~ ^[oOyY] ]]; }

command -v flutter >/dev/null || die "flutter introuvable dans le PATH"

git_sync() {
  local before; before=$(git hash-object "$0")
  step "Git : récupération des branches"
  git fetch --prune origin
  local current; current=$(git branch --show-current)
  echo "Branche actuelle : ${current}"
  echo "Branches distantes récentes :"
  git for-each-ref --sort=-committerdate --count=8 --format='  %(refname:short)  (%(committerdate:relative))' refs/remotes/origin
  local target
  read -rp "Branche à utiliser [${current}] : " target
  target=${target:-$current}
  target=${target#origin/}

  # Changements de droits seuls (disque NTFS/exFAT, chmod) : ignorés, sinon git croit à des modifications.
  git config core.fileMode false

  # Fichiers non suivis ignorés : android/ linux/ web/ sont générés localement.
  if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
    warn "Modifications locales non commitées :"
    git status --short --untracked-files=no
    if ask "Les mettre de côté (git stash) ?"; then
      git stash push -m "dev.sh $(date +%F_%T)"
    else
      die "Abandon : commite ou stash d'abord."
    fi
  fi

  if [[ "$target" != "$current" ]]; then
    git checkout "$target" 2>/dev/null || git checkout -b "$target" --track "origin/$target"
  fi
  git pull --ff-only origin "$target"
  ok "À jour sur $target ($(git log -1 --format='%h %s'))"
  SCRIPT_CHANGED=0
  [[ "$(git hash-object "$0")" != "$before" ]] && SCRIPT_CHANGED=1
  return 0
}

# Après un pull qui a modifié ce script, relance la nouvelle version pour la suite.
continue_after_git() {
  if (( SCRIPT_CHANGED )); then
    warn "dev.sh mis à jour par le pull : relance de la nouvelle version"
    exec "$0" "$1"
  fi
}

prepare() {
  step "Dossiers de plateformes"
  local missing=0
  for p in ${PLATFORMS//,/ }; do [[ -d "$p" ]] || missing=1; done
  if (( missing )); then
    flutter create --project-name garden_party --platforms="$PLATFORMS" .
    # flutter create re-résout les dépendances : on garde le lockfile versionné.
    git checkout -- pubspec.lock
  else
    ok "android/ linux/ web/ présents"
  fi
  # Test généré par défaut par flutter create, référence MyApp inexistant.
  rm -f test/widget_test.dart
  # Notifications programmées : desugaring, permissions et récepteurs dans android/ (généré).
  [[ -d android ]] && python3 scripts/patch_android.py

  step "Dépendances"
  # pubspec.lock modifié depuis la dernière préparation : on repart propre,
  # sinon les liens de plugins (linux/flutter/ephemeral) peuvent être périmés.
  local stamp=.dart_tool/dev_pubspec_lock
  local lock_hash; lock_hash=$(git hash-object pubspec.lock)
  if [[ -f "$stamp" && "$(cat "$stamp")" != "$lock_hash" ]]; then
    warn "pubspec.lock a changé : flutter clean"
    flutter clean
  fi
  flutter pub get
  echo "$lock_hash" > "$stamp"

  web_assets

  step "Code généré (drift)"
  local gen=lib/data/db/database.g.dart
  if [[ ! -f "$gen" ]] || [[ -n "$(find lib/data/db -name '*.dart' ! -name '*.g.dart' -newer "$gen")" ]]; then
    dart run build_runner build
  else
    ok "database.g.dart à jour"
  fi
}

# Version résolue d'un paquet dans pubspec.lock.
lock_version() {
  awk -v pkg="  $1:" '$0 == pkg {found=1} found && /version:/ {gsub(/"/, "", $2); print $2; exit}' pubspec.lock
}

# drift sur le web : sqlite3.wasm et drift_worker.js doivent correspondre aux versions de pubspec.lock.
web_assets() {
  step "Fichiers web de drift"
  local sqlite drift stamp=web/.drift_assets
  sqlite=$(lock_version sqlite3); drift=$(lock_version drift)
  [[ -n "$sqlite" && -n "$drift" ]] || die "versions sqlite3/drift introuvables dans pubspec.lock"
  if [[ -f web/sqlite3.wasm && -f web/drift_worker.js && "$(cat "$stamp" 2>/dev/null)" == "$sqlite/$drift" ]]; then
    ok "sqlite3.wasm $sqlite / drift_worker.js $drift présents"
    return 0
  fi
  curl -fsSL -o web/sqlite3.wasm "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-$sqlite/sqlite3.wasm"
  curl -fsSL -o web/drift_worker.js "https://github.com/simolus3/drift/releases/download/drift-$drift/drift_worker.js"
  echo "$sqlite/$drift" > "$stamp"
  ok "Téléchargés : sqlite3.wasm $sqlite, drift_worker.js $drift"
}

run_checks() {
  step "Analyse"
  flutter analyze || { ask "Analyse en échec, continuer ?" || exit 1; }
  step "Tests"
  flutter test || { ask "Tests en échec, continuer ?" || exit 1; }
}

# Identifiants OAuth Google Agenda (facultatifs) : google_oauth.env, non versionné.
google_defines() {
  if [[ -f google_oauth.env ]]; then
    DEFINES=(--dart-define-from-file=google_oauth.env)
  else
    DEFINES=()
    warn "google_oauth.env absent : synchro Google Agenda désactivée (voir google_oauth.env.example)"
  fi
}

launch() {
  local device=${1:-}
  google_defines
  if [[ -z "$device" ]]; then
    step "Lancement"
    echo "  1) linux   2) chrome   3) web-server (iPhone/iPad sur le réseau local)   4) autre appareil"
    local choice; read -rp "Choix [1] : " choice
    case "${choice:-1}" in
      1) device=linux ;;
      2) device=chrome ;;
      3) device=web-server ;;
      4) flutter devices; read -rp "ID de l'appareil : " device ;;
      *) die "Choix invalide" ;;
    esac
  fi
  if [[ "$device" == web-server ]]; then
    local ip; ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<NF;i++) if($i=="src") print $(i+1)}')
    echo "Ouvre http://${ip:-<ip-du-pc>}:8080 sur l'iPhone/iPad (même Wi-Fi)."
    echo "(Connexion Google impossible depuis une adresse IP en http : utilise l'export .ics ou la synchro depuis Linux/Android.)"
    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 "${DEFINES[@]}"
  elif [[ "$device" == chrome ]]; then
    # Port fixe : http://localhost:8080 doit être déclaré comme origine JavaScript du client OAuth web.
    flutter run -d chrome --web-port 8080 "${DEFINES[@]}"
  else
    flutter run -d "$device" "${DEFINES[@]}"
  fi
}

# Tout est dans main() : bash lit le script au fil de l'eau, et git pull peut le modifier en cours de route.
main() {
  case "${1:-}" in
    all) git_sync; continue_after_git _all_local; prepare; run_checks; launch linux; exit 0 ;;
    _all_local) prepare; run_checks; launch linux; exit 0 ;;
    _local) prepare; run_checks; launch; exit 0 ;;
  esac

  echo "${c_info}GardenParty — dev${c_off}"
  echo "  1) Tout : git → préparation → tests → lancement"
  echo "  2) Git seulement"
  echo "  3) Préparation (plateformes, pub get, fichiers web drift, génération drift)"
  echo "  4) Analyse + tests"
  echo "  5) Lancer l'app"
  echo "  6) Tout sauf git (code local)"
  read -rp "Choix [1] : " menu
  case "${menu:-1}" in
    1) git_sync; continue_after_git _local; prepare; run_checks; launch ;;
    2) git_sync ;;
    3) prepare ;;
    4) run_checks ;;
    5) launch ;;
    6) prepare; run_checks; launch ;;
    *) die "Choix invalide" ;;
  esac
}

main "$@"; exit
