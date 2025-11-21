#!/bin/bash
set -x
#############################################################################
# -------------- Compile ROMS-CICE from metROMS on Perlmutter ---------------
#############################################################################
# The purpose of this bash script is to do all of the edits in files and 
# calls needed to be able to compile ROMS-CICE on Perlmutter with a few
# User-specified edits...hopefully (: 
#
# The script can be ran by opening a terminal, making a project directory
# where you want everything to live, copying this script into it, then 
# calling this script:
#
#                    ./compile_roms_cice_perlmutter.sh
#
# which should work once all the **USER INPUT** sections have been updated
# and other things have been added to the Project directory, including:
#
# (1) ice_in
# (2) an 'Include' directory with the ROMS header file, the grid 
#     and kmt files for CICE, roms.in, initial conditions netcdf for CICE, 
#     and maybe more but that's all I know for now
# (3)  A copy of the script 'fix_long_fflags_rule.mk'
#
#
# Notes:
# - There are several spots where you will need to change the 
#   paths/directories/filenames that will be labeled with a
#   **USER INPUT** comment
#
# - This script assumes you have a project directory different from the 
#   metroms repo where you will build everything. Examples I did are:
#           /global/homes/b/bundzis/Projects/Beaufort_ROMS_CICE
#          /pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_scratch
#
# - Wherever you decide to build, it will put the cice and roms source codes
#   (trunks) there so future work could be making these write to the metroms
#   repo instead but you need to compile anytime you make changes to CICE 
#   or tiling 
#
# - Most of these are text changes to the scripts but some are actual things 
#   to run in here but no one else should need to worry about that but meeee
#   (it has been written to do all of that for you so all you need to do is
#    run this script)
#
# - For the purposes of testing this, the new Project directory will be 
#   /pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_scratch but the original
#   is /global/homes/b/bundzis/Projects/Beaufort_ROMS_CICE
#
# - User should absolutely check all filepaths, especially those in the sed
#   commands since they will probably need to be manually changed...(sorry)
#
# - If editing this script, absolutely DO NOT include inline comments or 
#   spaces at the end of any line with code at all ever in your life 
#   because it will cause errors and decrease the otherwise joyful 
#   experience you will have with this script 
#
# - Naturally, if this script fails when building, it is advised to manually 
#  "clean" your COMP_DIR by running the following (in COMP_DIR) to make sure
#   everything rebuilds when you rerun:
#        rm -r cice
#        rm -r build
#        rm -r MCT
#        rm -r roms_src
#        rm build_*.sh
#############################################################################
#############################################################################

# Set the directory that you are running this script in (your project directory)
# | **USER INPUT** |
export COMP_DIR=/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch

# Set the directory where you cloned metroms 
# | **USER INPUT** |
export METROMS_BASEDIR=/global/homes/b/bundzis/Repos/metroms

# Set the directory where the CICE code will go (same as compiling dir for me)
# | **USER INPUT** |
export METROMS_TMPDIR=/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch

# Set the version of CICE to use
# | **USER INPUT** |
export CICEVERSION=cice5.1.2

# Set the directory where the cice code will go
# | **USER INPUT** |
export CICE_DIR=${COMP_DIR}/cice

# Set the HPC
# | **USER INPUT** |
export METROMS_MYHOST=perlmutter

# Set the ROMS application name
export ROMS_APPLICATION=BEAUFORT_ROMS_CICE


# Load in the modules needed for building 
# (and use the same ones for running - the ones here 
# work for Perlmutter as of 11/11/2025)
module purge 
set +e
module load PrgEnv-gnu
module load gcc-native/12.3
module load cray-hdf5/1.14.3.1
module load cray-netcdf/4.9.0.13
module load cray-parallel-netcdf
module load cray-mpich
set -e
echo "Loaded modules"

# Go into the compiling directory 
cd ${COMP_DIR}

# Copy in the build scripts
cp -a ${METROMS_BASEDIR}/apps/build_mct.sh $COMP_DIR
cp -a ${METROMS_BASEDIR}/apps/build_cice.sh $COMP_DIR
cp -a ${METROMS_BASEDIR}/apps/build_roms.sh $COMP_DIR


# ------------------------------------------------------------------------
# ------------------------- MCT: build_mct.sh ----------------------------
# ------------------------------------------------------------------------
# Other scripts that this calls:
# - N/A
# Notes:
# - To verify if MCT build correctly, you should have a MCT directory in
#   your COMP_DIR

# ------ build_mct.sh ------

