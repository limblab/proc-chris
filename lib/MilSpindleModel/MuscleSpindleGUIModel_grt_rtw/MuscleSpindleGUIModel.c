/*
 * MuscleSpindleGUIModel.c
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

#include "MuscleSpindleGUIModel.h"
#include "MuscleSpindleGUIModel_private.h"

rtTimingBridge MuscleSpindleGUIMode_TimingBrdg;

/* Block signals (auto storage) */
B_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_B;

/* Continuous states */
X_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_X;

/* Block states (auto storage) */
DW_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_DW;

/* External inputs (root inport signals with auto storage) */
ExtU_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_U;

/* External outputs (root outports fed by signals with auto storage) */
ExtY_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_Y;

/* Real-time model */
RT_MODEL_MuscleSpindleGUIMode_T MuscleSpindleGUIModel_M_;
RT_MODEL_MuscleSpindleGUIMode_T *const MuscleSpindleGUIModel_M =
  &MuscleSpindleGUIModel_M_;

/*
 * This function updates continuous states using the ODE3 fixed-step
 * solver algorithm
 */
static void rt_ertODEUpdateContinuousStates(RTWSolverInfo *si )
{
  /* Solver Matrices */
  static const real_T rt_ODE3_A[3] = {
    1.0/2.0, 3.0/4.0, 1.0
  };

  static const real_T rt_ODE3_B[3][3] = {
    { 1.0/2.0, 0.0, 0.0 },

    { 0.0, 3.0/4.0, 0.0 },

    { 2.0/9.0, 1.0/3.0, 4.0/9.0 }
  };

  time_T t = rtsiGetT(si);
  time_T tnew = rtsiGetSolverStopTime(si);
  time_T h = rtsiGetStepSize(si);
  real_T *x = rtsiGetContStates(si);
  ODE3_IntgData *id = (ODE3_IntgData *)rtsiGetSolverData(si);
  real_T *y = id->y;
  real_T *f0 = id->f[0];
  real_T *f1 = id->f[1];
  real_T *f2 = id->f[2];
  real_T hB[3];
  int_T i;
  int_T nXc = 11;
  rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

  /* Save the state values at time t in y, we'll use x as ynew. */
  (void) memcpy(y, x,
                (uint_T)nXc*sizeof(real_T));

  /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
  /* f0 = f(t,y) */
  rtsiSetdX(si, f0);
  MuscleSpindleGUIModel_derivatives();

  /* f(:,2) = feval(odefile, t + hA(1), y + f*hB(:,1), args(:)(*)); */
  hB[0] = h * rt_ODE3_B[0][0];
  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0]);
  }

  rtsiSetT(si, t + h*rt_ODE3_A[0]);
  rtsiSetdX(si, f1);
  MuscleSpindleGUIModel_step();
  MuscleSpindleGUIModel_derivatives();

  /* f(:,3) = feval(odefile, t + hA(2), y + f*hB(:,2), args(:)(*)); */
  for (i = 0; i <= 1; i++) {
    hB[i] = h * rt_ODE3_B[1][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1]);
  }

  rtsiSetT(si, t + h*rt_ODE3_A[1]);
  rtsiSetdX(si, f2);
  MuscleSpindleGUIModel_step();
  MuscleSpindleGUIModel_derivatives();

  /* tnew = t + hA(3);
     ynew = y + f*hB(:,3); */
  for (i = 0; i <= 2; i++) {
    hB[i] = h * rt_ODE3_B[2][i];
  }

  for (i = 0; i < nXc; i++) {
    x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2]);
  }

  rtsiSetT(si, tnew);
  rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

