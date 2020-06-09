/*
 * MuscleSpindleGUIModel_data.c
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

/* Block parameters (auto storage) */
P_MuscleSpindleGUIModel_T MuscleSpindleGUIModel_P = {
  /* Mask Parameter: PIDController_D
   * Referenced by: '<S1>/Derivative Gain'
   */
  0.25,

  /* Mask Parameter: PIDController_I
   * Referenced by: '<S1>/Integral Gain'
   */
  0.75,

  /* Mask Parameter: PIDController_N
   * Referenced by: '<S1>/Filter Coefficient'
   */
  100.0,

  /* Mask Parameter: PIDController_P
   * Referenced by: '<S1>/Proportional Gain'
   */
  5.0,

  /* Expression: InitialConditionForFilter
   * Referenced by: '<S1>/Filter'
   */
  0.0,

  /* Expression: InitialConditionForIntegrator
   * Referenced by: '<S1>/Integrator'
   */
  0.0
};
