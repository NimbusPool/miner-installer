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
has_root() {
  echo "TODO"
}

# Check if we have yum package manager
#
# Adding a package:
# $ yum install curl -y
has_yum() {
  echo "TODO"
}

# Check if we have apt-get package manager
#
# Adding a package:
# $ apt-get install curl -y
has_apt() {
  echo "TODO"
}

# Check if we have apk package manager
#
# Adding a package:
# $ apk add curl
has_apk() {
  echo "TODO"
}

# Check if we have cURL
has_curl() {
  echo "TODO"
}

# Check if we have wget
has_wget() {
  echo "TODO"
}

# Check if we have lscpu command
#
# -- Output:
# Model:               158
# Model name:          Intel(R) Core(TM) i7-7820HQ CPU @ 2.90GHz
# Stepping:            9
# CPU MHz:             2900.000
has_lscpu() {
  echo "TODO"
}

# Check if we have /proc/cpuinfo
has_proc_cpuinfo() {
  echo "TODO"
}

# Check CPU type
check_cpu_type() {
  echo "TODO"
  # If we have lscpu, use the following command:

  # lscpu | sed -nr '/Model name/ s/.*:\s*(.*) @ .*/\1/p' | cut -d ' ' -f 3
  # Example: i7-7820HQ

  # If we have /proc/cpuinfo, use the following command:
  # cat /proc/cpuinfo | sed -nr '/model name/ s/.*:\s*(.*) @ .*/\1/p' | cut -d ' ' -f 3 | head -1
  # Example: i7-7820HQ

  # If we get something, look it up against our lookup tables
  # Otherwise, use the `compatible` version (ie. core2)
  CPU_TYPE="core2"
}

# Script starts here!
if [[ -z "$WALLET_ADDRESS" ]]; then
  echo "WALLET_ADDRESS was not defined!"
  exit 1
fi
if [[ -z ${WORKER_ID+x} ]]; then
  echo "WORKER_ID was not defined, using random numeric string ..."
  exit 1
fi

print_logo

echo "Installing Nimbus Pool Miner with the following settings:"
echo "Wallet: ${WALLET_ADDRESS}"
echo "Worker Name: ${WORKER_ID}"
echo "CPU Type: ${CPU_TYPE}"
