/*
 * Code generation for system model 'ContinuousDetectIncrease'
 * For more details, see corresponding source file ContinuousDetectIncrease.c
 *
 */

#ifndef RTW_HEADER_ContinuousDetectIncrease_h_
#define RTW_HEADER_ContinuousDetectIncrease_h_
#include <string.h>
#ifndef ContinuousDetectIncrease_COMMON_INCLUDES_
# define ContinuousDetectIncrease_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#endif                                 /* ContinuousDetectIncrease_COMMON_INCLUDES_ */

#include "ContinuousDetectIncrease_types.h"

/* Shared type includes */
#include "multiword_types.h"

/* Block states (auto storage) for model 'ContinuousDetectIncrease' */
typedef struct {
  real_T Memory_PreviousInput;         /* '<Root>/Memory' */
} DW_ContinuousDetectIncrease_f_T;

/* Real-time Model Data Structure */
struct tag_RTM_ContinuousDetectIncre_T {
  const char_T **errorStatus;
};

typedef struct {
  DW_ContinuousDetectIncrease_f_T rtdw;
  RT_MODEL_ContinuousDetectIncr_T rtm;
} MdlrefDW_ContinuousDetectIncr_T;

/* Model reference registration function */
extern void ContinuousDetectIncr_initialize(const char_T **rt_errorStatus,
  RT_MODEL_ContinuousDetectIncr_T *const ContinuousDetectIncrease_M,
  DW_ContinuousDetectIncrease_f_T *localDW);
extern void ContinuousDetectIncrease_Init(DW_ContinuousDetectIncrease_f_T
  *localDW);
extern void ContinuousDetectIncrease_Reset(DW_ContinuousDetectIncrease_f_T
  *localDW);
extern void ContinuousDetectIncrease(const real_T *rtu_U, uint8_T *rty_Y,
  DW_ContinuousDetectIncrease_f_T *localDW);

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
 * '<Root>' : 'ContinuousDetectIncrease'
 */
#endif                                 /* RTW_HEADER_ContinuousDetectIncrease_h_ */
