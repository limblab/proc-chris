/*
 * Code generation for system model 'MuscleSpindle'
 * For more details, see corresponding source file MuscleSpindle.c
 *
 */

#ifndef RTW_HEADER_MuscleSpindle_h_
#define RTW_HEADER_MuscleSpindle_h_
#include <math.h>
#include <string.h>
#ifndef MuscleSpindle_COMMON_INCLUDES_
# define MuscleSpindle_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#endif                                 /* MuscleSpindle_COMMON_INCLUDES_ */

#include "MuscleSpindle_types.h"

/* Shared type includes */
#include "multiword_types.h"
#include "model_reference_types.h"

/* Child system includes */
#include "ContinuousDetectIncrease.h"
#include "rtGetNaN.h"
#include "rt_nonfinite.h"
#include "rtGetInf.h"

/* Block signals for system '<S2>/Secondary Afferent Calculation (eqn (8))' */
typedef struct {
  real_T ScndryAffrntCntrbtn;          /* '<S2>/Secondary Afferent Calculation (eqn (8))' */
} B_SecondaryAfferentCalculatio_T;

/* Block signals for system '<S17>/Calculate ddT (Eqn 6)' */
typedef struct {
  real_T ddT;                          /* '<S17>/Calculate ddT (Eqn 6)' */
} B_CalculateddTEqn6_MuscleSpin_T;

/* Block signals for model 'MuscleSpindle' */
typedef struct {
  real_T Divide1;                      /* '<S10>/Divide1' */
  real_T RateTransition;               /* '<S6>/Rate Transition' */
  real_T RateTransition1;              /* '<S6>/Rate Transition1' */
  real_T ddTtodT;                      /* '<S9>/ddT to dT' */
  real_T LtodL;                        /* '<S9>/L to dL' */
  real_T Divide;                       /* '<S10>/Divide' */
  real_T Divide1_k;                    /* '<S18>/Divide1' */
  real_T RateTransition_m;             /* '<S13>/Rate Transition' */
  real_T RateTransition1_h;            /* '<S13>/Rate Transition1' */
  real_T ddTtodT_o;                    /* '<S17>/ddT to dT' */
  real_T LtodL_e;                      /* '<S17>/L to dL' */
  real_T Divide_g;                     /* '<S18>/Divide' */
  real_T RateTransition_e;             /* '<S21>/Rate Transition' */
  real_T RateTransition1_l;            /* '<S21>/Rate Transition1' */
  real_T ddTtodT_c;                    /* '<S25>/ddT to dT' */
  real_T LtodL_em;                     /* '<S25>/L to dL' */
  real_T ddT;                          /* '<S9>/Calculate ddT (Eqn 6)' */
  B_CalculateddTEqn6_MuscleSpin_T sf_CalculateddTEqn6_b;/* '<S25>/Calculate ddT (Eqn 6)' */
  B_SecondaryAfferentCalculatio_T sf_SecondaryAfferentCalculati_a;/* '<S3>/Secondary Afferent Calculation (eqn (8))' */
  B_CalculateddTEqn6_MuscleSpin_T sf_CalculateddTEqn6_c;/* '<S17>/Calculate ddT (Eqn 6)' */
  B_SecondaryAfferentCalculatio_T sf_SecondaryAfferentCalculation;/* '<S2>/Secondary Afferent Calculation (eqn (8))' */
} B_MuscleSpindle_c_T;

/* Block states (auto storage) for model 'MuscleSpindle' */
typedef struct {
  real_T TimeStampA;                   /* '<S9>/L to dL' */
  real_T LastUAtTimeA;                 /* '<S9>/L to dL' */
  real_T TimeStampB;                   /* '<S9>/L to dL' */
  real_T LastUAtTimeB;                 /* '<S9>/L to dL' */
  real_T TimeStampA_a;                 /* '<S9>/dL to ddL' */
  real_T LastUAtTimeA_m;               /* '<S9>/dL to ddL' */
  real_T TimeStampB_o;                 /* '<S9>/dL to ddL' */
  real_T LastUAtTimeB_b;               /* '<S9>/dL to ddL' */
  real_T TimeStampA_g;                 /* '<S17>/L to dL' */
  real_T LastUAtTimeA_n;               /* '<S17>/L to dL' */
  real_T TimeStampB_of;                /* '<S17>/L to dL' */
  real_T LastUAtTimeB_e;               /* '<S17>/L to dL' */
  real_T TimeStampA_i;                 /* '<S17>/dL to ddL' */
  real_T LastUAtTimeA_a;               /* '<S17>/dL to ddL' */
  real_T TimeStampB_d;                 /* '<S17>/dL to ddL' */
  real_T LastUAtTimeB_k;               /* '<S17>/dL to ddL' */
  real_T TimeStampA_f;                 /* '<S25>/L to dL' */
  real_T LastUAtTimeA_l;               /* '<S25>/L to dL' */
  real_T TimeStampB_j;                 /* '<S25>/L to dL' */
  real_T LastUAtTimeB_k2;              /* '<S25>/L to dL' */
  real_T TimeStampA_m;                 /* '<S25>/dL to ddL' */
  real_T LastUAtTimeA_h;               /* '<S25>/dL to ddL' */
  real_T TimeStampB_e;                 /* '<S25>/dL to ddL' */
  real_T LastUAtTimeB_o;               /* '<S25>/dL to ddL' */
  int_T fDynamic_IWORK;                /* '<S1>/fDynamic' */
  int_T fStatic_IWORK;                 /* '<S2>/fStatic' */
  MdlrefDW_ContinuousDetectIncr_T Model_InstanceData;/* '<S6>/Model' */
  MdlrefDW_ContinuousDetectIncr_T Model_InstanceData_j;/* '<S13>/Model' */
  MdlrefDW_ContinuousDetectIncr_T Model_InstanceData_m;/* '<S21>/Model' */
} DW_MuscleSpindle_f_T;

