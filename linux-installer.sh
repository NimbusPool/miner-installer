#/bin/bash

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
      echo "This script must be run with sudo in order to install curl"
      exit 1
   fi
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

check_ark_intel() {
   productUrl=$(curl "https://ark.intel.com/search/AutoComplete?term=${cpuModel}" | sed -n 's/.*\"quickUrl\":\"\(.*\)\".*/\1/p')
   tmpCpuType=$(curl --silent "https://ark.intel.com${productUrl}" | sed -n 's/.*Products formerly \(.*\)<.*/\1/p')
   CPU_TYPE=$(echo $tmpCpuType | sed 's/ //g' | awk '{print tolower($0)}')
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
   fi
}

install_curl() {
   if has_yum; then
      sudo yum upgrade -y
      sudo yum install curl
   elif has_apt; then
      sudo apt-get update -y
      sudo apt-get install curl
   elif has_apk; then
      sudo apk add curl
   fi
}

# Script starts here!
if [[ -z "$WALLET_ADDRESS" ]]; then
  echo "WALLET_ADDRESS was not defined!"
  exit 1
fi
if [[ -z ${WORKER_ID} ]]; then
  echo "WORKER_ID was not defined, using random numeric string ..."
  exit 1
fi

print_logo

check_cpu_type

echo "Installing Nimbus Pool Miner with the following settings:"
echo "Wallet: ${WALLET_ADDRESS}"
echo "Worker Name: ${WORKER_ID}"
echo "CPU Type: ${CPU_TYPE}"

VERSION=0.3.3
MINER_ZIP_FN="nimbuspool-miner-linux-${VERSION}-${CPU_TYPE}.zip"

if ! has_curl && has_wget; then
   echo "cURL is not installed. Trying wget..."
   wget "https://github.com/NimbusPool/miner/releases/download/v${VERSION}/${MINER_ZIP_FN}"
else
   if ! has_curl; then
      check_root
      echo "Trying to install cURL..."
      install_curl
   fi

   curl -k -L "https://github.com/NimbusPool/miner/releases/download/v${VERSION}/${MINER_ZIP_FN}" -o $MINER_ZIP_FN
fi

unzip $MINER_ZIP_FN
screen -d -m ./nimbuspool-client-linux-x64 --wallet-address=${WALLET_ADDRESS} --extra-data=${WORKER_ID}
