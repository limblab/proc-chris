/*
 * Code generation for system model 'MuscleSpindle'
 *
 * Model                      : MuscleSpindle
 * Model version              : 1.475
 * Simulink Coder version : 8.13 (R2017b) 24-Jul-2017
 * C source code generated on : Wed Apr 29 11:34:26 2020
 *
 * Note that the functions contained in this file are part of a Simulink
 * model, and are not self-contained algorithms.
 */

#include "MuscleSpindle.h"
#include "MuscleSpindle_private.h"
#include "rt_powd_snf.h"

/*
 * Output and update for atomic system:
 *    '<S2>/Secondary Afferent Calculation (eqn (8))'
 *    '<S3>/Secondary Afferent Calculation (eqn (8))'
 */
void SecondaryAfferentCalculationeqn(real_T rtu_Gsnd, real_T rtu_T, real_T
  rtu_Ksr, real_T rtu_X, real_T rtu_Lsnd, real_T rtu_Lsr0, real_T rtu_LsrN,
  real_T rtu_Lpr0, real_T rtu_LprN, const real_T *rtu_L,
  B_SecondaryAfferentCalculatio_T *localB)
{
  real_T ScndryAffrntCntrbtn_tmp;

  /* MATLAB Function 'Bag2/Secondary Afferent Calculation (eqn (8))': '<S16>:1' */
  /* '<S16>:1:3' */
  /* '<S16>:1:5' */
  /* '<S16>:1:7' */
  /* '<S16>:1:9' */
  ScndryAffrntCntrbtn_tmp = rtu_T / rtu_Ksr;
  localB->ScndryAffrntCntrbtn = ((((*rtu_L - ScndryAffrntCntrbtn_tmp) - rtu_Lsr0)
    - rtu_LprN) * (rtu_Lsnd / rtu_Lpr0) * (1.0 - rtu_X) +
    (ScndryAffrntCntrbtn_tmp - (rtu_LsrN - rtu_Lsr0)) * (rtu_Lsnd / rtu_Lsr0) *
    rtu_X) * rtu_Gsnd;
}

/*
 * Output and update for atomic system:
 *    '<S17>/Calculate ddT (Eqn 6)'
 *    '<S25>/Calculate ddT (Eqn 6)'
 */
void MuscleSpindle_CalculateddTEqn6(real_T rtu_dT, real_T rtu_T, const real_T
  *rtu_L, real_T rtu_dL, real_T rtu_ddL, real_T rtu_Lsr0, real_T rtu_Ksr, real_T
  rtu_M, real_T rtu_C, real_T rtu_Beta, real_T rtu_a, real_T rtu_R, real_T
  rtu_Kpr, real_T rtu_Lpr0, real_T rtu_Gamma, B_CalculateddTEqn6_MuscleSpin_T
  *localB)
{
  real_T LTerm;
  real_T u;

  /* MATLAB Function 'Bag2/Tension (T) Calculation /Calculate ddT (Eqn 6)': '<S19>:1' */
  /* '<S19>:1:3' */
  LTerm = (*rtu_L - rtu_Lsr0) - rtu_T / rtu_Ksr;

  /* '<S19>:1:5' */
  u = rtu_dL - rtu_dT / rtu_Ksr;
  if (u < 0.0) {
    u = -1.0;
  } else if (u > 0.0) {
    u = 1.0;
  } else if (u == 0.0) {
    u = 0.0;
  } else {
    u = (rtNaN);
  }

  localB->ddT = ((((rtu_C * rtu_Beta * u * rt_powd_snf(fabs(rtu_dL - rtu_dT /
    rtu_Ksr), rtu_a) * (LTerm - rtu_R) + (LTerm - rtu_Lpr0) * rtu_Kpr) + rtu_M *
                   rtu_ddL) + rtu_Gamma) - rtu_T) * (rtu_Ksr / rtu_M);
}