/* Continuous states for model 'MuscleSpindle' */
typedef struct {
  real_T fDynamic_CSTATE;              /* '<S1>/fDynamic' */
  real_T dTtoT_CSTATE;                 /* '<S9>/dT to T' */
  real_T ddTtodT_CSTATE;               /* '<S9>/ddT to dT' */
  real_T fStatic_CSTATE;               /* '<S2>/fStatic' */
  real_T dTtoT_CSTATE_g;               /* '<S17>/dT to T' */
  real_T ddTtodT_CSTATE_e;             /* '<S17>/ddT to dT' */
  real_T dTtoT_CSTATE_f;               /* '<S25>/dT to T' */
  real_T ddTtodT_CSTATE_f;             /* '<S25>/ddT to dT' */
} X_MuscleSpindle_n_T;

/* State derivatives for model 'MuscleSpindle' */
typedef struct {
  real_T fDynamic_CSTATE;              /* '<S1>/fDynamic' */
  real_T dTtoT_CSTATE;                 /* '<S9>/dT to T' */
  real_T ddTtodT_CSTATE;               /* '<S9>/ddT to dT' */
  real_T fStatic_CSTATE;               /* '<S2>/fStatic' */
  real_T dTtoT_CSTATE_g;               /* '<S17>/dT to T' */
  real_T ddTtodT_CSTATE_e;             /* '<S17>/ddT to dT' */
  real_T dTtoT_CSTATE_f;               /* '<S25>/dT to T' */
  real_T ddTtodT_CSTATE_f;             /* '<S25>/ddT to dT' */
} XDot_MuscleSpindle_n_T;

/* State Disabled for model 'MuscleSpindle' */
typedef struct {
  boolean_T fDynamic_CSTATE;           /* '<S1>/fDynamic' */
  boolean_T dTtoT_CSTATE;              /* '<S9>/dT to T' */
  boolean_T ddTtodT_CSTATE;            /* '<S9>/ddT to dT' */
  boolean_T fStatic_CSTATE;            /* '<S2>/fStatic' */
  boolean_T dTtoT_CSTATE_g;            /* '<S17>/dT to T' */
  boolean_T ddTtodT_CSTATE_e;          /* '<S17>/ddT to dT' */
  boolean_T dTtoT_CSTATE_f;            /* '<S25>/dT to T' */
  boolean_T ddTtodT_CSTATE_f;          /* '<S25>/ddT to dT' */
} XDis_MuscleSpindle_n_T;

/* Invariant block signals for model 'MuscleSpindle' */
typedef struct {
  const real_T Square1;                /* '<S10>/Square1' */
  const real_T Subtract1;              /* '<S8>/Subtract1' */
  const real_T Square1_n;              /* '<S18>/Square1' */
  const real_T Subtract1_a;            /* '<S15>/Subtract1' */
  const real_T Square1_m;              /* '<S26>/Square1' */
  const real_T Subtract1_d;            /* '<S23>/Subtract1' */
} ConstB_MuscleSpindle_h_T;

/* Real-time Model Data Structure */
struct tag_RTM_MuscleSpindle_T {
  const char_T **errorStatus;
  RTWSolverInfo *solverInfo;
  const rtTimingBridge *timingBridge;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    time_T stepSize0;
    int_T mdlref_GlobalTID[2];
    SimTimeStep *simTimeStep;
    boolean_T *stopRequestedFlag;
  } Timing;
};

typedef struct {
  B_MuscleSpindle_c_T rtb;
  DW_MuscleSpindle_f_T rtdw;
  RT_MODEL_MuscleSpindle_T rtm;
} MdlrefDW_MuscleSpindle_T;

/* Model reference registration function */
extern void MuscleSpindle_initialize(const char_T **rt_errorStatus, boolean_T
  *rt_stopRequested, RTWSolverInfo *rt_solverInfo, const rtTimingBridge
  *timingBridge, int_T mdlref_TID0, int_T mdlref_TID1, RT_MODEL_MuscleSpindle_T *
  const MuscleSpindle_M, B_MuscleSpindle_c_T *localB, DW_MuscleSpindle_f_T
  *localDW);
