#!/bin/bash -e

if [ -n "${PAWSEY_CLUSTER}" ] && [ -z ${SYSTEM+x} ]; then
    SYSTEM="$PAWSEY_CLUSTER"
fi

if [ -z ${SYSTEM+x} ]; then
    echo "The 'SYSTEM' variable is not set. Please specify the system you want to
    build Spack for."
    exit 1
fi

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
. "${ROOT_DIR}/systems/${SYSTEM}/settings.sh"

# for first run, use cray-python, because there is no Spack python yet
module load cray-python
# initialise spack 
. ${INSTALL_PREFIX}/spack/share/spack/setup-env.sh 

# make sure Clingo is bootstrapped
echo "Running 'spack -d spec nano' to bootstrap Clingo.."
spack -d spec nano

# first thing we need is Python
# spec gcc
echo "Concretization of Python.."
spack -d spec python@${python_version} +optimizations %gcc@${gcc_version} # target=zen3 

echo "Installing Python with default compilers.."

for arch in "zen2"; do #archs; do
    # install gcc
    sg $INSTALL_GROUP -c "spack install --no-checksum python@${python_version} +optimizations %gcc@${gcc_version} target=$arch"
    # install cce
    sg $INSTALL_GROUP -c "spack install --no-checksum python@${python_version} +optimizations %cce@${cce_version} target=$arch"
    # install aocc
    sg $INSTALL_GROUP -c "spack install --no-checksum python@${python_version} +optimizations %aocc@${aocc_version} target=$arch"
done