/* System initialize for referenced model: 'MuscleSpindle' */
void MuscleSpindle_Init(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M,
  DW_MuscleSpindle_f_T *localDW, X_MuscleSpindle_n_T *localX)
{
  /* InitializeConditions for Integrator: '<S1>/fDynamic' incorporates:
   *  Integrator: '<S2>/fStatic'
   */
  if (rtmIsFirstInitCond(MuscleSpindle_M)) {
    localX->fDynamic_CSTATE = 0.0;
    localX->fStatic_CSTATE = 0.0;
  }

  localDW->fDynamic_IWORK = 1;

  /* End of InitializeConditions for Integrator: '<S1>/fDynamic' */

  /* InitializeConditions for Integrator: '<S9>/dT to T' */
  localX->dTtoT_CSTATE = 0.0;

  /* InitializeConditions for Integrator: '<S9>/ddT to dT' */
  localX->ddTtodT_CSTATE = 0.0;

  /* InitializeConditions for Derivative: '<S9>/L to dL' */
  localDW->TimeStampA = (rtInf);
  localDW->TimeStampB = (rtInf);

  /* InitializeConditions for Derivative: '<S9>/dL to ddL' */
  localDW->TimeStampA_a = (rtInf);
  localDW->TimeStampB_o = (rtInf);

  /* InitializeConditions for Integrator: '<S2>/fStatic' */
  localDW->fStatic_IWORK = 1;

  /* InitializeConditions for Integrator: '<S17>/dT to T' */
  localX->dTtoT_CSTATE_g = 0.0;

  /* InitializeConditions for Integrator: '<S17>/ddT to dT' */
  localX->ddTtodT_CSTATE_e = 0.0;

  /* InitializeConditions for Derivative: '<S17>/L to dL' */
  localDW->TimeStampA_g = (rtInf);
  localDW->TimeStampB_of = (rtInf);

  /* InitializeConditions for Derivative: '<S17>/dL to ddL' */
  localDW->TimeStampA_i = (rtInf);
  localDW->TimeStampB_d = (rtInf);

  /* InitializeConditions for Integrator: '<S25>/dT to T' */
  localX->dTtoT_CSTATE_f = 0.0;

  /* InitializeConditions for Integrator: '<S25>/ddT to dT' */
  localX->ddTtodT_CSTATE_f = 0.0;

  /* InitializeConditions for Derivative: '<S25>/L to dL' */
  localDW->TimeStampA_f = (rtInf);
  localDW->TimeStampB_j = (rtInf);

  /* InitializeConditions for Derivative: '<S25>/dL to ddL' */
  localDW->TimeStampA_m = (rtInf);
  localDW->TimeStampB_e = (rtInf);

  /* SystemInitialize for ModelReference: '<S6>/Model' */
  ContinuousDetectIncrease_Init(&(localDW->Model_InstanceData.rtdw));

  /* SystemInitialize for ModelReference: '<S13>/Model' */
  ContinuousDetectIncrease_Init(&(localDW->Model_InstanceData_j.rtdw));

  /* SystemInitialize for ModelReference: '<S21>/Model' */
  ContinuousDetectIncrease_Init(&(localDW->Model_InstanceData_m.rtdw));
}

/* System reset for referenced model: 'MuscleSpindle' */
void MuscleSpindle_Reset(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M,
  DW_MuscleSpindle_f_T *localDW, X_MuscleSpindle_n_T *localX)
{
  /* InitializeConditions for Integrator: '<S1>/fDynamic' incorporates:
   *  Integrator: '<S2>/fStatic'
   */
  if (rtmIsFirstInitCond(MuscleSpindle_M)) {
    localX->fDynamic_CSTATE = 0.0;
    localX->fStatic_CSTATE = 0.0;
  }

  localDW->fDynamic_IWORK = 1;

  /* End of InitializeConditions for Integrator: '<S1>/fDynamic' */

  /* InitializeConditions for Integrator: '<S9>/dT to T' */
  localX->dTtoT_CSTATE = 0.0;

  /* InitializeConditions for Integrator: '<S9>/ddT to dT' */
  localX->ddTtodT_CSTATE = 0.0;

  /* InitializeConditions for Derivative: '<S9>/L to dL' */
  localDW->TimeStampA = (rtInf);
  localDW->TimeStampB = (rtInf);

  /* InitializeConditions for Derivative: '<S9>/dL to ddL' */
  localDW->TimeStampA_a = (rtInf);
  localDW->TimeStampB_o = (rtInf);

  /* InitializeConditions for Integrator: '<S2>/fStatic' */
  localDW->fStatic_IWORK = 1;

  /* InitializeConditions for Integrator: '<S17>/dT to T' */
  localX->dTtoT_CSTATE_g = 0.0;

  /* InitializeConditions for Integrator: '<S17>/ddT to dT' */
  localX->ddTtodT_CSTATE_e = 0.0;

  /* InitializeConditions for Derivative: '<S17>/L to dL' */
  localDW->TimeStampA_g = (rtInf);
  localDW->TimeStampB_of = (rtInf);

  /* InitializeConditions for Derivative: '<S17>/dL to ddL' */
  localDW->TimeStampA_i = (rtInf);
  localDW->TimeStampB_d = (rtInf);

  /* InitializeConditions for Integrator: '<S25>/dT to T' */
  localX->dTtoT_CSTATE_f = 0.0;

  /* InitializeConditions for Integrator: '<S25>/ddT to dT' */
  localX->ddTtodT_CSTATE_f = 0.0;

  /* InitializeConditions for Derivative: '<S25>/L to dL' */
  localDW->TimeStampA_f = (rtInf);
  localDW->TimeStampB_j = (rtInf);

  /* InitializeConditions for Derivative: '<S25>/dL to ddL' */
  localDW->TimeStampA_m = (rtInf);
  localDW->TimeStampB_e = (rtInf);

  /* SystemReset for ModelReference: '<S6>/Model' */
  ContinuousDetectIncrease_Reset(&(localDW->Model_InstanceData.rtdw));

  /* SystemReset for ModelReference: '<S13>/Model' */
  ContinuousDetectIncrease_Reset(&(localDW->Model_InstanceData_j.rtdw));

  /* SystemReset for ModelReference: '<S21>/Model' */
  ContinuousDetectIncrease_Reset(&(localDW->Model_InstanceData_m.rtdw));
}