extern void SecondaryAfferentCalculationeqn(real_T rtu_Gsnd, real_T rtu_T,
  real_T rtu_Ksr, real_T rtu_X, real_T rtu_Lsnd, real_T rtu_Lsr0, real_T
  rtu_LsrN, real_T rtu_Lpr0, real_T rtu_LprN, const real_T *rtu_L,
  B_SecondaryAfferentCalculatio_T *localB);
extern void MuscleSpindle_CalculateddTEqn6(real_T rtu_dT, real_T rtu_T, const
  real_T *rtu_L, real_T rtu_dL, real_T rtu_ddL, real_T rtu_Lsr0, real_T rtu_Ksr,
  real_T rtu_M, real_T rtu_C, real_T rtu_Beta, real_T rtu_a, real_T rtu_R,
  real_T rtu_Kpr, real_T rtu_Lpr0, real_T rtu_Gamma,
  B_CalculateddTEqn6_MuscleSpin_T *localB);
extern void MuscleSpindle_Init(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M,
  DW_MuscleSpindle_f_T *localDW, X_MuscleSpindle_n_T *localX);
extern void MuscleSpindle_Reset(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M,
  DW_MuscleSpindle_f_T *localDW, X_MuscleSpindle_n_T *localX);
extern void MuscleSpindle_Deriv(B_MuscleSpindle_c_T *localB,
  XDot_MuscleSpindle_n_T *localXdot);
extern void MuscleSpindle_Update(RT_MODEL_MuscleSpindle_T * const
  MuscleSpindle_M, const real_T *rtu_FascicleLength, B_MuscleSpindle_c_T *localB,
  DW_MuscleSpindle_f_T *localDW);
extern void MuscleSpindle(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M,
  const real_T *rtu_FascicleLength, const real_T *rtu_DynamicFusimotor, const
  real_T *rtu_StaticFusimotor, real_T *rty_PrimaryAfferent, real_T
  *rty_SecondaryAfferent, B_MuscleSpindle_c_T *localB, DW_MuscleSpindle_f_T
  *localDW, X_MuscleSpindle_n_T *localX);

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'MuscleSpindle'
 * '<S1>'   : 'MuscleSpindle/Bag1'
 * '<S2>'   : 'MuscleSpindle/Bag2'
 * '<S3>'   : 'MuscleSpindle/Chain'
 * '<S4>'   : 'MuscleSpindle/Partial Occlusion Effect'
 * '<S5>'   : 'MuscleSpindle/Bag1/Beta Calculation (Eqn 4)'
 * '<S6>'   : 'MuscleSpindle/Bag1/Coef of asymmetry (C)'
 * '<S7>'   : 'MuscleSpindle/Bag1/Gamma Calculation (Eqn 5)'
 * '<S8>'   : 'MuscleSpindle/Bag1/Primary Afferent Calculation (eqn (7))'
 * '<S9>'   : 'MuscleSpindle/Bag1/Tension (T) Calculation '
 * '<S10>'  : 'MuscleSpindle/Bag1/dfDynamic (Eqn 1, P=2)'
 * '<S11>'  : 'MuscleSpindle/Bag1/Tension (T) Calculation /Calculate ddT (Eqn 6)'
 * '<S12>'  : 'MuscleSpindle/Bag2/Beta Calculation (Eqn 4)'
 * '<S13>'  : 'MuscleSpindle/Bag2/Coef of asymmetry (C)'
 * '<S14>'  : 'MuscleSpindle/Bag2/Gamma Calculation (Eqn 5)'
 * '<S15>'  : 'MuscleSpindle/Bag2/Primary Afferent Calculation (eqn (7))'
 * '<S16>'  : 'MuscleSpindle/Bag2/Secondary Afferent Calculation (eqn (8))'
 * '<S17>'  : 'MuscleSpindle/Bag2/Tension (T) Calculation '
 * '<S18>'  : 'MuscleSpindle/Bag2/dfDynamic (Eqn 1, P=2)'
 * '<S19>'  : 'MuscleSpindle/Bag2/Tension (T) Calculation /Calculate ddT (Eqn 6)'
 * '<S20>'  : 'MuscleSpindle/Chain/Beta Calculation (Eqn 4)'
 * '<S21>'  : 'MuscleSpindle/Chain/Coef of asymmetry (C)'
 * '<S22>'  : 'MuscleSpindle/Chain/Gamma Calculation (Eqn 5)'
 * '<S23>'  : 'MuscleSpindle/Chain/Primary Afferent Calculation (eqn (7))'
 * '<S24>'  : 'MuscleSpindle/Chain/Secondary Afferent Calculation (eqn (8))'
 * '<S25>'  : 'MuscleSpindle/Chain/Tension (T) Calculation '
 * '<S26>'  : 'MuscleSpindle/Chain/dfDynamic (Eqn 1, P=2)'
 * '<S27>'  : 'MuscleSpindle/Chain/Tension (T) Calculation /Calculate ddT (Eqn 6)'
 */
#endif                                 /* RTW_HEADER_MuscleSpindle_h_ */
