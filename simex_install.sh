#!/usr/bin/env bash

set -e

BRANCH=master
URL=https://github.com/PaNOSC-ViNYL/SimEx/archive/${BRANCH}.zip

cd /opt

wget $URL
unzip ${BRANCH}.zip
rm ${BRANCH}.zip
cd SimEx-${BRANCH}

export PATH=/opt/miniconda/bin:$PATH
#export HDF5_ROOT=/opt/miniconda

echo "###### DONE unzip ${BRANCH}.zip"

conda install -c intel mkl
export MKLROOT=/opt/miniconda

# This is a dirty hack
pushd ${MKLROOT}/lib
ln -s . intel64
popd

echo "##### DONE install mkl"

ROOT_DIR=/opt/simex_platform
mkdir -p $ROOT_DIR

# Create new build dir and cd into it.

mkdir -v build
cd build

# Uncomment the next line and specify the install dir for a custom user install.
#cmake -DCMAKE_INSTALL_PREFIX=$ROOT_DIR $ROOT_DIR
# Uncomment the next line and specify the install dir for a developer install.
cmake -DUSE_XCSITPhotonDetector=OFF \
      -DUSE_GAPDPhotonDiffractor=OFF \
      -DUSE_CrystFELPhotonDiffractor=ON \
      -DUSE_SingFELPhotonDiffractor=ON \
      -DINSTALL_TESTS=OFF \
      -DSRW_OPTIMIZED=ON \
      -DDEVELOPER_INSTALL=OFF \
      -DCMAKE_INSTALL_PREFIX=$ROOT_DIR \
      -DUSE_sdf=ON \
      -DUSE_s2e=ON \
      -DUSE_S2EReconstruction_EMC=ON \
      -DUSE_S2EReconstruction_DM=ON \
      -DUSE_wpg=ON \
      -DUSE_GenesisPhotonSource=ON \
      -DUSE_FEFFPhotonInteractor=ON \
      $ROOT_DIR \
      .. 

chmod og+rwX -R $ROOT_DIR

# Build the project.
make -j12

echo "######## done make"

# Install the project.
make install
cd ../..

echo "####### done make install"

#rm -rf simex_platform-${BRANCH}


#remove tests?
#rm -rf $ROOT_DIR/Tests

echo "source /opt/simex_platform/bin/simex_vars.sh" > /etc/profile.d/scripts-simex.sh && \
	chmod 755 /etc/profile.d/scripts-simex.sh


echo "export PYFAI_TESTIMAGES=/tmp" >> /etc/profile.d/scripts-simex.sh


chmod og+rwX -R /opt/simex_platform

