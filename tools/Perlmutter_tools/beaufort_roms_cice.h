/*
** svn $Id: sed_toy.h 2232 2012-01-03 18:55:20Z arango $
*******************************************************************************
** Copyright (c) 2002-2012 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
**
** Application flag:   BEAUFORT_ROMS_CICE
** Input scripts:      ocean_beaufort_2020_dvd_myroms_ice.in
**                     ice.in
*/

#define ROMS_MODEL

/* === COUPLED ROMS–CICE SETTINGS === */

#define MODEL_COUPLING      /* tells ROMS this is a coupled simulation */
#define MCT_LIB             /* enable MCT driver library */
#undef MCT_COUPLING        /* use MCT coupler - this breaks the build */ 
#undef USE_MCT             /* (older versions use this spelling) - this breaks the build */

#define ICE_MODEL           /* activate sea ice model infrastructure */
#define CICE_COUPLING       /* ROMS is coupled to CICE */
#define CICE_OCEAN          /* ocean–ice exchange */
#define ICE_CICE            /* (some builds use this block name) */

/* Things from arctic-20km example*/
#define MODEL_COUPLING
#define HDF5

#undef  UV_VIS4            /* turn ON or OFF biharmonic horizontal mixing */
#undef  UV_U3ADV_SPLIT     /* use 3rd-order upstream split momentum advection */
#define UV_U3HADVECTION    /* define if 3rd-order upstream horiz. advection */
#undef  UV_SADVECTION      /* turn ON or OFF splines vertical advection */
#define  UV_C4HADVECTION    /* define if 4th-order centered horizontal advection */
#undef UV_SMAGORINSKY

#define TS_A4VADVECTION    /* define if 4th-order Akima vertical advection */
#undef  TS_C4VADVECTION    /* define if 4th-order centered vertical advection */
#undef  TS_SVADVECTION     /* define if splines vertical advection */
#undef  TS_SMAGORINSKY     /* define if Smagorinsky-like diffusion */

#undef  AVERAGES_AKT       /*undef Frode, define if writing out time-averaged AKt*/
#undef  AVERAGES_AKS       /*undef Frode, define if writing out time-averaged AKs*/
#undef  AVERAGES_AKV       /* define if writing out time-averaged AKv */
/* End things from arctic_20km */


#undef  BODYFORCE
#undef  LOG_PROFILE
#define DJ_GRADPS           /* Splines density  Jacobian (Shchepetkin, 2000) */
#define SALINITY
#define SPLINES_VVISC
#define SPLINES_VDIFF

#define OUT_DOUBLE
#define AVERAGES
/* Might not need PERFECT_RESTART but putting it here just in case */
#undef PERFECT_RESTART

/* Tracer Advection */
#define TS_MPDATA
#define TS_MPDATA_LIMIT
#define NONLIN_EOS
#undef HADVECTION
#undef VADVECTION

/* Numerical Mixing */
#undef TS_VAR
#undef T_PASSIVE
#undef ANA_PASSIVE

/* Boundary Conditions */
#define RADIATION_2D
#undef ANA_FSOBC
#undef ANA_M2OBC
#undef ANA_M3OBC
#undef ANA_TOBC

/* CLIMATOLOGY */
#define  M2CLIMATOLOGY      /* define 2D momentum climatology */
#define M3CLIMATOLOGY      /* define 3D momentum climatology */
#define TCLIMATOLOGY       /* define tracers climatology */
#define  M2CLM_NUDGING
#define M3CLM_NUDGING      /* nudging 3D momentum climatology */
#define TCLM_NUDGING       /* nudging tracers climatology */
#define  OBC_NUDGING


#undef ANA_GRID
#undef  ANA_INITIAL
#undef  ANA_SMFLUX

#define SOLVE3D
#ifdef SOLVE3D
# undef ANA_SEDIMENT
# define ANA_BPFLUX
# define ANA_BSFLUX
# define ANA_BTFLUX
# define ANA_SPFLUX
# undef ANA_SRFLUX
# undef ANA_SSFLUX
# undef ANA_STFLUX
#endif
#undef  ANA_VMIX
#undef  ANA_WWAVE

#define MASKING

/* Using bulk fluxes, change to sea ice one when sea ice is on */
#define BULK_FLUXES
#ifdef BULK_FLUXES
# undef ANA_TAIR
# undef ANA_PAIR
# undef ANA_HUMIDITY
# undef ANA_WINDS
# define LONGWAVE_OUT
# undef ANA_CLOUD
# undef ANA_RAIN
# define EMINUSP
#else
# undef ANA_SMFLUX
# undef ANA_STFLUX
#endif

/* Advection schemes */
#define UV_ADV
#define TS_C4VADVECTION
#define TS_A4HADVECTION 

/* Viscosity */
#define UV_VIS2
#define VISC_GRID
#define UV_COR
#define MIX_GEO_UV

/* Diffusivity */
#define TS_DIF2
#define DIFF_GRID
#define MIX_GEO_TS

/* select one of six bottom stress methods */
#define UV_LOGDRAG
#undef  UV_LDRAG
#undef  UV_QDRAG
#undef  SG_BBL
#undef  MB_BBL
#undef SSW_BBL

#ifdef SG_BBL
# undef  SG_CALC_ZNOT
# undef  SG_LOGINT
#endif
#ifdef MB_BBL
# undef  MB_CALC_ZNOT
# undef  MB_Z0BIO
# undef  MB_Z0BL
# undef  MB_Z0RIP
#endif
#ifdef SSW_BBL
# define SSW_CALC_ZNOT
# undef SSW_LOGINT
/* define one of these 2 (from test case) */
# undef SSW_LOGINT_WBL
# undef  SSW_LOGINT_DIRECT
#endif

/* turb closure - consult Dylan about this... but set up to match previous for now */
#define GLS_MIXING
#ifdef GLS_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
# define RI_SPLINES
# undef  CRAIG_BANNER
# undef  CHARNOK
# undef  ZOS_HSIG
# undef  TKE_WAVEDISS
#endif
#undef MY25_MIXING


/* Parallel Input/Output */
#undef PARALLEL_IO
#undef HDF5
#undef NETCDF4
#undef PIO_LIB


/* sediment choices */
#undef SEDIMENT
#ifdef SEDIMENT
# define SUSPLOAD
# undef  BEDLOAD_SOULSBY
# undef  BEDLOAD_MPM
# undef  BEDLOAD_VANDERA
# ifdef BEDLOAD_VANDERA
/*select any or all of these 3 (from test case) */
#  define BEDLOAD_VANDERA_ASYM_LIMITS
#  define BEDLOAD_VANDERA_SURFACE_WAVE
#  define BEDLOAD_VANDERA_WAVE_AVGD_STRESS
/*define one of these 2 (from test case) */
#  define BEDLOAD_VANDERA_MADSEN_UDELTA
#  undef  BEDLOAD_VANDERA_DIRECT_UDELTA
# endif
# define SED_MORPH
# undef  SED_SLUMP
# undef  SLOPE_KIRWAN
# undef  SLOPE_NEMETH
# undef  SLOPE_LESSER
# define SED_DENS
# define SED_MORPH
# undef  SED_BIODIFF
# undef  NONCOHESIVE_BED1
# undef  NONCOHESIVE_BED2
# define COHESIVE_BED
# undef  MIXED_BED
#endif