/* Outputs for referenced model: 'MuscleSpindle' */
void MuscleSpindle(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M, const
                   real_T *rtu_FascicleLength, const real_T
                   *rtu_DynamicFusimotor, const real_T *rtu_StaticFusimotor,
                   real_T *rty_PrimaryAfferent, real_T *rty_SecondaryAfferent,
                   B_MuscleSpindle_c_T *localB, DW_MuscleSpindle_f_T *localDW,
                   X_MuscleSpindle_n_T *localX)
{
  /* local block i/o variables */
  real_T rtb_Add_d;
  real_T rtb_Product_f;
  real_T rtb_dTtoT_e;
  real_T rtb_dLtoddL_l;
  real_T rtb_Add_mr;
  real_T rtb_Product_nd;
  real_T rtb_dTtoT_g;
  real_T rtb_dLtoddL_f;
  uint8_T rtb_Model;
  uint8_T rtb_Model_p;
  uint8_T rtb_Model_e;
  real_T *lastU;
  real_T LTerm;
  real_T rtb_Square;
  real_T rtb_Switch;
  real_T rtb_Switch_g;
  real_T rtb_Divide1;
  real_T rtb_Switch_p;
  real_T rtb_dLtoddL;
  real_T rtb_Sum1;
  real_T u;
  boolean_T tmp;

  /* Math: '<S10>/Square' */
  rtb_Square = *rtu_DynamicFusimotor * *rtu_DynamicFusimotor;

  /* Product: '<S10>/Divide1' incorporates:
   *  Sum: '<S10>/Add'
   */
  localB->Divide1 = rtb_Square / (rtb_Square + MuscleSpindle_ConstB.Square1);

  /* Integrator: '<S1>/fDynamic' */
  if (localDW->fDynamic_IWORK != 0) {
    localX->fDynamic_CSTATE = localB->Divide1;
  }

  /* RateTransition: '<S6>/Rate Transition' */
  if (rtmIsMajorTimeStep(MuscleSpindle_M)) {
    localB->RateTransition = *rtu_FascicleLength;

    /* ModelReference: '<S6>/Model' */
    ContinuousDetectIncrease(&localB->RateTransition, &rtb_Model,
      &(localDW->Model_InstanceData.rtdw));

    /* Switch: '<S6>/Switch' incorporates:
     *  Constant: '<S1>/C_lengthening'
     *  Constant: '<S1>/C_shortening'
     */
    if (rtb_Model >= ((uint8_T)0U)) {
      rtb_Switch = 1.0;
    } else {
      rtb_Switch = 0.42;
    }

    /* End of Switch: '<S6>/Switch' */

    /* RateTransition: '<S6>/Rate Transition1' */
    if (rtmIsMajorTimeStep(MuscleSpindle_M)) {
      localB->RateTransition1 = rtb_Switch;
    }

    /* End of RateTransition: '<S6>/Rate Transition1' */
  }

  /* End of RateTransition: '<S6>/Rate Transition' */

  /* Integrator: '<S9>/ddT to dT' */
  localB->ddTtodT = localX->ddTtodT_CSTATE;

  /* Derivative: '<S9>/L to dL' */
  if ((localDW->TimeStampA >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) &&
      (localDW->TimeStampB >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])))) {
    localB->LtodL = 0.0;
  } else {
    LTerm = localDW->TimeStampA;
    lastU = &localDW->LastUAtTimeA;
    if (localDW->TimeStampA < localDW->TimeStampB) {
      if (localDW->TimeStampB < (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB;
        lastU = &localDW->LastUAtTimeB;
      }
    } else {
      if (localDW->TimeStampA >= (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB;
        lastU = &localDW->LastUAtTimeB;
      }
    }

    localB->LtodL = (*rtu_FascicleLength - *lastU) /
      ((*(MuscleSpindle_M->timingBridge->taskTime
          [MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])) - LTerm);
  }

  /* End of Derivative: '<S9>/L to dL' */

  /* Derivative: '<S9>/dL to ddL' */
  if ((localDW->TimeStampA_a >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) &&
      (localDW->TimeStampB_o >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])))) {
    rtb_dLtoddL = 0.0;
  } else {
    LTerm = localDW->TimeStampA_a;
    lastU = &localDW->LastUAtTimeA_m;
    if (localDW->TimeStampA_a < localDW->TimeStampB_o) {
      if (localDW->TimeStampB_o < (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_o;
        lastU = &localDW->LastUAtTimeB_b;
      }
    } else {
      if (localDW->TimeStampA_a >= (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_o;
        lastU = &localDW->LastUAtTimeB_b;
      }
    }

    rtb_dLtoddL = (localB->LtodL - *lastU) / ((*(MuscleSpindle_M->
      timingBridge->taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])) -
      LTerm);
  }

  /* End of Derivative: '<S9>/dL to ddL' */

  /* MATLAB Function: '<S9>/Calculate ddT (Eqn 6)' incorporates:
   *  Constant: '<S1>/Fascicle length below which force is 0 (R)'
   *  Constant: '<S1>/Mass'
   *  Constant: '<S1>/Nonlinear velocity dependence power constant (a)'
   *  Constant: '<S1>/Passive damping coefficient (Beta)'
   *  Constant: '<S1>/Polar Zone Rest Length (Lpr0)'
   *  Constant: '<S1>/Polar region spring constant (Kpr)'
   *  Constant: '<S1>/Sensory region rest length (Lsr0)'
   *  Constant: '<S1>/Sensory region spring constant Ksr'
   *  Constant: '<S1>/fDynamic damping (Beta1)'
   *  Constant: '<S1>/fDynamic force gent (Gamma1)'
   *  Integrator: '<S1>/fDynamic'
   *  Integrator: '<S9>/dT to T'
   *  Product: '<S5>/Product'
   *  Product: '<S7>/Product'
   *  Sum: '<S5>/Add'
   */
  /* MATLAB Function 'Bag1/Tension (T) Calculation /Calculate ddT (Eqn 6)': '<S11>:1' */
  /* '<S11>:1:3' */
  LTerm = (*rtu_FascicleLength - 0.04) - localX->dTtoT_CSTATE / 10.4649;

  /* '<S11>:1:5' */
  u = localB->LtodL - localB->ddTtodT / 10.4649;
  if (u < 0.0) {
    u = -1.0;
  } else if (u > 0.0) {
    u = 1.0;
  } else if (u == 0.0) {
    u = 0.0;
  } else {
    u = (rtNaN);
  }

  localB->ddT = (((((0.2592 * localX->fDynamic_CSTATE + 0.0605) *
                    localB->RateTransition1 * u * rt_powd_snf(fabs(localB->LtodL
    - localB->ddTtodT / 10.4649), 0.3) * (LTerm - 0.46) + (LTerm - 0.76) * 0.15)
                   + 0.0002 * rtb_dLtoddL) + 0.0289 * localX->fDynamic_CSTATE) -
                 localX->dTtoT_CSTATE) * (10.4649 / 0.0002);

  /* End of MATLAB Function: '<S9>/Calculate ddT (Eqn 6)' */

  /* Product: '<S10>/Divide' incorporates:
   *  Constant: '<S1>/Low-Pass Filter Time Constant (Tau)'
   *  Integrator: '<S1>/fDynamic'
   *  Sum: '<S10>/Subtract'
   */
  localB->Divide = (localB->Divide1 - localX->fDynamic_CSTATE) / 0.149;

  /* Math: '<S18>/Square' incorporates:
   *  Math: '<S26>/Square'
   */
  u = *rtu_StaticFusimotor * *rtu_StaticFusimotor;

  /* Product: '<S18>/Divide1' incorporates:
   *  Math: '<S18>/Square'
   *  Sum: '<S18>/Add'
   */
  localB->Divide1_k = u / (u + MuscleSpindle_ConstB.Square1_n);

  /* Integrator: '<S2>/fStatic' */
  if (localDW->fStatic_IWORK != 0) {
    localX->fStatic_CSTATE = localB->Divide1_k;
  }

  /* Sum: '<S12>/Add' incorporates:
   *  Constant: '<S2>/Passive damping coefficient (Beta)'
   *  Constant: '<S2>/fStatic damping (Beta2)'
   *  Integrator: '<S2>/fStatic'
   *  Product: '<S12>/Product'
   */
  rtb_Add_d = (-0.046) * localX->fStatic_CSTATE + 0.0822;

  /* RateTransition: '<S13>/Rate Transition' */
  if (rtmIsMajorTimeStep(MuscleSpindle_M)) {
    localB->RateTransition_m = *rtu_FascicleLength;

    /* ModelReference: '<S13>/Model' */
    ContinuousDetectIncrease(&localB->RateTransition_m, &rtb_Model_p,
      &(localDW->Model_InstanceData_j.rtdw));

    /* Switch: '<S13>/Switch' incorporates:
     *  Constant: '<S2>/C_lengthening'
     *  Constant: '<S2>/C_shortening'
     */
    if (rtb_Model_p >= ((uint8_T)0U)) {
      rtb_Switch_g = 1.0;
    } else {
      rtb_Switch_g = 0.42;
    }

    /* End of Switch: '<S13>/Switch' */

    /* RateTransition: '<S13>/Rate Transition1' */
    if (rtmIsMajorTimeStep(MuscleSpindle_M)) {
      localB->RateTransition1_h = rtb_Switch_g;
    }

    /* End of RateTransition: '<S13>/Rate Transition1' */
  }

  /* End of RateTransition: '<S13>/Rate Transition' */

  /* Product: '<S14>/Product' incorporates:
   *  Constant: '<S2>/fStatic force gent (Gamma2)'
   *  Integrator: '<S2>/fStatic'
   */
  rtb_Product_f = 0.0636 * localX->fStatic_CSTATE;

  /* Integrator: '<S17>/dT to T' */
  rtb_dTtoT_e = localX->dTtoT_CSTATE_g;

  /* MATLAB Function: '<S2>/Secondary Afferent Calculation (eqn (8))' incorporates:
   *  Constant: '<S2>/Polar Zone Rest Length (Lpr0)'
   *  Constant: '<S2>/Polar region threshold length (LprN)'
   *  Constant: '<S2>/Proportion of p-rgn cont. to SndAff (X)'
   *  Constant: '<S2>/Sensory region rest length (Lsr0)'
   *  Constant: '<S2>/Sensory region spring constant Ksr'
   *  Constant: '<S2>/Sensory region threshold length (LsrN)'
   *  Constant: '<S2>/SndAff Rest Length (Lsnd)'
   *  Constant: '<S2>/Term for Stretch to Secondary Afferent Firing Gsnd'
   */
  SecondaryAfferentCalculationeqn(7250.0, rtb_dTtoT_e, 10.4649, 0.7, 0.04, 0.04,
    0.0423, 0.76, 0.89, rtu_FascicleLength,
    &localB->sf_SecondaryAfferentCalculation);

  /* Integrator: '<S17>/ddT to dT' */
  localB->ddTtodT_o = localX->ddTtodT_CSTATE_e;

  /* Derivative: '<S17>/L to dL' */
  if ((localDW->TimeStampA_g >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) &&
      (localDW->TimeStampB_of >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])))) {
    localB->LtodL_e = 0.0;
  } else {
    LTerm = localDW->TimeStampA_g;
    lastU = &localDW->LastUAtTimeA_n;
    if (localDW->TimeStampA_g < localDW->TimeStampB_of) {
      if (localDW->TimeStampB_of < (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_of;
        lastU = &localDW->LastUAtTimeB_e;
      }
    } else {
      if (localDW->TimeStampA_g >= (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_of;
        lastU = &localDW->LastUAtTimeB_e;
      }
    }

    localB->LtodL_e = (*rtu_FascicleLength - *lastU) /
      ((*(MuscleSpindle_M->timingBridge->taskTime
          [MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])) - LTerm);
  }

  /* End of Derivative: '<S17>/L to dL' */

  /* Derivative: '<S17>/dL to ddL' */
  if ((localDW->TimeStampA_i >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) &&
      (localDW->TimeStampB_d >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])))) {
    rtb_dLtoddL_l = 0.0;
  } else {
    LTerm = localDW->TimeStampA_i;
    lastU = &localDW->LastUAtTimeA_a;
    if (localDW->TimeStampA_i < localDW->TimeStampB_d) {
      if (localDW->TimeStampB_d < (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_d;
        lastU = &localDW->LastUAtTimeB_k;
      }
    } else {
      if (localDW->TimeStampA_i >= (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_d;
        lastU = &localDW->LastUAtTimeB_k;
      }
    }

    rtb_dLtoddL_l = (localB->LtodL_e - *lastU) /
      ((*(MuscleSpindle_M->timingBridge->taskTime
          [MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])) - LTerm);
  }

  /* End of Derivative: '<S17>/dL to ddL' */

  /* MATLAB Function: '<S17>/Calculate ddT (Eqn 6)' incorporates:
   *  Constant: '<S2>/Fascicle length below which force is 0 (R)'
   *  Constant: '<S2>/Mass'
   *  Constant: '<S2>/Nonlinear velocity dependence power constant (a)'
   *  Constant: '<S2>/Polar Zone Rest Length (Lpr0)'
   *  Constant: '<S2>/Polar region spring constant (Kpr)'
   *  Constant: '<S2>/Sensory region rest length (Lsr0)'
   *  Constant: '<S2>/Sensory region spring constant Ksr'
   */
  MuscleSpindle_CalculateddTEqn6(localB->ddTtodT_o, rtb_dTtoT_e,
    rtu_FascicleLength, localB->LtodL_e, rtb_dLtoddL_l, 0.04, 10.4649, 0.0002,
    localB->RateTransition1_h, rtb_Add_d, 0.3, 0.46, 0.15, 0.76, rtb_Product_f,
    &localB->sf_CalculateddTEqn6_c);

  /* Product: '<S18>/Divide' incorporates:
   *  Constant: '<S2>/Low-Pass Filter Time Constant (Tau)'
   *  Integrator: '<S2>/fStatic'
   *  Sum: '<S18>/Subtract'
   */
  localB->Divide_g = (localB->Divide1_k - localX->fStatic_CSTATE) / 0.205;

  /* Product: '<S26>/Divide1' incorporates:
   *  Sum: '<S26>/Add'
   */
  rtb_Divide1 = u / (u + MuscleSpindle_ConstB.Square1_m);

  /* Sum: '<S20>/Add' incorporates:
   *  Constant: '<S3>/Passive damping coefficient (Beta)'
   *  Constant: '<S3>/fStatic damping (Beta2)'
   *  Product: '<S20>/Product'
   */
  rtb_Add_mr = (-0.069) * rtb_Divide1 + 0.0822;

  /* RateTransition: '<S21>/Rate Transition' */
  if (rtmIsMajorTimeStep(MuscleSpindle_M)) {
    localB->RateTransition_e = *rtu_FascicleLength;

    /* ModelReference: '<S21>/Model' */
    ContinuousDetectIncrease(&localB->RateTransition_e, &rtb_Model_e,
      &(localDW->Model_InstanceData_m.rtdw));

    /* Switch: '<S21>/Switch' incorporates:
     *  Constant: '<S3>/C_lengthening'
     *  Constant: '<S3>/C_shortening'
     */
    if (rtb_Model_e >= ((uint8_T)0U)) {
      rtb_Switch_p = 1.0;
    } else {
      rtb_Switch_p = 0.42;
    }

    /* End of Switch: '<S21>/Switch' */

    /* RateTransition: '<S21>/Rate Transition1' */
    if (rtmIsMajorTimeStep(MuscleSpindle_M)) {
      localB->RateTransition1_l = rtb_Switch_p;
    }

    /* End of RateTransition: '<S21>/Rate Transition1' */
  }

  /* End of RateTransition: '<S21>/Rate Transition' */

  /* Product: '<S22>/Product' incorporates:
   *  Constant: '<S3>/fDynamic force gent (Gamma2)'
   */
  rtb_Product_nd = 0.0954 * rtb_Divide1;

  /* Integrator: '<S25>/dT to T' */
  rtb_dTtoT_g = localX->dTtoT_CSTATE_f;

  /* MATLAB Function: '<S3>/Secondary Afferent Calculation (eqn (8))' incorporates:
   *  Constant: '<S3>/Polar Zone Rest Length (Lpr0)'
   *  Constant: '<S3>/Polar region threshold length (LprN)'
   *  Constant: '<S3>/Proportion of p-rgn cont. to SndAff (X)'
   *  Constant: '<S3>/Sensory region rest length (Lsr0)'
   *  Constant: '<S3>/Sensory region spring constant Ksr'
   *  Constant: '<S3>/Sensory region threshold length (LsrN)'
   *  Constant: '<S3>/SndAff Rest Length (Lsnd)'
   *  Constant: '<S3>/Term for Stretch to Secondary Afferent Firing Gsnd'
   */
  SecondaryAfferentCalculationeqn(7250.0, rtb_dTtoT_g, 10.4649, 0.7, 0.04, 0.04,
    0.0423, 0.76, 0.89, rtu_FascicleLength,
    &localB->sf_SecondaryAfferentCalculati_a);

  /* Integrator: '<S25>/ddT to dT' */
  localB->ddTtodT_c = localX->ddTtodT_CSTATE_f;

  /* Derivative: '<S25>/L to dL' */
  if ((localDW->TimeStampA_f >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) &&
      (localDW->TimeStampB_j >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])))) {
    localB->LtodL_em = 0.0;
  } else {
    LTerm = localDW->TimeStampA_f;
    lastU = &localDW->LastUAtTimeA_l;
    if (localDW->TimeStampA_f < localDW->TimeStampB_j) {
      if (localDW->TimeStampB_j < (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_j;
        lastU = &localDW->LastUAtTimeB_k2;
      }
    } else {
      if (localDW->TimeStampA_f >= (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_j;
        lastU = &localDW->LastUAtTimeB_k2;
      }
    }

    localB->LtodL_em = (*rtu_FascicleLength - *lastU) /
      ((*(MuscleSpindle_M->timingBridge->taskTime
          [MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])) - LTerm);
  }

  /* End of Derivative: '<S25>/L to dL' */

  /* Derivative: '<S25>/dL to ddL' */
  if ((localDW->TimeStampA_m >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) &&
      (localDW->TimeStampB_e >= (*(MuscleSpindle_M->timingBridge->
         taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])))) {
    rtb_dLtoddL_f = 0.0;
  } else {
    LTerm = localDW->TimeStampA_m;
    lastU = &localDW->LastUAtTimeA_h;
    if (localDW->TimeStampA_m < localDW->TimeStampB_e) {
      if (localDW->TimeStampB_e < (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_e;
        lastU = &localDW->LastUAtTimeB_o;
      }
    } else {
      if (localDW->TimeStampA_m >= (*(MuscleSpindle_M->timingBridge->
            taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]))) {
        LTerm = localDW->TimeStampB_e;
        lastU = &localDW->LastUAtTimeB_o;
      }
    }

    rtb_dLtoddL_f = (localB->LtodL_em - *lastU) /
      ((*(MuscleSpindle_M->timingBridge->taskTime
          [MuscleSpindle_M->Timing.mdlref_GlobalTID[0]])) - LTerm);
  }

  /* End of Derivative: '<S25>/dL to ddL' */

  /* MATLAB Function: '<S25>/Calculate ddT (Eqn 6)' incorporates:
   *  Constant: '<S3>/Fascicle length below which force is 0 (R)'
   *  Constant: '<S3>/Mass'
   *  Constant: '<S3>/Nonlinear velocity dependence power constant (a)'
   *  Constant: '<S3>/Polar Zone Rest Length (Lpr0)'
   *  Constant: '<S3>/Polar region spring constant (Kpr)'
   *  Constant: '<S3>/Sensory region rest length (Lsr0)'
   *  Constant: '<S3>/Sensory region spring constant Ksr'
   */
  MuscleSpindle_CalculateddTEqn6(localB->ddTtodT_c, rtb_dTtoT_g,
    rtu_FascicleLength, localB->LtodL_em, rtb_dLtoddL_f, 0.04, 10.4649, 0.0002,
    localB->RateTransition1_l, rtb_Add_mr, 0.3, 0.46, 0.15, 0.76, rtb_Product_nd,
    &localB->sf_CalculateddTEqn6_b);

  /* Sum: '<Root>/Sum1' incorporates:
   *  Constant: '<S1>/Sensory region spring constant Ksr'
   *  Constant: '<S1>/Term for Stretch to Afferent Firing G'
   *  Constant: '<S2>/Sensory region spring constant Ksr'
   *  Constant: '<S2>/Term for Stretch to Afferent Firing G'
   *  Constant: '<S3>/Sensory region spring constant Ksr'
   *  Constant: '<S3>/Term for Stretch to Afferent Firing G'
   *  Integrator: '<S9>/dT to T'
   *  Product: '<S15>/Divide'
   *  Product: '<S15>/Product'
   *  Product: '<S23>/Divide'
   *  Product: '<S23>/Product'
   *  Product: '<S8>/Divide'
   *  Product: '<S8>/Product'
   *  Sum: '<S15>/Subtract'
   *  Sum: '<S23>/Subtract'
   *  Sum: '<S8>/Subtract'
   */
  rtb_Sum1 = ((localX->dTtoT_CSTATE / 10.4649 - MuscleSpindle_ConstB.Subtract1) *
              20000.0 + (rtb_dTtoT_e / 10.4649 -
    MuscleSpindle_ConstB.Subtract1_a) * 10000.0) + (rtb_dTtoT_g / 10.4649 -
    MuscleSpindle_ConstB.Subtract1_d) * 10000.0;

  /* Sum: '<Root>/Sum' */
  *rty_SecondaryAfferent =
    localB->sf_SecondaryAfferentCalculation.ScndryAffrntCntrbtn +
    localB->sf_SecondaryAfferentCalculati_a.ScndryAffrntCntrbtn;

  /* MinMax: '<S4>/Min' incorporates:
   *  MinMax: '<S4>/Max'
   */
  tmp = rtIsNaN(*rty_SecondaryAfferent);
  if ((rtb_Sum1 < *rty_SecondaryAfferent) || tmp) {
    LTerm = rtb_Sum1;
  } else {
    LTerm = *rty_SecondaryAfferent;
  }

  /* End of MinMax: '<S4>/Min' */

  /* MinMax: '<S4>/Max' */
  if ((rtb_Sum1 > *rty_SecondaryAfferent) || tmp) {
    u = rtb_Sum1;
  } else {
    u = *rty_SecondaryAfferent;
  }

  /* Sum: '<S4>/Sum' incorporates:
   *  Constant: '<Root>/S'
   *  Product: '<S4>/Product'
   */
  *rty_PrimaryAfferent = 0.156 * LTerm + u;
}