# At the top of the file under 'set -x' (line ~4)
sed -i "/set -x/a\\
\\
export METROMS_TMPDIR=${METROMS_TMPDIR}\\
export METROMS_BASEDIR=${METROMS_BASEDIR}\\
export METROMS_MYHOST=perlmutter" ${COMP_DIR}/build_mct.sh


# Add in the elif for perlmutter (line ~33)
sed -i '/elif \[ ${METROMS_MYHOST} == "fram" \]/i\
elif [ ${METROMS_MYHOST} == "perlmutter" ] ; then \
    FORT=gfortran\
    MPIFC=mpif90\
    export FCFLAGS="-fallow-argument-mismatch -ffree-line-length-none"' ${COMP_DIR}/build_mct.sh


# Change the config command and the lines under it
# OG works but might be flawed
#sed -i 's|^\./configure FC=$FORT MPIFC=$MPIFC --prefix=$MCT_DIR|#&\
#./configure FC=$FORT MPIFC=$MPIFC CPPFLAGS="-DUSE_USE_MPI" --prefix=$MCT_DIR|' ${COMP_DIR}/build_mct.sh
# New attempt at fix
#sed -i 's|^\./configure FC=\$FORT MPIFC=\$MPIFC --prefix=\$MCT_DIR|#&\
#./configure FC=$FORT MPIFC=$MPIFC CPPFLAGS="-DUSE_USE_MPI -DMPI_IN_PLACE=-1 -DMCT_DEBUG -DMCT_ABORT_ON_ERROR" --prefix=$MCT_DIR|' ${COMP_DIR}/build_mct.sh
# Another attempt at a fix
sed -i 's|^\./configure FC=\$FORT MPIFC=\$MPIFC --prefix=\$MCT_DIR|#&\
./configure FC=$FORT MPIFC=$MPIFC \\\
  CPPFLAGS="-DUSE_MPI -DMPI_IN_PLACE=-1 -DMCT_DEBUG -DMCT_ABORT_ON_ERROR" \\\
  CFLAGS="-O2 -march=native" \\\
  --prefix=$MCT_DIR|' ${COMP_DIR}/build_mct.sh




sed -i '/configure FC=$FORT MPIFC=$MPIFC CPPFLAGS="-DUSE_USE_MPI" --prefix=$MCT_DIR/a\
rm -f *.o *.mod lib/\*.a' ${COMP_DIR}/build_mct.sh

sed -i '/make clean/s/^/#/' ${COMP_DIR}/build_mct.sh

# That's all, then call by doing the following command in your 
# project directory where build_mct.sh lives (uncomment here when ready to build MCT)
./build_mct.sh 


# ------------------------------------------------------------------------
# ----------------------- CICE: build_cice.sh ----------------------------
# ------------------------------------------------------------------------
# Other scripts that this calls:
# - comp_ice
#      (${METROMS_BASEDIR}/apps/common/modified_src/cice5.1.2/comp_ice)
# - Makefile 
#      (${COMP_DIR}/cice/bld/Makefile)
#   - This is hidden/does not exist until the cice code is unzipped 
#   - So if you unzip again, you will overwrite any edits to Makefile 
#     in local cice that you made
# - Macros.Linux.perlmutter 
#      (will be copied from somewhere into ${COMP_DIR}/cice/bld once cice code is unzipped)
# - ice_in 
#      (copies it from your COMP_DIR to your COMP_DIR...redundant right now and 
#       probably very unnecessary)
# - ice_da.F90 
#       (${METROMS_BASEDIR}/apps/common/modified_src/cice5.1.2/source)
# - makdep.c 
#       (${COMP_DIR}/cice/bld/makdep.c)
#   - This needs to be edited to be more compatible with C compiler; This 
#     is optional, it will only throw a warning but not an error. This 
#     script updates it to be safe
# 
# 
# Notes:
# - User should have a directory with the cice grid and kmt files (Include dir in COMP_DIR)
# - User should also have an ice_in and know where it is since it will be edited
#   and copied into a different directory 
#   - Right now this script assumes it is in COMP_DIR
#
#

# ------ build_cice.sh ------

# Make sure it has (make sure the version of CICE matches what you will use)
# This is done by default so I am not going to make a command for this for now
#export CICEVERSION=cice5.1.2


# Add to the top of the file under 'export CICEVERSION=cice5.1.2'
sed -i "/export CICEVERSION=cice5.1.2/a\\
\\
export METROMS_TMPDIR=${METROMS_TMPDIR}\\
export METROMS_BASEDIR=${METROMS_BASEDIR}\\
export METROMS_MYHOST=perlmutter" ${COMP_DIR}/build_cice.sh