/* Model step function */
void MuscleSpindleGUIModel_step(void)
{
  real_T rtb_Subtract;
  if (rtmIsMajorTimeStep(MuscleSpindleGUIModel_M)) {
    /* set solver stop time */
    if (!(MuscleSpindleGUIModel_M->Timing.clockTick0+1)) {
      rtsiSetSolverStopTime(&MuscleSpindleGUIModel_M->solverInfo,
                            ((MuscleSpindleGUIModel_M->Timing.clockTickH0 + 1) *
        MuscleSpindleGUIModel_M->Timing.stepSize0 * 4294967296.0));
    } else {
      rtsiSetSolverStopTime(&MuscleSpindleGUIModel_M->solverInfo,
                            ((MuscleSpindleGUIModel_M->Timing.clockTick0 + 1) *
        MuscleSpindleGUIModel_M->Timing.stepSize0 +
        MuscleSpindleGUIModel_M->Timing.clockTickH0 *
        MuscleSpindleGUIModel_M->Timing.stepSize0 * 4294967296.0));
    }
  }                                    /* end MajorTimeStep */

  /* Update absolute time of base rate at minor time step */
  if (rtmIsMinorTimeStep(MuscleSpindleGUIModel_M)) {
    MuscleSpindleGUIModel_M->Timing.t[0] = rtsiGetT
      (&MuscleSpindleGUIModel_M->solverInfo);
  }

  /* Integrator: '<Root>/Integrator' incorporates:
   *  Inport: '<Root>/MuscleLen'
   */
  if (MuscleSpindleGUIModel_DW.Integrator_IWORK != 0) {
    MuscleSpindleGUIModel_X.Integrator_CSTATE =
      MuscleSpindleGUIModel_U.MuscleLen;
  }

  MuscleSpindleGUIModel_B.Integrator = MuscleSpindleGUIModel_X.Integrator_CSTATE;

  /* End of Integrator: '<Root>/Integrator' */

  /* ModelReference: '<Root>/Model' incorporates:
   *  Inport: '<Root>/DynGam'
   *  Inport: '<Root>/StatGam'
   */
  MuscleSpindle(&(MuscleSpindleGUIModel_DW.Model_InstanceData.rtm),
                &MuscleSpindleGUIModel_B.Integrator,
                &MuscleSpindleGUIModel_U.DynGam,
                &MuscleSpindleGUIModel_U.StatGam,
                &MuscleSpindleGUIModel_B.Model_o1,
                &MuscleSpindleGUIModel_B.Model_o2,
                &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtb),
                &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtdw),
                &(MuscleSpindleGUIModel_X.Model_CSTATE));

  /* Outport: '<Root>/Primary' */
  MuscleSpindleGUIModel_Y.Primary = MuscleSpindleGUIModel_B.Model_o1;

  /* Outport: '<Root>/Secondary' */
  MuscleSpindleGUIModel_Y.Secondary = MuscleSpindleGUIModel_B.Model_o2;

  /* Sum: '<Root>/Subtract' incorporates:
   *  Inport: '<Root>/MuscleLen'
   */
  rtb_Subtract = MuscleSpindleGUIModel_U.MuscleLen -
    MuscleSpindleGUIModel_B.Integrator;

  /* Gain: '<S1>/Filter Coefficient' incorporates:
   *  Gain: '<S1>/Derivative Gain'
   *  Integrator: '<S1>/Filter'
   *  Sum: '<S1>/SumD'
   */
  MuscleSpindleGUIModel_B.FilterCoefficient =
    (MuscleSpindleGUIModel_P.PIDController_D * rtb_Subtract -
     MuscleSpindleGUIModel_X.Filter_CSTATE) *
    MuscleSpindleGUIModel_P.PIDController_N;

  /* Gain: '<S1>/Integral Gain' */
  MuscleSpindleGUIModel_B.IntegralGain = MuscleSpindleGUIModel_P.PIDController_I
    * rtb_Subtract;

  /* Sum: '<S1>/Sum' incorporates:
   *  Gain: '<S1>/Proportional Gain'
   *  Integrator: '<S1>/Integrator'
   */
  MuscleSpindleGUIModel_B.Sum = (MuscleSpindleGUIModel_P.PIDController_P *
    rtb_Subtract + MuscleSpindleGUIModel_X.Integrator_CSTATE_m) +
    MuscleSpindleGUIModel_B.FilterCoefficient;
  if (rtmIsMajorTimeStep(MuscleSpindleGUIModel_M)) {
    /* Matfile logging */
    rt_UpdateTXYLogVars(MuscleSpindleGUIModel_M->rtwLogInfo,
                        (MuscleSpindleGUIModel_M->Timing.t));
  }                                    /* end MajorTimeStep */

  if (rtmIsMajorTimeStep(MuscleSpindleGUIModel_M)) {
    /* Update for Integrator: '<Root>/Integrator' */
    MuscleSpindleGUIModel_DW.Integrator_IWORK = 0;

    /* Update for ModelReference: '<Root>/Model' incorporates:
     *  Inport: '<Root>/DynGam'
     *  Inport: '<Root>/StatGam'
     */
    MuscleSpindle_Update(&(MuscleSpindleGUIModel_DW.Model_InstanceData.rtm),
                         &MuscleSpindleGUIModel_B.Integrator,
                         &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtb),
                         &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtdw));
  }                                    /* end MajorTimeStep */

  if (rtmIsMajorTimeStep(MuscleSpindleGUIModel_M)) {
    /* signal main to stop simulation */
    {                                  /* Sample time: [0.0s, 0.0s] */
      if ((rtmGetTFinal(MuscleSpindleGUIModel_M)!=-1) &&
          !((rtmGetTFinal(MuscleSpindleGUIModel_M)-
             (((MuscleSpindleGUIModel_M->Timing.clockTick1+
                MuscleSpindleGUIModel_M->Timing.clockTickH1* 4294967296.0)) *
              0.001)) > (((MuscleSpindleGUIModel_M->Timing.clockTick1+
                           MuscleSpindleGUIModel_M->Timing.clockTickH1*
                           4294967296.0)) * 0.001) * (DBL_EPSILON))) {
        rtmSetErrorStatus(MuscleSpindleGUIModel_M, "Simulation finished");
      }
    }

    rt_ertODEUpdateContinuousStates(&MuscleSpindleGUIModel_M->solverInfo);

    /* Update absolute time for base rate */
    /* The "clockTick0" counts the number of times the code of this task has
     * been executed. The absolute time is the multiplication of "clockTick0"
     * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
     * overflow during the application lifespan selected.
     * Timer of this task consists of two 32 bit unsigned integers.
     * The two integers represent the low bits Timing.clockTick0 and the high bits
     * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
     */
    if (!(++MuscleSpindleGUIModel_M->Timing.clockTick0)) {
      ++MuscleSpindleGUIModel_M->Timing.clockTickH0;
    }

    MuscleSpindleGUIModel_M->Timing.t[0] = rtsiGetSolverStopTime
      (&MuscleSpindleGUIModel_M->solverInfo);

    {
      /* Update absolute timer for sample time: [0.001s, 0.0s] */
      /* The "clockTick1" counts the number of times the code of this task has
       * been executed. The resolution of this integer timer is 0.001, which is the step size
       * of the task. Size of "clockTick1" ensures timer will not overflow during the
       * application lifespan selected.
       * Timer of this task consists of two 32 bit unsigned integers.
       * The two integers represent the low bits Timing.clockTick1 and the high bits
       * Timing.clockTickH1. When the low bit overflows to 0, the high bits increment.
       */
      MuscleSpindleGUIModel_M->Timing.clockTick1++;
      if (!MuscleSpindleGUIModel_M->Timing.clockTick1) {
        MuscleSpindleGUIModel_M->Timing.clockTickH1++;
      }
    }
  }                                    /* end MajorTimeStep */
}

