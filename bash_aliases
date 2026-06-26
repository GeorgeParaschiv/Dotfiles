# WSL/local-only aliases and functions
[[ -r "${HOME}/.bash_aliases.shared" ]] && . "${HOME}/.bash_aliases.shared"

_install_lab_key() {
	local server="$1"
	local key="${2:-$HOME/.ssh/id_rsa.pub}"

	if [[ ! -r "$key" ]]; then
		echo "Error: public key not found: ${key}" >&2
		return 1
	fi

	ssh-copy-id -i "$key" "lab@${server}"
}

_install_nxp_key() {
	local host="$1"
	local key="${2:-$HOME/.ssh/id_rsa.pub}"

	if [[ ! -r "$key" ]]; then
		echo "Error: public key not found: ${key}" >&2
		return 1
	fi

	if cat "$key" | ssh "root@${host}" \
		'mkdir -p /etc/dropbear
		 touch /etc/dropbear/authorized_keys
		 grep -qF "$(cat)" /etc/dropbear/authorized_keys 2>/dev/null'; then
		echo "SSH key already installed on root@${host}"
		return 0
	fi

	cat "$key" | ssh "root@${host}" \
		'mkdir -p /etc/dropbear && cat >> /etc/dropbear/authorized_keys && chmod 700 /etc/dropbear && chmod 600 /etc/dropbear/authorized_keys'
}

_setup_lab() {
	local server="$1"
	local setup_dir="${2:-$GEORGE_REMOTE_DIR}"
	local aliases_path="${setup_dir}/.bash_aliases"
	local init_path="${setup_dir}/.bash_george_init"
	local login_path="${setup_dir}/.bash_george_login"

	ssh "lab@${server}" "mkdir -p '${setup_dir}'" || return 1
	scp "$GEORGE_SHARED_ALIASES" "lab@${server}:${aliases_path}" || return 1

	ssh "lab@${server}" "cat > '${init_path}'" <<'EOF'
[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -n "${GEORGE_ALIASES}" ]] && [[ -r "${GEORGE_ALIASES}" ]] && . "${GEORGE_ALIASES}"
EOF

	ssh "lab@${server}" "cat > '${login_path}'" <<EOF
#!/bin/bash
export GEORGE_ALIASES="${aliases_path}"
cd "${setup_dir}" 2>/dev/null || true
if [[ -r "${init_path}" ]]; then
  exec bash --rcfile "${init_path}" -i
else
  exec bash -i
fi
EOF

	ssh "lab@${server}" "chmod +x '${login_path}'" || return 1

	ssh "lab@${server}" "sed -i '/# Load George Custom Aliases/,/^fi\$/d' ~/.bashrc 2>/dev/null"
}

setup() {
	local server="$1"
	local host="${server%%.*}"

	if [[ -z "$server" ]]; then
		echo "Usage: setup <hostname>" >&2
		return 1
	fi

	case "$host" in
	sw-nxp-n*)
		echo "Installing SSH key on NXP: root@${host}"
		_install_nxp_key "$host" || return 1
		;;
	pv-host*|automation-*|repeater-*)
		echo "Installing SSH key on lab: lab@${server}"
		_install_lab_key "$server" || return 1

		if [[ ! -r "$GEORGE_SHARED_ALIASES" ]]; then
			echo "Error: Shared aliases file not found at ${GEORGE_SHARED_ALIASES}" >&2
			return 1
		fi

		echo "Deploying aliases to lab@${server}"
		_setup_lab "$server" || return 1
		;;
	*)
		echo "Error: Unrecognized host '${host}'" >&2
		echo "  Lab: pv-host*, automation-*, repeater-*" >&2
		echo "  NXP: sw-nxp-n*" >&2
		return 1
		;;
	esac
}

setupbash() {
	setup "pv-host49${CORP}" || return 1
	setup "automation-140${CORP}" || return 1
	setup "repeater-3${CORP}" || return 1
}

alias src='unalias -a && source ~/.bashrc'
alias cpy='xclip -sel c < '

p4() {
  "/mnt/c/Program Files/Perforce/p4.exe" "$@"
}

