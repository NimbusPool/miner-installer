#/bin/bash

VERSION=0.3.3
WORKING_DIR="nimbuspool-miner"

# List of supported CPU; if not in this list, then
# will revert to use compatible 'core2'.
supported_cputypes=(
  'broadwell'
  'core2'
  'haswell'
  'ivybridge'
  'nehalem'
  'sandybridge'
  'silvermont'
  'skylake-avx512'
  'skylake'
  'westmere'
  'znver1'
)

print_logo() {
  echo ""
  echo ""
  echo "                               +++                               "
  echo "                            +++++++++                            "
  echo "                        +++++       +++++                        "
  echo "                     +++++             +++++                     "
  echo "                 +++++                     +++++                 "
  echo "              +++++      +++                  +++++              "
  echo "          +++++       ++++ ++++                  ++++++          "
  echo "       +++++          +++   ++++++++++++++++++++++++++++++       "
  echo "   +++++              +++   +++                          +++++   "
  echo "+++++                   +++++                               +++++"
  echo "+++                                +++++++                    +++"
  echo "+++++++++++++++++++++++++++++++++++++   +++       NIMIQ       +++"
  echo "++++                             ++++   +++     POOL MINER    +++"
  echo "+++                                +++++++                    +++"
  echo "+++          ++++++                           www.nimbus.fun  +++"
  echo "+++        ++++  +++                                          +++"
  echo "+++        +++    +++++++++++++++++++++++++++++++++++++++++++++++"
  echo "+++        +++++++++                                          +++"
  echo "+++           +++         NIMBUS             +++              +++"
  echo "+++                                        ++++++++           +++"
  echo "+++++++++++++++++++++++++++++++++++++++++++++    +++          +++"
  echo "+++                                       ++++  +++           +++"
  echo "+++                                         ++++++            +++"
  echo "+++                     ++++++++                              +++"
  echo "+++                    ++++   +++++++++++++++++++++++++++++++++++"
  echo "+++                    ++++   +++++++++++++++++++++++++++++++++++"
  echo "+++                     ++++++++                              +++"
  echo "+++++                                 +++++                 +++++"
  echo "   ++++++                           ++++  +++           ++++++   "
  echo "       ++++++++++++++++++++++++++++++++   +++        +++++       "
  echo "          ++++++                    +++++++++    ++++++          "
  echo "              +++++                   +++++   +++++              "
  echo "                 ++++++                   ++++++                 "
  echo "                     +++++             +++++                     "
  echo "                        ++++++     ++++++                        "
  echo "                            +++++++++                            "
  echo "                               +++                               "
  echo ""
  echo ""
}

# Check if we have root
check_root() {
  if [[ $EUID -ne 0 ]]; then
    return 1
  fi
  return 0
}

# Check if we have yum package manager
#
# Adding a package:
# $ yum install curl -y
has_yum() {
  if [[ -n "$(command -v yum)" ]]; then
    return 0
  fi
  return 1
}

# Check if we have apt-get package manager
#
# Adding a package:
# $ apt-get install curl -y
has_apt() {
  if [[ -n "$(command -v apt-get)" ]]; then
    return 0
  fi
  return 1
}

# Check if we have apk package manager
#
# Adding a package:
# $ apk add curl
has_apk() {
  if [[ -n "$(command -v apk)" ]]; then
    return 0
  fi
  return 1
}

# Check if we have cURL
has_curl() {
  if [[ -n "$(command -v curl)" ]]; then
    return 0
  fi
  return 1
}

# Check if we have wget
has_wget() {
  if [[ -n "$(command -v wget)" ]]; then
    return 0
  fi
  return 1
}

# Check if we have lscpu command
#
# -- Output:
# Model:               158
# Model name:          Intel(R) Core(TM) i7-7820HQ CPU @ 2.90GHz
# Stepping:            9
# CPU MHz:             2900.000
has_lscpu() {
  if [[ -n "$(command -v lscpu)" ]]; then
    return 0
  fi
  return 1
}

# Check if we have /proc/cpuinfo
has_proc_cpuinfo() {
  if [[ -e /proc/cpuinfo ]]; then
    return 0
  fi
  return 1
}

# Returns true if we are on macOS
is_darwin() {
  unamestr=`uname`
  if [ "$unamestr" == "Darwin" ]; then
    return 0
  fi
  return 1
}