/* Derivatives for root system: '<Root>' */
void MuscleSpindleGUIModel_derivatives(void)
{
  XDot_MuscleSpindleGUIModel_T *_rtXdot;
  _rtXdot = ((XDot_MuscleSpindleGUIModel_T *) MuscleSpindleGUIModel_M->derivs);

  /* Derivatives for Integrator: '<Root>/Integrator' */
  _rtXdot->Integrator_CSTATE = MuscleSpindleGUIModel_B.Sum;

  /* Derivatives for ModelReference: '<Root>/Model' incorporates:
   *  Inport: '<Root>/DynGam'
   *  Inport: '<Root>/StatGam'
   */
  MuscleSpindle_Deriv(&(MuscleSpindleGUIModel_DW.Model_InstanceData.rtb),
                      &(((XDot_MuscleSpindleGUIModel_T *)
    MuscleSpindleGUIModel_M->derivs)->Model_CSTATE));

  /* Derivatives for Integrator: '<S1>/Filter' */
  _rtXdot->Filter_CSTATE = MuscleSpindleGUIModel_B.FilterCoefficient;

  /* Derivatives for Integrator: '<S1>/Integrator' */
  _rtXdot->Integrator_CSTATE_m = MuscleSpindleGUIModel_B.IntegralGain;
}