cldiff() {
  local CL="$1"
  local OUT_DIR="/mnt/c/Users/gparaschiv.PERASO-CORP/Documents/Changelist Diffs"
  local CHANGE_SPEC STATUS DESC SLUG OUT P4CLIENT OPENED

  if [[ -z "$CL" ]]; then
    echo "Usage: cldiff <changelist>"
    return 1
  fi

  if ! CHANGE_SPEC=$(p4 change -o "$CL" 2>/dev/null | tr -d '\r'); then
    echo "No changelist $CL exists."
    return 1
  fi
  if [[ -z "$CHANGE_SPEC" ]]; then
    echo "No changelist $CL exists."
    return 1
  fi

  STATUS=$(printf '%s\n' "$CHANGE_SPEC" | sed -n 's/^Status:[[:space:]]*//p')
  DESC=$(printf '%s\n' "$CHANGE_SPEC" | sed -n '/^Description:/{n;s/^\t//;s/[[:space:]]*$//;p;q}')
  SLUG=$(printf '%s' "$DESC" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed -e 's/^-//' -e 's/-$//' -e 's/-\{1,\}/-/g' | cut -c1-40)
  if [[ -n "$SLUG" ]]; then
    OUT="${OUT_DIR}/${CL}_${STATUS}_${SLUG}.diff"
  else
    OUT="${OUT_DIR}/${CL}_${STATUS}.diff"
  fi

  echo "Changelist $CL: $STATUS"

  case "$STATUS" in
    submitted)
      p4 describe -duw "$CL" > "$OUT"
      ;;
    pending)
      P4CLIENT=$(p4 info 2>/dev/null | tr -d '\r' | sed -n 's/^Client name:[[:space:]]*//p')
      OPENED=$(p4 opened -c "$CL" -C "$P4CLIENT" 2>/dev/null)
      if [[ -n "$OPENED" ]]; then
        echo "Using workspace diff (open files in $P4CLIENT; no shelve)."
        printf '%s\n' "$OPENED" | sed -e 's/#.*//' | p4 -x - diff -duw > "$OUT"
      elif p4 describe -sS "$CL" 2>/dev/null | grep -qE '^\.\.\. '; then
        echo "Using shelf diff (no open files in your workspace)."
        p4 describe -S -duw "$CL" > "$OUT"
      else
        echo "Pending changelist $CL has no open files in your workspace and no shelf."
        return 1
      fi
      ;;
    *)
      echo "Unexpected changelist status: $STATUS"
      return 1
      ;;
  esac

  echo "Saved to ${OUT}"
}

alias downloads='cd /mnt/c/Users/gparaschiv.PERASO-CORP/Downloads'
alias pf='cd /mnt/c/Perforce'
alias cddr='cd /mnt/c/Perforce/gpara_device_drivers/components/drivers/network/Makefiles'
alias cdwpa='cd /mnt/c/Perforce/gpara_wpa_supplicant/components'

alias esp="ssh root@esp2305${CORP}"


NXP_N="${NXP_N:-5}"

_nxp_host() {
	local n="${1:-$NXP_N}"
	echo "root@sw-nxp-n${n}"
}

nxpdefault() {
	NXP_N="$1"
	export NXP_N
	echo "NXP default: sw-nxp-n${NXP_N}"
}

nxp() {
	local n="${1:-$NXP_N}"
	ssh -t "$(_nxp_host "$n")"
}

nxplist() {
	local n="${1:-$NXP_N}"
	ssh "$(_nxp_host "$n")" 'first=1
_lookup_product() {
  case "$1" in
    2932:01ca) echo "PER095 USB Connection Exerciser" ;;
  esac
}

for t in /sys/class/tty/ttyACM*; do
  [ -d "$t" ] || continue
  dev="/dev/${t##*/}"
  iface=$(readlink -f "$t/device")
  usb=$(dirname "$iface")
  port=$(basename "$usb")
  ifnum=$(printf "%02d" "$(cat "$iface/bInterfaceNumber" 2>/dev/null | tr -d "\n\r")" 2>/dev/null || echo "00")

  m=$(cat "$usb/manufacturer" 2>/dev/null | tr -d "\n\r")
  pr=$(cat "$usb/product" 2>/dev/null | tr -d "\n\r")
  v=$(cat "$usb/idVendor" 2>/dev/null | tr -d "\n\r")
  p=$(cat "$usb/idProduct" 2>/dev/null | tr -d "\n\r")

  [ -z "$pr" ] && pr=$(_lookup_product "${v}:${p}")

  if [ -n "$m" ] && [ -n "$pr" ]; then
    id="usb-$(echo "${m}_${pr}" | tr " " "_")-${port}-if${ifnum}"
    desc="$m $pr"
  elif [ -n "$v" ] && [ -n "$p" ]; then
    id="usb-${v}_${p}-${port}-if${ifnum}"
    desc="${v}:${p}"
  else
    id="usb-${port}-if${ifnum}"
    desc="—"
  fi

  [ "$first" -eq 0 ] && echo
  first=0
  echo "$dev"
  echo "├── ID: $id"
  echo "└── DESC:  $desc"