# Hard set the number of processors for the CICE model and add in the option
# for perlmutter (after exporting all of the directories above)
# Define the number of processors in x and y for CICE model 
# Change in the variables below (NPX, NPY) in the sed commands - Bri 
# currently has them set to 14x8
# | **USER INPUT** |
sed -i 's/NPX=1; NPY=1/NPX=1; NPY=1/' ${COMP_DIR}/build_cice.sh
# Same can be done for blocking if/when User knows what blocking they want

sed -i '/elif \[ "${METROMS_MYHOST}" == "vilje" \] || \\/a\
     \[ "${METROMS_MYHOST}" == "perlmutter" \] || \\' ${COMP_DIR}/build_cice.sh

sed -i '/then/,\/fi/ {
  /NPX=1/s/NPX=1/NPX=1/
  /NPY=2/s/NPY=2/NPY=1/
}' ${COMP_DIR}/build_cice.sh


# Set the ROMS application name (line 32 under printing of things)
sed -i "s/export ROMS_APPLICATION=\$1/export ROMS_APPLICATION=${ROMS_APPLICATION}/" ${COMP_DIR}/build_cice.sh


# Set the directory for the CICE folder for all of its code (line ~62)
# Sorry...really struggled to get this to use the variables in this script
# so this needs to be manually set unfortunately (replace /pscratch/sd/b/bundzis/...)
# | **USER INPUT** |
sed -i 's|export CICE_DIR=${METROMS_TMPDIR}/$ROMS_APPLICATION/cice|export CICE_DIR=/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/cice|' ${COMP_DIR}/build_cice.sh


# Change into METROMS_TMPDIR (line ~73)
sed -i 's|cd ${METROMS_TMPDIR}/$ROMS_APPLICATION|cd ${METROMS_TMPDIR}|' ${COMP_DIR}/build_cice.sh


# Need to unzip the CICE code into METROMS_TMPDIR but then after that, need
# to copy in the Macros.Linux.perlmutter file (from somewhere else). So 
# instead of unzipping in build_cice.sh, unzip here, then copy in that
# folder, then continue 

# Comment out the tar line in build_cice.sh (line ~77)
sed -i '/tar -xvf ${METROMS_BASEDIR}/s/^/#/' ${COMP_DIR}/build_cice.sh


# Change into the directory where the CICE code should go 
cd ${METROMS_TMPDIR}

# Unzip the cice code into METROMS_TMPDIR
tar -xvf ${METROMS_BASEDIR}/static_libs/$CICEVERSION.tar.gz

# Copy in the Macros.Linux.Perlmutter to the right spot in the cice directory
# Copy in the one from my running directory for now...User should change to 
# wherever they have Macros.Linux.Perlmutter
# | **USER INPUT** |
cp -a /global/homes/b/bundzis/Projects/Beaufort_ROMS_CICE/cice/bld/Macros.Linux.perlmutter $METROMS_TMPDIR/cice/bld

# Then continue normal things in build_cice.sh

# Change the line that copies in things from modified_src to exclude comp_ice
# so that we can edit the local one without messing up other runs
sed -i 's|cp -a ${METROMS_BASEDIR}/apps/common/modified_src/$CICEVERSION/\* $CICE_DIR|rsync -av --exclude '"'"'comp_ice'"'"' ${METROMS_BASEDIR}/apps/common/modified_src/$CICEVERSION/ $CICE_DIR|' ${COMP_DIR}/build_cice.sh


# Change where the grid stuff is being copied from (line ~92)
# User needs to change the name and the location of the grid and kmt files 
# below so that they can be copied into the newly created cice_input_grid 
# directory. 
# (replace /global/homes/b/bundzis/... with the location of 
# the cice_input_grid directory that you make below) But first need to make the 
# directory where build_cice.sh expects them, then put them in there,
# then change the path in the sed command 
# | **USER INPUT** |
mkdir -p ${COMP_DIR}/cice_input_grid
cp -p ${COMP_DIR}/Include/new_cice.grid.nc ${COMP_DIR}/cice_input_grid
cp -p ${COMP_DIR}/Include/new_cice.kmt.nc ${COMP_DIR}/cice_input_grid
sed -i 's|cp -av ${METROMS_APPDIR}/$ROMS_APPLICATION/cice_input_grid/\*|cp -av /pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/cice_input_grid/\*|' ${COMP_DIR}/build_cice.sh


# ------ comp_ice ------

