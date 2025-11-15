class GlobalParams(object):
    import getpass
    import os
    import sys

    username=getpass.getuser()

    MYHOST=os.environ.get('METROMS_MYHOST','metlocal')

    print('MYHOST: ', MYHOST)

    if MYHOST=='metlocal':
        METROMSDIR=os.environ.get('METROMS_BASEDIR','/disk1/'+username+'/metroms')
        tmpdir=os.environ.get('METROMS_TMPDIR','/disk1/'+username)
        RUNDIR=tmpdir
    elif MYHOST=='vilje' or MYHOST=='alvin' or MYHOST=='met_ppi' or MYHOST=='elvis' or MYHOST=='nebula' or MYHOST=='stratus' or MYHOST=='fram':
        HOME=os.environ.get('HOME')
        if HOME=='None':
            print("Environment variable HOME not found in configuration")
            sys.exit(1)

        METROMSDIR=os.environ.get('METROMS_BASEDIR',HOME+'/metroms')

        tmpdir=os.environ.get('METROMS_TMPDIR','/work/'+username)
        RUNDIR=tmpdir
        METROMSAPPDIR=os.environ.get('METROMS_APPDIR',HOME+'/metroms_apps')
    elif MYHOST=='perlmutter':
        HOME=os.environ.get('HOME')
        if HOME=='None':
            print("Environment variable HOME not found in configuration")
            sys.exit(1)

        METROMSDIR=os.environ.get('METROMS_BASEDIR','/global/homes/b/bundzis/Repos/metroms')

        tmpdir=os.environ.get('METROMS_TMPDIR','/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch')
        RUNDIR=tmpdir
        METROMSAPPDIR=os.environ.get('METROMS_APPDIR','/global/homes/b/bundzis/pscratch/sd/b/bundzis/Beaufort_ROMS_CICE_test_02_scratch')
    else:
        print('Environment variable MYHOST not defined or unknown (metlocal,vilje,)')
        sys.exit(1)

    COMMONPATH=METROMSDIR+"/apps/common"
    COMMONORIGPATH=COMMONPATH+"/origfiles"

    ########################################################################
    # Internal files:
    ########################################################################
