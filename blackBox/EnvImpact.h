//
//  envImpact.h
//  blackBox 2.0
//
//  Created by Bo Shen on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef blackBox_EnvImpact_h
#define blackBox_EnvImpact_h

#include "Input.h"

/* function prototype */

float calEnvImpact(BridgeInfo bridge, int year, int repairID, int rating, RepairEnvMat repairs, ImproveMat impMat);
//float calTotalCO2(float bridgeInfo[10], int optSchedule[][3], float repairCO2[][7]);

#endif