# Manually copy the original one to where this one should be so that it can be edited 
# (and then it won't be overwritten since we are excluding it above since build_cice.sh 
# would otherwise overwrite our edits by copying it from metroms)
# | **USER INPUT** |
# IF starting with new Github repo/unzipped, copy from here/uncomment this line
#cp -a ${METROMS_BASEDIR}/apps/common/modified_src/cice5.1.2/comp_ice ${CICE_DIR}
# ELSE IF starting from Bri's already fixed metroms, start here/uncomment this line
cp ${METROMS_BASEDIR}/apps/common/modified_src/cice5.1.2/comp_ice_og ${CICE_DIR}/comp_ice

# Now edit this one since this is the one that will be executed 

# Set the SRCDIR and EXEDIR (line ~15)
sed -i "/export SRCDIR=\$CICE_DIR/a\export EXEDIR=${COMP_DIR}" ${CICE_DIR}/comp_ice


# Add an elif for perlmutter (line ~33) 
sed -i '/elif \[ "\$METROMS\_MYHOST" == "nebula2" \]/i\
elif [ "$METROMS_MYHOST" == "perlmutter" ]; then \
    export SITE=Linux.perlmutter' "${CICE_DIR}/comp_ice"


# Set the name of the grid (might not be necessary but keeping it 
# since it works) (line ~50)
# If changing the name of the grid (only referenced in build scripts),
# then change it here from 'beaufort_roms_cice' to whatever you want
# but be sure to be consistent about replacing it in this script
# (not recommended)
# | **USER INPUT** |
sed -i '/^GRID=GRID/a\GRID=beaufort_roms_cice' ${CICE_DIR}/comp_ice


# Add in the grid to the list of cases of grids (line ~59)
# | **USER INPUT** | (if changing from 'beaufort_roms_cice'; not recommended)
sed -i "/^# *'gx1') GRID=/i\    'BEAUFORT_ROMS_CICE' | 'beaufort_roms_cice') GRID=608x206;;" ${CICE_DIR}/comp_ice


# Set restart equal to false (or true - default is true) (line ~74)
# User can change this if we run from restart instead (which would 
# require other changes that this script does not currently do but can/will be updated)
# | **USER INPUT** |
sed -i 's/restart='\''\.true\.'\''/restart='\''\.false\.'\''/g' ${CICE_DIR}/comp_ice


# User should look through comp_ice settings for the sea ice model 
# to see if they want to change anything like tracers and number of 
# vertical ice and snow layers. This script might also have the locations
# of where the output will be written...so definitely change that when
# it starts running... (lines ~187 - 191). Putting relevant section here for
# now but not changing anything
# export OBJDIR=$EXEDIR/compile           ; [ -d $OBJDIR ] ||  mkdir -p $OBJDIR  
# export RSTDIR=$EXEDIR/restart           ; [ -d $RSTDIR ] ||  mkdir -p $RSTDIR 
# export HSTDIR=$EXEDIR/history           ; [ -d $HSTDIR ] ||  mkdir -p $HSTDIR 
# Leaving the above paths alone for now but maybe come back to this later


# Comment out the copying of the Makefile (line ~194)
sed -i 's/^ *cp -f \$CBLD\/Makefile\.std \$CBLD\/Makefile/# &/' ${CICE_DIR}/comp_ice


# Add elif to copy in your grid and kmt files (lines ~204 - 213)
# Unfortunately User needs to manually set the paths for the grid and kmt files
# so replace '/global/homes/b/bundzis/.../new_cice.grid.nc' and same for kmt to 
# wherever these files live for you. No need to edit the other lines
# | **USER INPUT** |
gawk -i inplace '
BEGIN {inblock=0; replaced=0}
/^[[:space:]]*if[[:space:]]*\[.*arctic-20km.*\]\s*\|\|[[:space:]]*\[.*arctic-4km.*\];[[:space:]]*then/ && !replaced {
    inblock=1
    replaced=1
    print "if [ $RES == '\''arctic-20km'\'' ] || [ $RES == '\''arctic-4km'\'' ]; then"
    print "    cp -auv $SRCDIR/input_templates/$RES/cice.grid.nc cice.grid.nc"
    print "    cp -auv $SRCDIR/input_templates/$RES/cice.kmt.nc cice.kmt.nc"
    print "elif [ $RES == '\''BEAUFORT_ROMS_CICE'\'' ]; then"
    print "    cp -auv /pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/cice_input_grid/new_cice.grid.nc grid.nc"
    print "    cp -auv /pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/cice_input_grid/new_cice.kmt.nc kmt.nc"
    print "elif [ ! $RES == '\''col'\'' ]; then"
    print "    cp -auv $SRCDIR/input_templates/$RES/global_$RES.grid.nc grid.nc"
    print "    cp -auv $SRCDIR/input_templates/$RES/global_$RES.kmt.nc kmt.nc"
    next
}
inblock && /^[[:space:]]*fi[[:space:]]*$/ { inblock=0; next }
!inblock { print }
' ${CICE_DIR}/comp_ice