/* Model initialize function */
void MuscleSpindleGUIModel_initialize(void)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)MuscleSpindleGUIModel_M, 0,
                sizeof(RT_MODEL_MuscleSpindleGUIMode_T));

  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&MuscleSpindleGUIModel_M->solverInfo,
                          &MuscleSpindleGUIModel_M->Timing.simTimeStep);
    rtsiSetTPtr(&MuscleSpindleGUIModel_M->solverInfo, &rtmGetTPtr
                (MuscleSpindleGUIModel_M));
    rtsiSetStepSizePtr(&MuscleSpindleGUIModel_M->solverInfo,
                       &MuscleSpindleGUIModel_M->Timing.stepSize0);
    rtsiSetdXPtr(&MuscleSpindleGUIModel_M->solverInfo,
                 &MuscleSpindleGUIModel_M->derivs);
    rtsiSetContStatesPtr(&MuscleSpindleGUIModel_M->solverInfo, (real_T **)
                         &MuscleSpindleGUIModel_M->contStates);
    rtsiSetNumContStatesPtr(&MuscleSpindleGUIModel_M->solverInfo,
      &MuscleSpindleGUIModel_M->Sizes.numContStates);
    rtsiSetNumPeriodicContStatesPtr(&MuscleSpindleGUIModel_M->solverInfo,
      &MuscleSpindleGUIModel_M->Sizes.numPeriodicContStates);
    rtsiSetPeriodicContStateIndicesPtr(&MuscleSpindleGUIModel_M->solverInfo,
      &MuscleSpindleGUIModel_M->periodicContStateIndices);
    rtsiSetPeriodicContStateRangesPtr(&MuscleSpindleGUIModel_M->solverInfo,
      &MuscleSpindleGUIModel_M->periodicContStateRanges);
    rtsiSetErrorStatusPtr(&MuscleSpindleGUIModel_M->solverInfo,
                          (&rtmGetErrorStatus(MuscleSpindleGUIModel_M)));
    rtsiSetRTModelPtr(&MuscleSpindleGUIModel_M->solverInfo,
                      MuscleSpindleGUIModel_M);
  }

  rtsiSetSimTimeStep(&MuscleSpindleGUIModel_M->solverInfo, MAJOR_TIME_STEP);
  MuscleSpindleGUIModel_M->intgData.y = MuscleSpindleGUIModel_M->odeY;
  MuscleSpindleGUIModel_M->intgData.f[0] = MuscleSpindleGUIModel_M->odeF[0];
  MuscleSpindleGUIModel_M->intgData.f[1] = MuscleSpindleGUIModel_M->odeF[1];
  MuscleSpindleGUIModel_M->intgData.f[2] = MuscleSpindleGUIModel_M->odeF[2];
  MuscleSpindleGUIModel_M->contStates = ((X_MuscleSpindleGUIModel_T *)
    &MuscleSpindleGUIModel_X);
  rtsiSetSolverData(&MuscleSpindleGUIModel_M->solverInfo, (void *)
                    &MuscleSpindleGUIModel_M->intgData);
  rtsiSetSolverName(&MuscleSpindleGUIModel_M->solverInfo,"ode3");
  rtmSetTPtr(MuscleSpindleGUIModel_M, &MuscleSpindleGUIModel_M->Timing.tArray[0]);
  rtmSetTFinal(MuscleSpindleGUIModel_M, -1);
  MuscleSpindleGUIModel_M->Timing.stepSize0 = 0.001;
  rtmSetFirstInitCond(MuscleSpindleGUIModel_M, 1);

  /* Setup for data logging */
  {
    static RTWLogInfo rt_DataLoggingInfo;
    rt_DataLoggingInfo.loggingInterval = NULL;
    MuscleSpindleGUIModel_M->rtwLogInfo = &rt_DataLoggingInfo;
  }

  /* Setup for data logging */
  {
    rtliSetLogXSignalInfo(MuscleSpindleGUIModel_M->rtwLogInfo, (NULL));
    rtliSetLogXSignalPtrs(MuscleSpindleGUIModel_M->rtwLogInfo, (NULL));
    rtliSetLogT(MuscleSpindleGUIModel_M->rtwLogInfo, "tout");
    rtliSetLogX(MuscleSpindleGUIModel_M->rtwLogInfo, "");
    rtliSetLogXFinal(MuscleSpindleGUIModel_M->rtwLogInfo, "");
    rtliSetLogVarNameModifier(MuscleSpindleGUIModel_M->rtwLogInfo, "rt_");
    rtliSetLogFormat(MuscleSpindleGUIModel_M->rtwLogInfo, 0);
    rtliSetLogMaxRows(MuscleSpindleGUIModel_M->rtwLogInfo, 1000);
    rtliSetLogDecimation(MuscleSpindleGUIModel_M->rtwLogInfo, 1);

    /*
     * Set pointers to the data and signal info for each output
     */
    {
      static void * rt_LoggedOutputSignalPtrs[] = {
        &MuscleSpindleGUIModel_Y.Primary,
        &MuscleSpindleGUIModel_Y.Secondary
      };

      rtliSetLogYSignalPtrs(MuscleSpindleGUIModel_M->rtwLogInfo,
                            ((LogSignalPtrsType)rt_LoggedOutputSignalPtrs));
    }

    {
      static int_T rt_LoggedOutputWidths[] = {
        1,
        1
      };

      static int_T rt_LoggedOutputNumDimensions[] = {
        1,
        1
      };

      static int_T rt_LoggedOutputDimensions[] = {
        1,
        1
      };

      static boolean_T rt_LoggedOutputIsVarDims[] = {
        0,
        0
      };

      static void* rt_LoggedCurrentSignalDimensions[] = {
        (NULL),
        (NULL)
      };

      static int_T rt_LoggedCurrentSignalDimensionsSize[] = {
        4,
        4
      };

      static BuiltInDTypeId rt_LoggedOutputDataTypeIds[] = {
        SS_DOUBLE,
        SS_DOUBLE
      };

      static int_T rt_LoggedOutputComplexSignals[] = {
        0,
        0
      };

      static RTWPreprocessingFcnPtr rt_LoggingPreprocessingFcnPtrs[] = {
        (NULL),
        (NULL)
      };

      static const char_T *rt_LoggedOutputLabels[] = {
        "",
        "" };

      static const char_T *rt_LoggedOutputBlockNames[] = {
        "MuscleSpindleGUIModel/Primary",
        "MuscleSpindleGUIModel/Secondary" };

      static RTWLogDataTypeConvert rt_RTWLogDataTypeConvert[] = {
        { 0, SS_DOUBLE, SS_DOUBLE, 0, 0, 0, 1.0, 0, 0.0 },

        { 0, SS_DOUBLE, SS_DOUBLE, 0, 0, 0, 1.0, 0, 0.0 }
      };

      static RTWLogSignalInfo rt_LoggedOutputSignalInfo[] = {
        {
          2,
          rt_LoggedOutputWidths,
          rt_LoggedOutputNumDimensions,
          rt_LoggedOutputDimensions,
          rt_LoggedOutputIsVarDims,
          rt_LoggedCurrentSignalDimensions,
          rt_LoggedCurrentSignalDimensionsSize,
          rt_LoggedOutputDataTypeIds,
          rt_LoggedOutputComplexSignals,
          (NULL),
          rt_LoggingPreprocessingFcnPtrs,

          { rt_LoggedOutputLabels },
          (NULL),
          (NULL),
          (NULL),

          { rt_LoggedOutputBlockNames },

          { (NULL) },
          (NULL),
          rt_RTWLogDataTypeConvert
        }
      };

      rtliSetLogYSignalInfo(MuscleSpindleGUIModel_M->rtwLogInfo,
                            rt_LoggedOutputSignalInfo);

      /* set currSigDims field */
      rt_LoggedCurrentSignalDimensions[0] = &rt_LoggedOutputWidths[0];
      rt_LoggedCurrentSignalDimensions[1] = &rt_LoggedOutputWidths[1];
    }

    rtliSetLogY(MuscleSpindleGUIModel_M->rtwLogInfo, "yout");
  }

  /* block I/O */
  (void) memset(((void *) &MuscleSpindleGUIModel_B), 0,
                sizeof(B_MuscleSpindleGUIModel_T));

  /* states (continuous) */
  {
    (void) memset((void *)&MuscleSpindleGUIModel_X, 0,
                  sizeof(X_MuscleSpindleGUIModel_T));
  }

  /* states (dwork) */
  (void) memset((void *)&MuscleSpindleGUIModel_DW, 0,
                sizeof(DW_MuscleSpindleGUIModel_T));

  /* external inputs */
  (void)memset((void *)&MuscleSpindleGUIModel_U, 0, sizeof
               (ExtU_MuscleSpindleGUIModel_T));

  /* external outputs */
  (void) memset((void *)&MuscleSpindleGUIModel_Y, 0,
                sizeof(ExtY_MuscleSpindleGUIModel_T));

  {
    static uint32_T *clockTickPtrs[2];
    static uint32_T *clockTickHPtrs[2];
    static real_T *taskTimePtrs[2];
    MuscleSpindleGUIMode_TimingBrdg.nTasks = 2;
    clockTickPtrs[0] = &(MuscleSpindleGUIModel_M->Timing.clockTick0);
    clockTickHPtrs[0] = &(MuscleSpindleGUIModel_M->Timing.clockTickH0);
    clockTickPtrs[1] = &(MuscleSpindleGUIModel_M->Timing.clockTick1);
    clockTickHPtrs[1] = &(MuscleSpindleGUIModel_M->Timing.clockTickH1);
    MuscleSpindleGUIMode_TimingBrdg.clockTick = clockTickPtrs;
    MuscleSpindleGUIMode_TimingBrdg.clockTickH = clockTickHPtrs;
    taskTimePtrs[0] = &(MuscleSpindleGUIModel_M->Timing.t[0]);
    taskTimePtrs[1] = (NULL);
    MuscleSpindleGUIMode_TimingBrdg.taskTime = taskTimePtrs;
    MuscleSpindleGUIMode_TimingBrdg.firstInitCond = &rtmIsFirstInitCond
      (MuscleSpindleGUIModel_M);
  }

  /* Model Initialize fcn for ModelReference Block: '<Root>/Model' */
  MuscleSpindle_initialize(rtmGetErrorStatusPointer(MuscleSpindleGUIModel_M),
    rtmGetStopRequestedPtr(MuscleSpindleGUIModel_M),
    &(MuscleSpindleGUIModel_M->solverInfo), &MuscleSpindleGUIMode_TimingBrdg, 0,
    1, &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtm),
    &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtb),
    &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtdw));

  /* Matfile logging */
  rt_StartDataLoggingWithStartTime(MuscleSpindleGUIModel_M->rtwLogInfo, 0.0,
    rtmGetTFinal(MuscleSpindleGUIModel_M),
    MuscleSpindleGUIModel_M->Timing.stepSize0, (&rtmGetErrorStatus
    (MuscleSpindleGUIModel_M)));

  /* InitializeConditions for Integrator: '<Root>/Integrator' */
  if (rtmIsFirstInitCond(MuscleSpindleGUIModel_M)) {
    MuscleSpindleGUIModel_X.Integrator_CSTATE = 0.0;
  }

  MuscleSpindleGUIModel_DW.Integrator_IWORK = 1;

  /* End of InitializeConditions for Integrator: '<Root>/Integrator' */

  /* InitializeConditions for Integrator: '<S1>/Filter' */
  MuscleSpindleGUIModel_X.Filter_CSTATE = MuscleSpindleGUIModel_P.Filter_IC;

  /* InitializeConditions for Integrator: '<S1>/Integrator' */
  MuscleSpindleGUIModel_X.Integrator_CSTATE_m =
    MuscleSpindleGUIModel_P.Integrator_IC;

  /* SystemInitialize for ModelReference: '<Root>/Model' incorporates:
   *  Inport: '<Root>/DynGam'
   *  Inport: '<Root>/StatGam'
   */
  MuscleSpindle_Init(&(MuscleSpindleGUIModel_DW.Model_InstanceData.rtm),
                     &(MuscleSpindleGUIModel_DW.Model_InstanceData.rtdw),
                     &(MuscleSpindleGUIModel_X.Model_CSTATE));

  /* set "at time zero" to false */
  if (rtmIsFirstInitCond(MuscleSpindleGUIModel_M)) {
    rtmSetFirstInitCond(MuscleSpindleGUIModel_M, 0);
  }
}

/* Model terminate function */
void MuscleSpindleGUIModel_terminate(void)
{
  /* (no terminate code required) */
}
