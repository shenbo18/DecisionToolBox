#ifndef blackBox_FindOptSchedule_h
#define blackBox_FindOptSchedule_h

#include "Input.h"

struct Pair{
	int repairID;
	int repairYear;
};
typedef vector<Pair> RepairSchedule;

/* function prototype */
//float calCost(int yearFrom, int yearTo);
//float findOptCostSchedule(int ratingsDecay[][10], float repairs[][4], int nRepairs, int limit, int optSchedule[][3]);
//float calTotalCost(int optSchedule[][3], float repairCost[][4], float discountRate);



/* 
 * Function: findOptEnvSchedule
 * Usage: findEnvCO2Schedule(bridgeInfo, ratingsDecay, reparis, repairs, impMat, optSchedule);
 * ----------------------------------------------------------------------------------------------------------
 * This function generates a optimal schedule for environmental impact by using a dynamic programing algorithm.
 * Returns the minimum envImpact
 */
float findOptEnvSchedule(BridgeInfo bridge, int ratingsDecay[][10], RepairEnvMat repairs, ImproveMat impMat, int limit, RepairSchedule &optSchedule);

/* 
 * Function: findOptCostSchedule
 * Usage: findOptCostSchedule(bridgeInfo, ratingsDecay,repairs, costs, impMat, optSchedule);
 * -----------------------------------------------------------------------------------------------------------
 * This function generates a optimal schedule for environmental impact by using a dynamic programing algorithm.
 * Returns the minimum envImpact
 */
float findOptCostSchedule(BridgeInfo bridge, int ratingsDecay[][10], RepairEnvMat repairs, CostMap costs, ImproveMat impMat, int limit, RepairSchedule &optSchedule);

/*
 * Function: mergeFourSched
 * Usage: mergeFourSched(vec1,  vec2,  vec3, vec4);
 * ----------------------------------------------------------------------------------------------------------
 * This function merge four different schedules into one, and sort the merged schedule chronologically.
 */
 RepairSchedule mergeFourSched(RepairSchedule vec1, RepairSchedule vec2, RepairSchedule vec3, RepairSchedule vec4);
#endif