# Edit the if statement to include our case so that we do not load 
# in some restart file from the cice directory (lines ~220 - 223)
# IF we do run from restart one day, this should be replaced with a sed 
# command that instead edits this section to point to the restart file
# User may need to change this if they decide to change the ROMS_APPLICATION name
# | **USER INPUT** |
sed -i "s/if \[ ! \$RES == 'arctic-20km' \]/if \[ ! \$RES == 'BEAUFORT_ROMS_CICE' \]/" ${CICE_DIR}/comp_ice


# Change the sed command that copies in ice_in (line ~271)
# Make this more robust with filepath (I think this is redundant but oh well leave for now)
# User change this to match wherever ice_in is stored for you (replace /pscratch/sd/b/bundzis/.../ice_in)
# | **USER INPUT** |
sed -i 's#$SRCDIR/input_templates/$RES/ice_in.$CICEVERSION#/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/ice_in#' ${CICE_DIR}/comp_ice


# Optional adding of echo commands to see where things are (recommended) (lines ~308)
sed -i "/^MAKE=\$(which gmake)$/a\\\n\
echo \"SRCDIR: \$SRCDIR\"\n\
echo \"PWD: \$PWD\"\n\
echo \"CBLD: \$CBLD\"\n\
echo \"Makefile: \$CBLD/Makefile\"\n\
echo \"NXGLOB - \$NXGLOB: \$NXGLOB\"\n\
echo \"NYGLOB - \$NYGLOB: \$NYGLOB\"" ${CICE_DIR}/comp_ice


# Set the err variable to 0 and set the MCT and Cray things (lines ~327 - 330)
# User will need to change the paths to wherever MCT will be built for them
# which should be ${COMP_DIR}/MCT/include and ${COMP_DIR}/MCT/lib which won't exist until
# this script is actually executed (specifically ./build_mct.sh)
# | **USER INPUT** |
sed -i "/^if \[ \$comp -eq 1 \]; then/i\
err=0\n\
export CRAY_CPU_TARGET=x86-64\n\
export MCT_INCDIR=/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/MCT/include\n\
export MCT_LIBDIR=/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/MCT/lib\n" ${CICE_DIR}/comp_ice


# Edit the make command (lines ~334 - 348)
sed -i "/^if \[ \$comp -eq 1 \]; then/,/^fi$/c\
if [ \$comp -eq 1 ]; then\n\
    cc -o makdep \$CBLD/makdep.c                      || exit 2\n\
\n\
    \$MAKE -j \$ncomp -f \$CBLD/Makefile FC=mpif90 VPFILE=Filepath EXEC=\$EXEDIR/cice \\\\\n\
        NXGLOB=\$NXGLOB NYGLOB=\$NYGLOB \\\\\n\
        BLCKX=\$BLCKX BLCKY=\$BLCKY MXBLCKS=\$MXBLCKS \\\\\n\
        MACFILE=\$CBLD/Macros.Linux.perlmutter || err=1\n\
\#   -f  \$CBLD/Makefile MACFILE=\$CBLD/Macros.\$SITE || exit 2\n\
fi" ${CICE_DIR}/comp_ice


# ------ makdep.c ------ 
# *Optionally* edit this to have 'int main' instead of 'main' to be more compatible with c compiler
# Note that this is sensitive to unzipping and will be overwritten if cice is unzipped
# Change 'main' to 'int main' in line 54
sed -i 's/main (int argc, char \*\*argv)/int main (int argc, char \*\*argv)/' ${CICE_DIR}/bld/makdep.c


# ------ ice_da.F90 ------
# sed command to change '==' to '.eqv.' or something like that in certain line...
# Edit line 343 to be (so replace ' == ' with ' .eqv. ') to be compatible with gfortran
sed -i 's/if (da_sic == \.true\.)/if (da_sic .eqv. \.true\.)/' ${METROMS_BASEDIR}/apps/common/modified_src/cice5.1.2/source/ice_da.F90


# ------ Makefile ------
# Any edits to Makefile?
# Nope


# ------ Macros.Linux.perlmutter ------
# Anything to Macros.Linux.perlmutter?
# Nope


