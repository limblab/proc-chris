/*
 * MuscleSpindleGUIModel.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "MuscleSpindleGUIModel".
 *
 * Model version              : 1.174
 * Simulink Coder version : 8.13 (R2017b) 24-Jul-2017
 * C source code generated on : Wed Apr 29 11:34:39 2020
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: 32-bit Generic
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_MuscleSpindleGUIModel_h_
#define RTW_HEADER_MuscleSpindleGUIModel_h_
#include <string.h>
#include <float.h>
#include <stddef.h>
#ifndef MuscleSpindleGUIModel_COMMON_INCLUDES_
# define MuscleSpindleGUIModel_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "rt_logging.h"
#endif                                 /* MuscleSpindleGUIModel_COMMON_INCLUDES_ */

#include "MuscleSpindleGUIModel_types.h"

/* Shared type includes */
#include "multiword_types.h"
#include "model_reference_types.h"

/* Child system includes */
#include "MuscleSpindle.h"
#include "rt_nonfinite.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetContStateDisabled
# define rtmGetContStateDisabled(rtm)  ((rtm)->contStateDisabled)
#endif

#ifndef rtmSetContStateDisabled
# define rtmSetContStateDisabled(rtm, val) ((rtm)->contStateDisabled = (val))
#endif

#ifndef rtmGetContStates
# define rtmGetContStates(rtm)         ((rtm)->contStates)
#endif

#ifndef rtmSetContStates
# define rtmSetContStates(rtm, val)    ((rtm)->contStates = (val))
#endif

#ifndef rtmGetContTimeOutputInconsistentWithStateAtMajorStepFlag
# define rtmGetContTimeOutputInconsistentWithStateAtMajorStepFlag(rtm) ((rtm)->CTOutputIncnstWithState)
#endif

#ifndef rtmSetContTimeOutputInconsistentWithStateAtMajorStepFlag
# define rtmSetContTimeOutputInconsistentWithStateAtMajorStepFlag(rtm, val) ((rtm)->CTOutputIncnstWithState = (val))
#endif

#ifndef rtmGetDerivCacheNeedsReset
# define rtmGetDerivCacheNeedsReset(rtm) ((rtm)->derivCacheNeedsReset)
#endif

#ifndef rtmSetDerivCacheNeedsReset
# define rtmSetDerivCacheNeedsReset(rtm, val) ((rtm)->derivCacheNeedsReset = (val))
#endif

#ifndef rtmGetFinalTime
# define rtmGetFinalTime(rtm)          ((rtm)->Timing.tFinal)
#endif

#ifndef rtmGetIntgData
# define rtmGetIntgData(rtm)           ((rtm)->intgData)
#endif

#ifndef rtmSetIntgData
# define rtmSetIntgData(rtm, val)      ((rtm)->intgData = (val))
#endif

#ifndef rtmGetOdeF
# define rtmGetOdeF(rtm)               ((rtm)->odeF)
#endif

#ifndef rtmSetOdeF
# define rtmSetOdeF(rtm, val)          ((rtm)->odeF = (val))
#endif

#ifndef rtmGetOdeY
# define rtmGetOdeY(rtm)               ((rtm)->odeY)
#endif

#ifndef rtmSetOdeY
# define rtmSetOdeY(rtm, val)          ((rtm)->odeY = (val))
#endif

#ifndef rtmGetPeriodicContStateIndices
# define rtmGetPeriodicContStateIndices(rtm) ((rtm)->periodicContStateIndices)
#endif

#ifndef rtmSetPeriodicContStateIndices
# define rtmSetPeriodicContStateIndices(rtm, val) ((rtm)->periodicContStateIndices = (val))
#endif

#ifndef rtmGetPeriodicContStateRanges
# define rtmGetPeriodicContStateRanges(rtm) ((rtm)->periodicContStateRanges)
#endif

#ifndef rtmSetPeriodicContStateRanges
# define rtmSetPeriodicContStateRanges(rtm, val) ((rtm)->periodicContStateRanges = (val))
#endif