/* Update for referenced model: 'MuscleSpindle' */
void MuscleSpindle_Update(RT_MODEL_MuscleSpindle_T * const MuscleSpindle_M,
  const real_T *rtu_FascicleLength, B_MuscleSpindle_c_T *localB,
  DW_MuscleSpindle_f_T *localDW)
{
  real_T *lastU;

  /* Update for Integrator: '<S1>/fDynamic' */
  localDW->fDynamic_IWORK = 0;

  /* Update for Derivative: '<S9>/L to dL' */
  if (localDW->TimeStampA == (rtInf)) {
    localDW->TimeStampA = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA;
  } else if (localDW->TimeStampB == (rtInf)) {
    localDW->TimeStampB = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB;
  } else if (localDW->TimeStampA < localDW->TimeStampB) {
    localDW->TimeStampA = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA;
  } else {
    localDW->TimeStampB = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB;
  }

  *lastU = *rtu_FascicleLength;

  /* End of Update for Derivative: '<S9>/L to dL' */

  /* Update for Derivative: '<S9>/dL to ddL' */
  if (localDW->TimeStampA_a == (rtInf)) {
    localDW->TimeStampA_a = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_m;
  } else if (localDW->TimeStampB_o == (rtInf)) {
    localDW->TimeStampB_o = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_b;
  } else if (localDW->TimeStampA_a < localDW->TimeStampB_o) {
    localDW->TimeStampA_a = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_m;
  } else {
    localDW->TimeStampB_o = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_b;
  }

  *lastU = localB->LtodL;

  /* End of Update for Derivative: '<S9>/dL to ddL' */

  /* Update for Integrator: '<S2>/fStatic' */
  localDW->fStatic_IWORK = 0;

  /* Update for Derivative: '<S17>/L to dL' */
  if (localDW->TimeStampA_g == (rtInf)) {
    localDW->TimeStampA_g = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_n;
  } else if (localDW->TimeStampB_of == (rtInf)) {
    localDW->TimeStampB_of = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_e;
  } else if (localDW->TimeStampA_g < localDW->TimeStampB_of) {
    localDW->TimeStampA_g = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_n;
  } else {
    localDW->TimeStampB_of = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_e;
  }

  *lastU = *rtu_FascicleLength;

  /* End of Update for Derivative: '<S17>/L to dL' */

  /* Update for Derivative: '<S17>/dL to ddL' */
  if (localDW->TimeStampA_i == (rtInf)) {
    localDW->TimeStampA_i = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_a;
  } else if (localDW->TimeStampB_d == (rtInf)) {
    localDW->TimeStampB_d = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_k;
  } else if (localDW->TimeStampA_i < localDW->TimeStampB_d) {
    localDW->TimeStampA_i = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_a;
  } else {
    localDW->TimeStampB_d = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_k;
  }

  *lastU = localB->LtodL_e;

  /* End of Update for Derivative: '<S17>/dL to ddL' */

  /* Update for Derivative: '<S25>/L to dL' */
  if (localDW->TimeStampA_f == (rtInf)) {
    localDW->TimeStampA_f = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_l;
  } else if (localDW->TimeStampB_j == (rtInf)) {
    localDW->TimeStampB_j = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_k2;
  } else if (localDW->TimeStampA_f < localDW->TimeStampB_j) {
    localDW->TimeStampA_f = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_l;
  } else {
    localDW->TimeStampB_j = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_k2;
  }

  *lastU = *rtu_FascicleLength;

  /* End of Update for Derivative: '<S25>/L to dL' */

  /* Update for Derivative: '<S25>/dL to ddL' */
  if (localDW->TimeStampA_m == (rtInf)) {
    localDW->TimeStampA_m = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_h;
  } else if (localDW->TimeStampB_e == (rtInf)) {
    localDW->TimeStampB_e = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_o;
  } else if (localDW->TimeStampA_m < localDW->TimeStampB_e) {
    localDW->TimeStampA_m = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeA_h;
  } else {
    localDW->TimeStampB_e = (*(MuscleSpindle_M->timingBridge->
      taskTime[MuscleSpindle_M->Timing.mdlref_GlobalTID[0]]));
    lastU = &localDW->LastUAtTimeB_o;
  }

  *lastU = localB->LtodL_em;

  /* End of Update for Derivative: '<S25>/dL to ddL' */
}