# ------ ice_in ------
# Edit ice_in separately and make sure it is properly linked before compiling/building build_cice.sh!
# And then make it is linked properly above for comp_ice (line ~321 in this script)
# which mainly means make sure it is in your COMP_DIR


# Once all of these files have been edited, can build cice!
./build_cice.sh BEAUFORT_ROMS_CICE



# ------------------------------------------------------------------------
# ----------------------- ROMS: build_roms.sh ----------------------------
# ------------------------------------------------------------------------
# Other scripts that this calls:
# - makefile 
#        (${COMP_DIR}/roms_src/makefile)
#   - This script will unzip the roms source code to make this folder 
#     and then edit it 
# - Linux-gfortran.mk 
#        (${COMP_DIR}/roms_src/ROMS/Compilers/Linux-gfortran.mk)
#   - This bash script will copy this over from somewhere specified by 
#     the user into the correct roms folder once roms code is unzipped 
# 
# 
# Notes:
# - This code will unzip and edit roms file as needed 
# - User needs to copy coupling.dat into ${METROMS_BASEDIR}/apps/common/modified_src/${roms_ver}
#   so there is a spot to do this below
#


# ------ build_roms.sh -------

# Towards the top, set the ROMS application name, some directories, and 
# other things (lines ~58 - 64)
# | **USER INPUT** | (if using a different version of ROMS, not recommended)
sed -i "s/export ROMS_APPLICATION=\$1/export ROMS_APPLICATION=${ROMS_APPLICATION}/" ${COMP_DIR}/build_roms.sh
sed -i 's/export roms_ver="roms-trunk820"/export roms_ver="roms-3.9"/' ${COMP_DIR}/build_roms.sh
sed -i "/^# Default settings:$/i\
export METROMS_BLDDIR=${METROMS_TMPDIR}\n\
export METROMS_MYHOST=perlmutter\n" ${COMP_DIR}/build_roms.sh

# Add an elif for perlmutter (lines ~84 - 89)
# (maybe take out -ffast-math depending on conversation with Mark) - still needs to be discussed 
sed -i "/elif \[ \"\${METROMS_MYHOST}\" == \"nebula\" \] || \\\/i\
elif [ \${METROMS_MYHOST} == \"perlmutter\" ] ; then \n\
    FORT=gfortran\n\
    MPIFC=mpif90\n\
    export FCFLAGS=\"-ffree-line-length-none -fallow-argument-mismatch -fbounds-check -fbacktrace -fcheck=all -O3 -march=native -ffast-math\"\n\
    #export FCFLAGS=\"-fallow-argument-mismatch\"" ${COMP_DIR}/build_roms.sh


# Export/Set a whole bunch of directories (lines ~121 - 123)
sed -i "/^if \[ ! -d \${METROMS_TMPDIR} \] ; then/i\
export METROMS_TMPDIR=${COMP_DIR}\\
export METROMS_BASEDIR=${METROMS_BASEDIR}\\
export METROMS_MYHOST=perlmutter\n" ${COMP_DIR}/build_roms.sh


# Need to unzip the ROMS source code
# Comment out the line that unzips this in build_roms.sh (line ~142)
sed -i 's/^tar -xf \${METROMS_BASEDIR}\/static_libs\/\${roms_ver}\.tar\.gz/#&/' ${COMP_DIR}/build_roms.sh


# Unzip the ROMS code into the place we want
# | **USER INPUT** | (if using different version of ROMS, not recommended)
export roms_ver="roms-3.9"
export MY_ROMS_SRC=${METROMS_TMPDIR}/roms_src
mkdir -p ${MY_ROMS_SRC}
cd ${MY_ROMS_SRC}
tar -xf ${METROMS_BASEDIR}/static_libs/${roms_ver}.tar.gz


# Explicitly set the compiler just to be safe
# Copy in the Linux-gfortran.mk file from somewhere else to the unzipped roms_src/ROMS/Compilers
# Rename the original unzipped one first
mv ${MY_ROMS_SRC}/Compilers/Linux-gfortran.mk ${MY_ROMS_SRC}/Compilers/Linux-gfortran-og.mk
# User needs to specify where they are copying Linux-gfortran.mk from (so replace
# /global/homes/b/bundzis/... in both cp commands below)
# | **USER INPUT** | 
# First line copying into MY_ROMS_SRC/Compilers might not be needed since I think 
# the build copies it into there so try with this uncommented 
cp /global/homes/b/bundzis/Projects/Linux-gfortran.mk ${MY_ROMS_SRC}/Compilers
cp /global/homes/b/bundzis/Projects/Linux-gfortran.mk ${METROMS_BASEDIR}/apps/common/modified_src/${roms_ver}

