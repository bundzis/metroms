#PBS -N beaufort_roms_cice
#PBS -A bundzis
#PBS -l select=1:ncpus=368:mpiprocs=16:ompthreads=16
#PBS -j oe
#PBS -V
datstamp=`date +%Y_%m_%d_%H_%M`
exec 1>/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch/run.log_${datstamp} 2>&1
# Load modules needed
#source /etc/profile.d/modules.sh

source myenv.bash perlmutter
source env.sh

export PYTHONPATH=$PYTHONPATH:/global/homes/b/bundzis/Repos/metroms/apps/common/python/
export MYHOST=perlmutter

module load python
#
#cd ~/metroms/apps/arctic-20km
python beaufort_roms_cice_run.py