/* Derivatives for referenced model: 'MuscleSpindle' */
void MuscleSpindle_Deriv(B_MuscleSpindle_c_T *localB, XDot_MuscleSpindle_n_T
  *localXdot)
{
  /* Derivatives for Integrator: '<S1>/fDynamic' */
  localXdot->fDynamic_CSTATE = localB->Divide;

  /* Derivatives for Integrator: '<S9>/dT to T' */
  localXdot->dTtoT_CSTATE = localB->ddTtodT;

  /* Derivatives for Integrator: '<S9>/ddT to dT' */
  localXdot->ddTtodT_CSTATE = localB->ddT;

  /* Derivatives for Integrator: '<S2>/fStatic' */
  localXdot->fStatic_CSTATE = localB->Divide_g;

  /* Derivatives for Integrator: '<S17>/dT to T' */
  localXdot->dTtoT_CSTATE_g = localB->ddTtodT_o;

  /* Derivatives for Integrator: '<S17>/ddT to dT' */
  localXdot->ddTtodT_CSTATE_e = localB->sf_CalculateddTEqn6_c.ddT;

  /* Derivatives for Integrator: '<S25>/dT to T' */
  localXdot->dTtoT_CSTATE_f = localB->ddTtodT_c;

  /* Derivatives for Integrator: '<S25>/ddT to dT' */
  localXdot->ddTtodT_CSTATE_f = localB->sf_CalculateddTEqn6_b.ddT;
}