# Now it is safe to set it in build_roms.sh (line ~160)
sed -i "/^export COMPILERS=\${MY_ROMS_SRC}\/Compilers/a\
export COMPILER=Linux-gfortran.mk" ${COMP_DIR}/build_roms.sh


# Add code to hardset the MCT libraries 
sed -i "/^export COMPILER=Linux-gfortran.mk/a\export MCT_INCDIR=${COMP_DIR}/MCT/include\\nexport MCT_LIBDIR=${COMP_DIR}/MCT/lib" "${COMP_DIR}/build_roms.sh"


# Fix the crazy infinite loop (replace lines ~167 - 183) with this
sed -i '/while \[ \$# -gt 1 \]/,/done/ c\
while [ $# -gt 0 ]; do\
  case "$1" in\
    -j)\
      shift\
      parallel=1\
      if [[ "$1" =~ ^[0-9]+$ ]]; then\
        NCPUS="-j $1"\
        shift\
      else\
        NCPUS="-j"\
      fi\
      ;;\
    -noclean)\
      clean=0\
      shift\
      ;;\
    *)\
      shift\
      ;;\
  esac\
done' "${COMP_DIR}/build_roms.sh"


# Change the directory it changes to (line ~211)
sed -i 's/cd \${ROMS_APPLICATION}/cd \${MY_PROJECT_DIR}/' ${COMP_DIR}/build_roms.sh


# Set some directories (lines ~218 - 227) and comment out old versions or replace them
sed -i "s#^export MY_ROOT_DIR=\${METROMS_APPDIR}\/\${ROMS_APPLICATION}\/#export MY_ROOT_DIR=${COMP_DIR}#" ${COMP_DIR}/build_roms.sh
sed -i "s#^export MY_PROJECT_DIR=\${METROMS_APPDIR}\/\${ROMS_APPLICATION}\/#export MY_PROJECT_DIR=\${MY_ROOT_DIR}#" ${COMP_DIR}/build_roms.sh


# Add a C Flag to make sure it uses netcdf (might not be needed but can't hurt...)
# (line ~367)
sed -i 's/-DCICE_OCEAN"/-DCICE_OCEAN -DUSE_NETCDF4"/' ${COMP_DIR}/build_roms.sh


# Change the header dir (line ~377)
sed -i 's/export MY_HEADER_DIR=\${MY_PROJECT_DIR}\/include/export MY_HEADER_DIR=\${MY_PROJECT_DIR}\/Include/' ${COMP_DIR}/build_roms.sh
sed -i 's/^export MY_ANALYTICAL_DIR=\${MY_HEADER_DIR}/#&/' ${COMP_DIR}/build_roms.sh


# Set the BINDIR (line ~387)
sed -i "s#^export BINDIR=\${METROMS_TMPDIR}\/\${ROMS_APPLICATION}\$#export BINDIR=\${MY_PROJECT_DIR}#" ${COMP_DIR}/build_roms.sh


# Replace the calls to the make command since they don't have locations 
# Replace lines ~390 - 401 with this
sed -i "/^if \[ \$clean -eq 1 \]; then/ {
  n
  s/^[[:space:]]*make clean[[:space:]]*$/  make clean SCRATCH_DIR=\${SCRATCH_DIR}/
}" ${COMP_DIR}/build_roms.sh

sed -i "/^if \[ \$parallel -eq 1 \]; then/ {
  n
  s/^[[:space:]]*make \$NCPUS[[:space:]]*$/  make \$NCPUS SCRATCH_DIR=\${SCRATCH_DIR}/
}" ${COMP_DIR}/build_roms.sh

sed -i 's/^[[:space:]]*make[[:space:]]*$/  make SCRATCH_DIR=\${SCRATCH_DIR}/' ${COMP_DIR}/build_roms.sh


# Always build in the top-level /build folder, not inside roms_src
sed -i "/^mkdir -p \$BINDIR$/a\
export SCRATCH_DIR=\${METROMS_BLDDIR}\/build" ${COMP_DIR}/build_roms.sh


# Need to copy in coupling.dat from somewhere to where this script expects it
# User uncomment and change the paths to match where your coupling.dat is 
# | **USER INPUT** |
#cp /path/to/coupling.dat ${METROMS_BASEDIR}/apps/common/modified_src/${roms_ver}


# ------ makefile ------
# This can be edited once the ROMS source code has been unzipped

