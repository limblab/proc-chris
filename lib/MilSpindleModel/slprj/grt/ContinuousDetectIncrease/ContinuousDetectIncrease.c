/*
 * Code generation for system model 'ContinuousDetectIncrease'
 *
 * Model                      : ContinuousDetectIncrease
 * Model version              : 1.21
 * Simulink Coder version : 8.13 (R2017b) 24-Jul-2017
 * C source code generated on : Wed Apr 29 11:33:57 2020
 *
 * Note that the functions contained in this file are part of a Simulink
 * model, and are not self-contained algorithms.
 */

#include "ContinuousDetectIncrease.h"
#include "ContinuousDetectIncrease_private.h"

/* System initialize for referenced model: 'ContinuousDetectIncrease' */
void ContinuousDetectIncrease_Init(DW_ContinuousDetectIncrease_f_T *localDW)
{
  /* InitializeConditions for Memory: '<Root>/Memory' */
  localDW->Memory_PreviousInput = 0.0;
}

/* System reset for referenced model: 'ContinuousDetectIncrease' */
void ContinuousDetectIncrease_Reset(DW_ContinuousDetectIncrease_f_T *localDW)
{
  /* InitializeConditions for Memory: '<Root>/Memory' */
  localDW->Memory_PreviousInput = 0.0;
}

/* Output and update for referenced model: 'ContinuousDetectIncrease' */
void ContinuousDetectIncrease(const real_T *rtu_U, uint8_T *rty_Y,
  DW_ContinuousDetectIncrease_f_T *localDW)
{
  /* RelationalOperator: '<Root>/FixPt Relational Operator' incorporates:
   *  Memory: '<Root>/Memory'
   */
  *rty_Y = (uint8_T)(*rtu_U > localDW->Memory_PreviousInput);

  /* Update for Memory: '<Root>/Memory' */
  localDW->Memory_PreviousInput = *rtu_U;
}

/* Model initialize function */
void ContinuousDetectIncr_initialize(const char_T **rt_errorStatus,
  RT_MODEL_ContinuousDetectIncr_T *const ContinuousDetectIncrease_M,
  DW_ContinuousDetectIncrease_f_T *localDW)
{
  /* Registration code */

  /* initialize error status */
  rtmSetErrorStatusPointer(ContinuousDetectIncrease_M, rt_errorStatus);

  /* states (dwork) */
  (void) memset((void *)localDW, 0,
                sizeof(DW_ContinuousDetectIncrease_f_T));
}