/* Model initialize function */
void MuscleSpindle_initialize(const char_T **rt_errorStatus, boolean_T
  *rt_stopRequested, RTWSolverInfo *rt_solverInfo, const rtTimingBridge
  *timingBridge, int_T mdlref_TID0, int_T mdlref_TID1, RT_MODEL_MuscleSpindle_T *
  const MuscleSpindle_M, B_MuscleSpindle_c_T *localB, DW_MuscleSpindle_f_T
  *localDW)
{
  /* Registration code */

  /* initialize non-finites */
  rt_InitInfAndNaN(sizeof(real_T));

  /* initialize real-time model */
  (void) memset((void *)MuscleSpindle_M, 0,
                sizeof(RT_MODEL_MuscleSpindle_T));

  /* setup the global timing engine */
  MuscleSpindle_M->Timing.mdlref_GlobalTID[0] = mdlref_TID0;
  MuscleSpindle_M->Timing.mdlref_GlobalTID[1] = mdlref_TID1;
  MuscleSpindle_M->timingBridge = (timingBridge);

  /* initialize error status */
  rtmSetErrorStatusPointer(MuscleSpindle_M, rt_errorStatus);

  /* initialize stop requested flag */
  rtmSetStopRequestedPtr(MuscleSpindle_M, rt_stopRequested);

  /* initialize RTWSolverInfo */
  MuscleSpindle_M->solverInfo = (rt_solverInfo);

  /* Set the Timing fields to the appropriate data in the RTWSolverInfo */
  rtmSetSimTimeStepPointer(MuscleSpindle_M, rtsiGetSimTimeStepPtr
    (MuscleSpindle_M->solverInfo));
  MuscleSpindle_M->Timing.stepSize0 = (rtsiGetStepSize
    (MuscleSpindle_M->solverInfo));

  /* block I/O */
  (void) memset(((void *) localB), 0,
                sizeof(B_MuscleSpindle_c_T));

  /* states (dwork) */
  (void) memset((void *)localDW, 0,
                sizeof(DW_MuscleSpindle_f_T));

  /* Model Initialize fcn for ModelReference Block: '<S6>/Model' */
  ContinuousDetectIncr_initialize(rtmGetErrorStatusPointer(MuscleSpindle_M),
    &(localDW->Model_InstanceData.rtm), &(localDW->Model_InstanceData.rtdw));

  /* Model Initialize fcn for ModelReference Block: '<S13>/Model' */
  ContinuousDetectIncr_initialize(rtmGetErrorStatusPointer(MuscleSpindle_M),
    &(localDW->Model_InstanceData_j.rtm), &(localDW->Model_InstanceData_j.rtdw));

  /* Model Initialize fcn for ModelReference Block: '<S21>/Model' */
  ContinuousDetectIncr_initialize(rtmGetErrorStatusPointer(MuscleSpindle_M),
    &(localDW->Model_InstanceData_m.rtm), &(localDW->Model_InstanceData_m.rtdw));
}
