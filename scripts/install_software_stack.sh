#!/bin/bash -e

# Check input variables
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

echo "Setting up spack.."
"${ROOT_DIR}/scripts/setup_spack.sh"

echo "Running first python install"
"${ROOT_DIR}/scripts/run_first_python_install.sh"

module --ignore-cache unload pawsey_prgenv
module use ${INSTALL_PREFIX}/staff_modulefiles 
# we need the python module to be available in order to run spack
module --ignore-cache load pawseyenv/${pawseyenv_version} 
# swap is needed for the pawsey_temp module to work
module swap PrgEnv-gnu PrgEnv-cray
module swap PrgEnv-cray PrgEnv-gnu
module load spack/${spack_version}

echo "Run concretization.."
"${ROOT_DIR}/scripts/run_concretization.sh"

echo "Run install all.."
"${ROOT_DIR}/scripts/run_installation_all.sh"
