
//
//  Created by Bo Shen on 12/8/12.
//  Copyright (c) 2012 Bo Shen. All rights reserved.
//


// Input structures are defined here except those defined in LCO.ice senStore.ice

#ifndef blackBox_Input_h
#define blackBox_Input_h

#include <vector>
#include "LCO.h"
#include "EnumString.h"
#include <map>
#include "SenStore.h"
#include <Ice/Ice.h>
#include <iostream>

using namespace std;
using namespace LCO;
using namespace SenStore;

/*
enum componentType {
    Barrier = 1,
    Bearing = 2,
    Bent = 3,
    Column = 4,
    Deck = 5,
    Foundation = 6,
    Girder = 7,
    Joint = 8,
    Other = 9,
    PinHanger = 10
    };
*/

struct RepairBasicInfo {
    int repairID;
    string component;
    int LB;
    int UB;
    int improvement;
};

typedef vector<RepairBasicInfo> RepairBasicInfoMat; // ?

struct EnvCoef {
    int repairID;
    float repairMean;
    float trafficMean;
};

typedef vector<EnvCoef> EnvCoefMat; //?

struct ImpCoef {
    int condition;
    float coef;
};

typedef vector<ImpCoef> ImproveMat;

//enum OptimizationObjective {
//	GlobalWarming = 1,
//	OzoneDepletionPotential = 2,
//	AcidificationPotential = 3,
//	EutriphicationPotential = 4,
//	HeavyMetal= 5,
//	Carcinogens = 6,
//	SummerSmog = 7,
//	WinterSmog = 8,
//	EnergyResources = 9,
//	SolidWaste = 10,
//	Cost = 11,
//};

//enum StructureComponentType {
//	/** Deck.  */
//	StructureComponentTypeDECK,
//	/** Abutment.  */
//	StructureComponentTypeABUTMENT,
//	/** Pin and hanger.  */
//	StructureComponentTypePINHANGER,
//	/** Span.  */
//	StructureComponentTypeSPAN,
//	/** Column.  */
//	StructureComponentTypeCOLUMN,
//};
//
///* String support for StructureComponentType */
//Begin_Enum_String( StructureComponentType )
//{
//	Enum_String( StructureComponentTypeDECK );
//	Enum_String( StructureComponentTypeABUTMENT );
//	Enum_String( StructureComponentTypePINHANGER );
//	Enum_String( StructureComponentTypeSPAN );
//	Enum_String( StructureComponentTypeCOLUMN );
//}
//End_Enum_String;

struct ServerInput {
    float bridgeWidth;
    float bridgeLength;
    StructureComponentType componentType;
};

struct RepairCost {
    int repairID;
    int LB;
    int UB;
	float cost;
	int duration;
    int improvement;
};

typedef vector<RepairCost> RepCostMat;

struct RepairEnv {
    int repairID;
    int LB;
    int UB;
    int improvement;
	int duration;
	float repairMean;
    float trafficMean;
};

typedef vector<RepairEnv> RepairEnvMat;

struct BridgeInfo {
	float bridgeWidth;
    float bridgeLength;
	int bridgeID;
	float bridgeAADT;
	float bridgeAADTT;
	float trafficGrowthRate;
	float discountRate;
	int startRating;
	int startYear;
};

typedef map<int,float> CostMap;

// function prototypes

/*
 * Function: toUpper
 * Usage: toUpper(s);
 * ---------------------------------------
 * convert a string to a uppercase string
 */
string toUpper(string);

/*
 * Function: ExePath
 * Usage: ExePath();
 * ------------------------------------------------------
 * Return the current working directory of the executable
 */
string ExePath();


/*
 * Function: ratingDecay
 * Usage: ratingDecay(ratingsDecay, limit);
 * ----------------------------------------
 * Calculate the years that takes for rating "x" decreasing to "y" witout maintenance
 * by using deteriorate curve obtained from polyFit.
 */
void ratingDecay(int ratingsDecay[][10],ComponentRatingMat ratings, int limit);

/*
 * Function: readRepairBasicInfo
 * Usage: readRepairBasicInfo();
 * -----------------------------------------------------------------------------------------------------------
 * Read basic info which includes <repairID, appliedComponent, LB and UB of condition applicable, improvement>
 * Data are stored as a text file in the "Data" file which is in the same directory of the blackbox executable
 * Function returns a struct RepairBasicInfoMat defined in the input.h
 */
RepairBasicInfoMat readRepairBasicInfo();

/*
 * Function: readEnvCoef
 * Usage: readEnvCoef(optObj);
 * -----------------------------------------------------------------------------------------------------------
 * Read the coefficients used to calculate the environmental impact
 * Data are stored as a text file in the "Data" file which is in the same directory of the blackbox executable
 * Function returns a struct EnvCoefMat defined in the input.h
 */
EnvCoefMat readEnvCoef(int optObj);

/*
 * Function: bridgeInfoCompiler
 * Usage: bridgeInfoCompiler(userIn,serverIn);
 * ----------------------------------------------------------------------
 * Compile the inputs from both user and server into a struct BridgeInfo 
 * BridgeInfo is an argument of function findOptEnvSchedule
 */
BridgeInfo bridgeInfoCompiler(UserInput userIn, ServerInput serverIn);

/*
 * Function: envInfoComiler
 * Usage: envInfoCompiler(repairUserIn, componentType, basicInfo, envMat);
 * -----------------------------------------------------------------------
 * Compile the inputs from user and data files into a struct RepairEnvMat
 * RepairEnvMat is an argument of function findOptEnvSchedule
 */
RepairEnvMat envInfoCompiler(RepairInfoMat repairUserIn, string componentType, RepairBasicInfoMat &basicInfo, EnvCoefMat &envMat);

/*
 * Function: readRepairCost
 * Usage: readRepairCost(repairs);
 * ---------------------------------------------
 * map repair costs to repairIDs
 */
CostMap readRepairCost(RepairInfoMat repairs);

/*
 * Function: readServerInput
 * Usage: readServerInput(brdigeID, componentID)
 * ---------------------------------------------
 * map repair costs to repairIDs
 */
ServerInput readServerInput(int bridgeID, int componentID);

/*
 * Function: readRatings
 * Usage: readRatings(componentID)
 * ------------------------------------
 * read ratings for given component
 */
ComponentRatingMat readRatings(int bridgeID,int componentID);

#endif