#!/bin/bash

set -ueo pipefail


# check if lscpu outputs AMD

cpu_vendor=$(lscpu | grep "Vendor ID:" | awk '{print $3}')

# Check if the CPU vendor is AMD
if [ "$cpu_vendor" == "AuthenticAMD" ]; then
    echo "CPU vendor is AMD"
else
    exit 1
fi


cat <<EOF > fakeintel.c
int mkl_serv_intel_cpu_true() {
  return 1;
}

EOF

gcc -shared -fPIC -o libfakeintel.so fakeintel.c

conda install -c defaults --override-channels numpy -y

echo "No LD_PRELOAD"
python mkl_amd_hack.py

echo "Has LD_PRELOAD"
LD_PRELOAD=/path/to/libfakeintel.so python mkl_amd_hack.py