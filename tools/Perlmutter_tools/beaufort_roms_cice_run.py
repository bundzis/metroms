########################################################################
# Python-modules:
########################################################################
import numpy as np
import os
import Constants
from datetime import datetime, timedelta
########################################################################
# METROMS-modules:
########################################################################
from GlobalParams import *
from Params import *
from ModelRun import *
########################################################################
########################################################################
# Set cpus for ROMS:
xcpu=32
ycpu=8
# Set cpus for CICE:
icecpu=112
# Choose a predefined ROMS-application:
app='beaufort_roms_cice' 

start_date = datetime(2019,1,1,00)
end_date   = datetime(2020,1,1,00)

print('start_date: ', start_date)
print('end_date: ', end_date)


beaufort_params=Params(app,xcpu,ycpu,start_date,end_date,nrrec=0,cicecpu=icecpu,restart=False)

modelrun=ModelRun(beaufort_params)

print('GLOBAL RUNDIR: ', GlobalParams.RUNDIR)
print('GLOBAL PARAMS: ', GlobalParams.COMMONPATH)

modelrun.preprocess()
modelrun.run_roms(Constants.MPI,Constants.NODEBUG,Constants.PERLMUTTER) #24h hindcast
#modelrun.run_roms(Constants.DRY,Constants.NODEBUG,Constants.MET64) #24h hindcast
#modelrun.postprocess()

