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
  CL="$1"
  OUT="/mnt/c/Users/gparaschiv.PERASO-CORP/Downloads/cl_${CL}.diff"

  p4 shelve -f -c "$CL"
  p4 describe -S -duw "$CL" > "$OUT"

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

fw() {
  local FW_DIR="/mnt/c/Perforce/gpara_trunk/components/firmware"
  local JOBS="${JOBS:-4}"

  local SERIES="pro"
  local RADIO="rfc"
  local BBID="prs4601"
  local DO_CLEAN=0

  for arg in "$@"; do
    case "$arg" in
      clean)
        DO_CLEAN=1
        ;;
      pro|dune|infra|wlan|avatar|navi|insight|velo)
        SERIES="$arg"
        ;;
      rfc|spw|spwA|qtz)
        RADIO="$arg"
        ;;
      4601|prs4601)
        BBID="prs4601"
        ;;
      4001|prs4001)
        BBID="prs4001"
        ;;
      *)
        echo "Unknown option: $arg"
        return 1
        ;;
    esac
  done

  cd "$FW_DIR" || return 1

  if (( DO_CLEAN )); then
    make clean
    echo "Cleaned: $FW_DIR"
    return
  fi

  local TARGET="${SERIES}_${RADIO}_${BBID}"

  make -j"$JOBS" "$TARGET"
  echo "Built: $FW_DIR/targets/debug/image_${TARGET}.bin"
}

compile() {
	local function="$1"
	local platform="$2"

	if ! declare -f "$function" > /dev/null; then
		echo "Error: Function '$function' not found." >&2
		return 1
	fi

	if [[ "$function" == "driver" ]]; then
		"$function" "$platform"
	else
		"$function"
	fi
}