#ifndef rtmGetRTWLogInfo
# define rtmGetRTWLogInfo(rtm)         ((rtm)->rtwLogInfo)
#endif

#ifndef rtmGetZCCacheNeedsReset
# define rtmGetZCCacheNeedsReset(rtm)  ((rtm)->zCCacheNeedsReset)
#endif

#ifndef rtmSetZCCacheNeedsReset
# define rtmSetZCCacheNeedsReset(rtm, val) ((rtm)->zCCacheNeedsReset = (val))
#endif

#ifndef rtmGetdX
# define rtmGetdX(rtm)                 ((rtm)->derivs)
#endif

#ifndef rtmSetdX
# define rtmSetdX(rtm, val)            ((rtm)->derivs = (val))
#endif

#ifndef rtmGetErrorStatus
# define rtmGetErrorStatus(rtm)        ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
# define rtmSetErrorStatus(rtm, val)   ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetErrorStatusPointer
# define rtmGetErrorStatusPointer(rtm) ((const char_T **)(&((rtm)->errorStatus)))
#endif

#ifndef rtmGetStopRequested
# define rtmGetStopRequested(rtm)      ((rtm)->Timing.stopRequestedFlag)
#endif

#ifndef rtmSetStopRequested
# define rtmSetStopRequested(rtm, val) ((rtm)->Timing.stopRequestedFlag = (val))
#endif

#ifndef rtmGetStopRequestedPtr
# define rtmGetStopRequestedPtr(rtm)   (&((rtm)->Timing.stopRequestedFlag))
#endif

#ifndef rtmGetT
# define rtmGetT(rtm)                  (rtmGetTPtr((rtm))[0])
#endif

#ifndef rtmGetTFinal
# define rtmGetTFinal(rtm)             ((rtm)->Timing.tFinal)
#endif

/* Block signals (auto storage) */
typedef struct {
  real_T Integrator;                   /* '<Root>/Integrator' */
  real_T Model_o1;                     /* '<Root>/Model' */
  real_T Model_o2;                     /* '<Root>/Model' */
  real_T FilterCoefficient;            /* '<S1>/Filter Coefficient' */
  real_T IntegralGain;                 /* '<S1>/Integral Gain' */
  real_T Sum;                          /* '<S1>/Sum' */
} B_MuscleSpindleGUIModel_T;

/* Block states (auto storage) for system '<Root>' */
typedef struct {
  int_T Integrator_IWORK;              /* '<Root>/Integrator' */
  MdlrefDW_MuscleSpindle_T Model_InstanceData;/* '<Root>/Model' */
} DW_MuscleSpindleGUIModel_T;

/* Continuous states (auto storage) */
typedef struct {
  real_T Integrator_CSTATE;            /* '<Root>/Integrator' */
  X_MuscleSpindle_n_T Model_CSTATE;    /* '<Root>/Model' */
  real_T Filter_CSTATE;                /* '<S1>/Filter' */
  real_T Integrator_CSTATE_m;          /* '<S1>/Integrator' */
} X_MuscleSpindleGUIModel_T;

/* State derivatives (auto storage) */
typedef struct {
  real_T Integrator_CSTATE;            /* '<Root>/Integrator' */
  XDot_MuscleSpindle_n_T Model_CSTATE; /* '<Root>/Model' */
  real_T Filter_CSTATE;                /* '<S1>/Filter' */
  real_T Integrator_CSTATE_m;          /* '<S1>/Integrator' */
} XDot_MuscleSpindleGUIModel_T;

/* State disabled  */
typedef struct {
  boolean_T Integrator_CSTATE;         /* '<Root>/Integrator' */
  XDis_MuscleSpindle_n_T Model_CSTATE; /* '<Root>/Model' */
  boolean_T Filter_CSTATE;             /* '<S1>/Filter' */
  boolean_T Integrator_CSTATE_m;       /* '<S1>/Integrator' */
} XDis_MuscleSpindleGUIModel_T;

#ifndef ODE3_INTG
#define ODE3_INTG