# Set the ROMS application (line ~62)
sed -i "s/^ROMS_APPLICATION ?= UPWELLING$/ROMS_APPLICATION ?= ${ROMS_APPLICATION}/" ${COMP_DIR}/roms_src/makefile


# Make sure USE_NETCDF is on (line ~117)
sed -i 's/^\([[:space:]]*\)USE_NETCDF4 ?=/\1USE_NETCDF4 ?= on/' ${COMP_DIR}/roms_src/makefile


# Set Fortran compiler to gfortran (line ~142)
sed -i 's/^[[:space:]]*FORT ?= pgi/        FORT ?= gfortran/' ${COMP_DIR}/roms_src/makefile


# Set the scratch dir (line ~162)
sed -i 's/^[[:space:]]*SCRATCH_DIR ?= Build_roms/SCRATCH_DIR ?= build/' ${COMP_DIR}/roms_src/makefile


# Add text to make it print which *.mk file it is using (for debugging/sanity check)
sed -i 's/^\(\s*MKFILE := \$(COMPILERS)\/\$(OS)-\$(strip \$(FORT)).mk\)$/\1\n  \$(info >>> Using compiler configuration: \$(abspath \$(MKFILE)))/' "${COMP_DIR}/roms_src/makefile"

# Comment out the part the makes MakeDepend since we will do that
# manually in the build (lines ~587 - 596)
sed -i '/^\$(SCRATCH_DIR)\/MakeDepend:/,/cp -p \$(MAKE_MACROS) \$(SCRATCH_DIR)/ s/^/#/' ${COMP_DIR}/roms_src/makefile


# Edit where it points to sfmakedepend (line ~604)
sed -i "s|SFMAKEDEPEND := ./ROMS/Bin/sfmakedepend|SFMAKEDEPEND := ${COMP_DIR}/roms_src/ROMS/Bin/sfmakedepend|g" ${COMP_DIR}/roms_src/makefile


# Make a copy and rename it
cp ${MY_ROMS_SRC}/makefile ${MY_ROMS_SRC}/makefile_nofix


# Add in the stuff to fix mod_strings.f90 flags (lines ~206)
# User needs to edit the path to where fix_long_fflags_rule.mk lives
# (replace /pscratch/sd/b/bundzis/...) (recommended to put it in ${COMP_DIR})
# | **USER INPUT** |
sed -i "/^CLEAN := ROMS\/Bin\/cpp_clean$/r /pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/fix_long_fflags_rule.mk" ${COMP_DIR}/roms_src/makefile


# Save a copy of this version
cp ${MY_ROMS_SRC}/makefile ${MY_ROMS_SRC}/makefile_wfix


# I think the makefile_wfix was only needed before Perlmutter maintenance 
# but now we might not need the fix so I will change the workflow below...

# Then call build_roms.sh, that will crash, so then mv this makefile to be the other one
# and run build_roms.sh again (that will be in workflow below)


# ------ Linux-gfortran.mk ------
# This was copied in above so no need to do anything here...


# Now ready to build ROMS!
# Copy the project header file into the roms source code directory
cp ${COMP_DIR}/Include/beaufort_roms_cice.h ${COMP_DIR}/roms_src/ROMS/Include 

# Go into the roms_src and make dependencies
cd ${MY_ROMS_SRC}
make depend SCRATCH_DIR=${COMP_DIR}/build

# Go back and then copy in the netcdf.mod and typesizes.mod to build directory 
# (paths could be more robust/may need to be changed if using other NetCDF modules)
cd ../
cp /opt/cray/pe/netcdf/4.9.0.13/gnu/12.3/include/netcdf.mod ./build
cp /opt/cray/pe/netcdf/4.9.0.13/gnu/12.3/include/typesizes.mod ./build

# Make sure makefile is the right one 
# IF we need the fix
#cp ${MY_ROMS_SRC}/makefile_wfix ${MY_ROMS_SRC}/makefile
# IF we don't need the fix
cp ${MY_ROMS_SRC}/makefile_nofix ${MY_ROMS_SRC}/makefile

# Call the build once 
./build_roms.sh -j 4 -noclean >&compile_001.out || true

# ONLY UNCOMMENT BELOW if we need the fix for mod_strings.f90 in the makefile
# # This will stop prematurely in the makefile so change the makefile
# # to the other one without the mod_strings.f90 fix and run again 
# cp ${MY_ROMS_SRC}/makefile_nofix ${MY_ROMS_SRC}/makefile

# # Call the build again 
# ./build_roms.sh -j 4 -noclean >&compile_001.out

# After this, you should have a romsM in ${METROMS_TMPDIR} which is the same 
# as ${COMP_DIR}


set +x