check_ark_intel() {
  productUrl=$(curl --silent "https://ark.intel.com/search/AutoComplete?term=${cpuModel}" | sed -n 's/.*\"quickUrl\":\"\(.*\)\".*/\1/p')
  tmpCpuType=$(curl --silent "https://ark.intel.com${productUrl}" | sed -n 's/.*Products formerly \(.*\)<.*/\1/p')
  CPU_TYPE=$(echo $tmpCpuType | sed 's/ //g' | awk '{print tolower($0)}')

  # Kaby Lake is not supported yet, downgrade to Skylake
  if [ "$CPU_TYPE" == "kabylake" ]; then
    CPU_TYPE="foo"
  fi
}

# Check CPU type
check_cpu_type() {
  CPU_TYPE="core2"

  if has_lscpu; then
    cpuModel=$(lscpu | sed -nr '/Model name/ s/.*:\s*(.*) @ .*/\1/p' | cut -d ' ' -f 3)
    check_ark_intel
  elif has_proc_cpuinfo; then
    cpuModel=$(cat /proc/cpuinfo | sed -nr '/model name/ s/.*:\s*(.*) @ .*/\1/p' | cut -d ' ' -f 3 | head -1)
    check_ark_intel
  elif is_darwin; then
    cpuModel=$(sysctl -n machdep.cpu.brand_string | cut -d ' ' -f 3)
    check_ark_intel
  else
    echo "Unknown CPU type; using default 'core2' for compatibility"
  fi
}

# Check if CPU_TYPE is compatible
check_cpu_compatible() {
  if [[ ! "${supported_cputypes[@]}" =~ "${CPU_TYPE}" ]]; then
    echo "CPU type '${CPU_TYPE}' is not compatible with the miner; reverting to compatible 'core2'."
    return 1
  fi
  return 0
}

install_curl() {
  if ! check_root; then
    echo "Cannot install cURL without root privileges!"
    exit 1
  fi

  if has_yum; then
    yum upgrade -y
    yum install curl
  elif has_apt; then
    apt-get update -y
    apt-get install curl
  elif has_apk; then
    apk add curl
  fi
}

# Download <url> <output_path>
download() {
  URL=$1
  OUTPUT_PATH=$2

  if [[ has_curl ]]; then
    curl -k -L "${URL}" -o $OUTPUT_PATH
  elif [[ has_wget ]]; then
    wget "${URL}" -o $OUTPUT_PATH
  fi

  unset URL
  unset OUTPUT_PATH
}

# Script starts here!
# Check for a download manager
if has_curl == 0 && has_wget == 0; then
  install_curl
fi

print_logo
check_cpu_type
check_cpu_compatible

MINER_ZIP_FN="nimbuspool-miner-linux-${VERSION}-${CPU_TYPE}.zip"
MINER_URL="https://github.com/NimbusPool/miner/releases/download/v${VERSION}/${MINER_ZIP_FN}"

if [[ -z "$WALLET_ADDRESS" ]]; then
  echo "WALLET_ADDRESS was not defined!"
  exit 1
fi
PRETTY_WORKER_NAME=$WORKER_ID
if [[ -z ${WORKER_ID+x} ]]; then
  echo "WORKER_ID was not defined, using random numeric string ..."
  PRETTY_WORKER_NAME="<random string>"
  unset WORKER_ID
fi

echo "Installing Nimbus Pool Miner with the following settings:"
echo "Wallet: ${WALLET_ADDRESS}"
echo "Worker Name: ${PRETTY_WORKER_NAME}"
echo "CPU Type: ${CPU_TYPE}"

# Make working directory
mkdir -p $WORKING_DIR
cd $WORKING_DIR
download "${MINER_URL}" $MINER_ZIP_FN
unzip $MINER_ZIP_FN

# Install persistence
if [[ -n "$INSTALL_SERVICE" ]]; then
  # TODO
  # https://github.com/moby/moby/tree/master/contrib/init
  # Need to check what service is available:
  # systemd
  # sysvinit-debian
  # sysvinit-redhat
  # upstart

  # After installing the service, start it
fi
# screen -d -m ./nimbuspool-client-linux-x64 --wallet-address=${WALLET_ADDRESS} --extra-data=${WORKER_ID}