/* ODE3 Integration Data */
typedef struct {
  real_T *y;                           /* output */
  real_T *f[3];                        /* derivatives */
} ODE3_IntgData;

#endif

/* External inputs (root inport signals with auto storage) */
typedef struct {
  real_T MuscleLen;                    /* '<Root>/MuscleLen' */
  real_T DynGam;                       /* '<Root>/DynGam' */
  real_T StatGam;                      /* '<Root>/StatGam' */
} ExtU_MuscleSpindleGUIModel_T;

/* External outputs (root outports fed by signals with auto storage) */
typedef struct {
  real_T Primary;                      /* '<Root>/Primary' */
  real_T Secondary;                    /* '<Root>/Secondary' */
} ExtY_MuscleSpindleGUIModel_T;

/* Parameters (auto storage) */
struct P_MuscleSpindleGUIModel_T_ {
  real_T PIDController_D;              /* Mask Parameter: PIDController_D
                                        * Referenced by: '<S1>/Derivative Gain'
                                        */
  real_T PIDController_I;              /* Mask Parameter: PIDController_I
                                        * Referenced by: '<S1>/Integral Gain'
                                        */
  real_T PIDController_N;              /* Mask Parameter: PIDController_N
                                        * Referenced by: '<S1>/Filter Coefficient'
                                        */
  real_T PIDController_P;              /* Mask Parameter: PIDController_P
                                        * Referenced by: '<S1>/Proportional Gain'
                                        */
  real_T Filter_IC;                    /* Expression: InitialConditionForFilter
                                        * Referenced by: '<S1>/Filter'
                                        */
  real_T Integrator_IC;                /* Expression: InitialConditionForIntegrator
                                        * Referenced by: '<S1>/Integrator'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_MuscleSpindleGUIModel_T {
  const char_T *errorStatus;
  RTWLogInfo *rtwLogInfo;
  RTWSolverInfo solverInfo;
  X_MuscleSpindleGUIModel_T *contStates;
  int_T *periodicContStateIndices;
  real_T *periodicContStateRanges;
  real_T *derivs;
  boolean_T *contStateDisabled;
  boolean_T zCCacheNeedsReset;
  boolean_T derivCacheNeedsReset;
  boolean_T CTOutputIncnstWithState;
  real_T odeY[11];
  real_T odeF[3][11];
  ODE3_IntgData intgData;

  /*
   * Sizes:
   * The following substructure contains sizes information
   * for many of the model attributes such as inputs, outputs,
   * dwork, sample times, etc.
   */
  struct {
    int_T numContStates;
    int_T numPeriodicContStates;
    int_T numSampTimes;
  } Sizes;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    uint32_T clockTickH0;
    time_T stepSize0;
    uint32_T clockTick1;
    uint32_T clockTickH1;
    boolean_T firstInitCondFlag;
    time_T tFinal;
    SimTimeStep simTimeStep;
    boolean_T stopRequestedFlag;
    time_T *t;
    time_T tArray[2];
  } Timing;
};

/* Block parameters (auto storage) */
extern P_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_P;

/* Block signals (auto storage) */
extern B_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_B;

/* Continuous states (auto storage) */
extern X_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_X;

/* Block states (auto storage) */
extern DW_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_DW;

/* External inputs (root inport signals with auto storage) */
extern ExtU_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_U;

/* External outputs (root outports fed by signals with auto storage) */
extern ExtY_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_Y;

/* Model entry point functions */
extern void MuscleSpindleGUIModel_initialize(void);
extern void MuscleSpindleGUIModel_step(void);
extern void MuscleSpindleGUIModel_terminate(void);

/* Real-time Model object */
extern RT_MODEL_MuscleSpindleGUIMode_T *const MuscleSpindleGUIModel_M;

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
 * '<Root>' : 'MuscleSpindleGUIModel'
 * '<S1>'   : 'MuscleSpindleGUIModel/PID Controller'
 */
#endif                                 /* RTW_HEADER_MuscleSpindleGUIModel_h_ */