done'
}

nxppico() {
	local n dev
	if [[ $# -ge 2 ]]; then
		n="$1"
		dev="$2"
	else
		n="$NXP_N"
		dev="${1:-0}"
	fi
	ssh -t "$(_nxp_host "$n")" \
		picocom -b 115200 --echo --imap lfcrlf --omap crcrlf "/dev/ttyACM${dev}"
}

nxppicocr() {
	local n dev
	if [[ $# -ge 2 ]]; then
		n="$1"
		dev="$2"
	else
		n="$NXP_N"
		dev="${1:-0}"
	fi
	ssh -t "$(_nxp_host "$n")" \
		picocom -b 115200 --echo --imap lfcr "/dev/ttyACM${dev}"
}

alias cpyvue="scp ~/george_p/openwrt_2305/dune/bin/packages/aarch64_cortex-a53/peraso_ui/prs-vue-ui_1.0.0-r1_all.ipk root@esp2305${CORP}:"

makevue() {
	cd ~/george_p/openwrt_2305/dune
	make package/feeds/peraso_ui/prs-vue-ui/clean
	make V=s package/feeds/peraso_ui/prs-vue-ui/compile
	cd -
}

hostapd() {
	cd /mnt/c/Perforce/gpara_wpa_supplicant/components/wpa_supplicant/Makefiles
	python3 linux_build.py --cleandir
	cd /mnt/c/Perforce/gpara_wpa_supplicant/components/wpa_supplicant/hostapd
	make clean
	make
}

wpa() {
	cd /mnt/c/Perforce/gpara_wpa_supplicant/components/wpa_supplicant/Makefiles
	python3 linux_build.py --cleandir
	cd /mnt/c/Perforce/gpara_wpa_supplicant/components/wpa_supplicant/wpa_supplicant
	make clean
	make
}

usbwigig() {
  local folder="${1:-gpara_wpa_supplicant}"
  local clean_flag=""
  
  if [ "$1" == "clean" ]; then
    folder="gpara_wpa_supplicant"
    clean_flag="clean"
  elif [ "$2" == "clean" ]; then
    clean_flag="clean"
  fi
  
  mkdir -p /mnt/c/Perforce/${folder}/components/prs_usb_wigig_lib/build
  cd /mnt/c/Perforce/${folder}/components/prs_usb_wigig_lib/build
  cmake ..
  if [ "$clean_flag" == "clean" ]; then
    make clean
  fi
  make
}

wpausb() {
  local folder="${1:-gpara_wpa_supplicant}"
  ~/scripts/build_wpausb.sh "${folder}"
}

driver() {

	cd /mnt/c/Perforce/gpara_device_drivers/components/drivers/network/Makefiles

	local arg="$1"
	local platform=""

	local valid_platforms=(
		ipq6010_zwl ls1043ardb ls1046ardb ls1046_21 ls1046_23 ls2088_21 ls1046ardb_glibc imx8mp_sr
		imx8mp_sr_kirkstone android_r25c_x86_64 android_r25c_arm64-v8a espressobin espressobin-1806
		espressobin-1806.0 espressobin-2102 espressobin-2305 clearfog clearfog-1806 clearfog-2102
		bits53x2_125 zindune_122 wrt3200acm metrolinq ubnt_ipq806x ubuntu-14_04-4_4_0-31
		ubuntu-14_04-4_4_0-62 ubuntu-14_04-4_4_0-31-prscfg80211 ubuntu-14_04-4_4_0-62-prscfg80211
		ubuntu-18_10-4_19_125-0419125 ubuntu-19_04-5_0_0-13 ubuntu-20_04-5_4_0-29
		ubuntu-22_04-5_19_0-40 ubuntu-22_04-5_19_0-50 ubuntu-22_04-5_15_0-130
	)

	display_usage() {
		echo 'Usage: install_driver [u|l|e|<platform_name>]'
		echo '  u | Ubuntu       = Ubuntu'
		echo '  l | LS1046       = LS1046'
		echo '  e | EspressoBin  = EspressoBin'
		echo "  <valid platform names> = $(IFS=, ; echo "${valid_platforms[*]}")"
	}

	if [ -z "$arg" ]; then
		echo "Error: No platform name provided."
		display_usage
		return 1
	fi

    	is_valid_platform() {
        	local input="$1"
        	shift
        	local list=("$@")

        	for valid in "${list[@]}"; do
        	    if [[ "$input" == "$valid" ]]; then
        	        return 0
        	    fi
        	done
        	return 1
    	}

	# Check if the name is a valid platform or a shortcut (u, l, e)
	if is_valid_platform "$arg" "${valid_platforms[@]}"; then
		platform="$arg"
	elif [[ "$arg" == "u" ]]; then
		platform="ubuntu-20_04-5_4_0-29"
	elif [[ "$arg" == "l" ]]; then
		platform="ls1046ardb"
	elif [[ "$arg" == "e" ]]; then
		platform="espressobin-1806.0"
	else
		echo 'Error: Invalid platform name or shortcut.'
		display_usage
		return 1
	fi

	echo "Building for platform: $platform"
	python2.7 linux_build.py --platform "$platform" --output "${platform}_build" --makearg=PRS_SVN_REVISION=000000 --cleandir --prs_debug -v
}

_fw_report_sizes() {
  local fw_dir=$1 target=$2 radio=$3
  local sw_root awk umac_map lmac_map

  sw_root="$(dirname "$(dirname "$fw_dir")")"
  awk="${sw_root}/utility/bin/post-process-map-firmware-size.awk"
  umac_map="${fw_dir}/build/uppermac/umac_${target}.map"
  lmac_map="${fw_dir}/build/lowermac/lmac_${target}.map"

  if [[ ! -f "$awk" ]]; then
    echo "Warning: awk script not found: $awk" >&2
    return 1
  fi
  if [[ ! -f "$umac_map" || ! -f "$lmac_map" ]]; then
    echo "Warning: map files not found for ${target} (build it first)" >&2
    return 1
  fi

  echo
  echo "Radio ${radio} sizes as computed by post-process-map-firmware-size.awk:"
  echo
  gawk -f "$awk" -v BUILD="$target" -v MAC="umac" "$umac_map"
  gawk -f "$awk" -v BUILD="$target" -v MAC="lmac" "$lmac_map"
}

_fw_in_list() {
  local needle=$1; shift
  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

_fw_normalize_bbid() {
  local arg=$1
  if [[ "$arg" =~ ^prs[0-9]+$ ]]; then
    printf '%s' "$arg"
  elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    printf 'prs%s' "$arg"
  else
    return 1
  fi
}

_fw_load_catalog() {
  local fw_dir=$1
  local -n _targets=$2 _series_list=$3 _radio_list=$4 _bbid_list=$5
  local target series radio bbid

  _targets=()
  _series_list=()
  _radio_list=()
  _bbid_list=()

  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    _targets+=("$target")
    if [[ "$target" =~ ^(.+)_(rfc|spw|spwA|qtz)_(prs[0-9]+)$ ]]; then
      series="${BASH_REMATCH[1]}"
      radio="${BASH_REMATCH[2]}"
      bbid="${BASH_REMATCH[3]}"
      _fw_in_list "$series" "${_series_list[@]}" || _series_list+=("$series")
      _fw_in_list "$radio" "${_radio_list[@]}" || _radio_list+=("$radio")
      _fw_in_list "$bbid" "${_bbid_list[@]}" || _bbid_list+=("$bbid")
    fi
  done < <(command grep -E '^[a-zA-Z0-9_]+_prs[0-9]+:' "$fw_dir/makefile" | sed 's/:.*//')

  if ((${#_targets[@]} == 0)); then
    echo "No firmware targets found in ${fw_dir}/makefile" >&2
    return 1
  fi
}

_fw_resolve_target() {
  # Sets stream/series/radio/bbid/fw_dir/target via namerefs; returns 1 on error.
  local -n _stream=$1 _series=$2 _radio=$3 _bbid=$4 _fw_dir=$5 _target=$6
  local p4_base="/mnt/c/Perforce"
  local arg normalized
  local -a valid_targets valid_series valid_radios valid_bbids
  shift 6

  _stream="trunk"
  for arg in "$@"; do
    case "$arg" in
      trunk|81|631)
        _stream="$arg"
        ;;
    esac
  done

  case "$_stream" in
    trunk) _fw_dir="${p4_base}/gpara_trunk/components/firmware" ;;
    81)    _fw_dir="${p4_base}/gpara_fw_81/components/firmware" ;;
    631)   _fw_dir="${p4_base}/gpara_fw_631/components/firmware" ;;
  esac

  if [[ ! -d "$_fw_dir" ]]; then
    echo "Firmware tree not found: $_fw_dir" >&2
    return 1
  fi

  _fw_load_catalog "$_fw_dir" valid_targets valid_series valid_radios valid_bbids || return 1

  _series="pro"
  _radio="rfc"
  _bbid="prs4601"

  for arg in "$@"; do
    case "$arg" in
      trunk|81|631|clean)
        continue
        ;;
    esac

    if _fw_in_list "$arg" "${valid_series[@]}"; then
      _series="$arg"
      continue
    fi

    if _fw_in_list "$arg" "${valid_radios[@]}"; then
      _radio="$arg"
      continue
    fi

    if normalized=$(_fw_normalize_bbid "$arg" 2>/dev/null) && _fw_in_list "$normalized" "${valid_bbids[@]}"; then
      _bbid="$normalized"
      continue
    fi

    echo "Unknown option: $arg" >&2
    echo "Valid series (${_stream}): ${valid_series[*]}" >&2
    echo "Valid radios (${_stream}): ${valid_radios[*]}" >&2
    echo "Valid bbids (${_stream}): ${valid_bbids[*]}" >&2
    return 1
  done

  _target="${_series}_${_radio}_${_bbid}"

  if ! _fw_in_list "$_target" "${valid_targets[@]}"; then
    echo "Unknown target for ${_stream} stream: $_target" >&2
    echo "Valid targets (${_stream}):" >&2
    printf '  %s\n' "${valid_targets[@]}" >&2
    return 1
  fi
}

fwsizes() {
  local STREAM SERIES RADIO BBID FW_DIR TARGET

  _fw_resolve_target STREAM SERIES RADIO BBID FW_DIR TARGET "$@" || return 1
  _fw_report_sizes "$FW_DIR" "$TARGET" "$RADIO"
}

fw() {
  local STREAM SERIES RADIO BBID FW_DIR TARGET
  local JOBS="${JOBS:-4}"
  local DO_CLEAN=0 IMAGE OUT_DIR

  for arg in "$@"; do
    [[ "$arg" == clean ]] && DO_CLEAN=1
  done

  _fw_resolve_target STREAM SERIES RADIO BBID FW_DIR TARGET "$@" || return 1

  cd "$FW_DIR" || return 1

  if (( DO_CLEAN )); then
    make clean
    OUT_DIR="${HOME}/builds/fw/${STREAM}"
    if [[ -d "$OUT_DIR" ]]; then
      rm -rf "$OUT_DIR"
      echo "Removed: $OUT_DIR"
    fi
    mkdir -p "$OUT_DIR"
    echo "Cleaned: $FW_DIR"
    cd "$OUT_DIR" || return 1
    return
  fi

  make -j"$JOBS" "$TARGET" || return 1

  _fw_report_sizes "$FW_DIR" "$TARGET" "$RADIO" || true

  IMAGE="${FW_DIR}/targets/debug/${TARGET}.bin"
  OUT_DIR="${HOME}/builds/fw/${STREAM}"
  mkdir -p "$OUT_DIR"
  cp -f "$IMAGE" "${OUT_DIR}/" || return 1
  echo "Built: $IMAGE"
  echo "Copied: ${OUT_DIR}/${TARGET}.bin"
  cd "$OUT_DIR" || return 1
}
