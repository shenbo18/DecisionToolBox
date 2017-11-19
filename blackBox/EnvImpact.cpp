//
//  EnvImpact.cpp
//  optSchedule
//
//  Created by Bo Shen on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <math.h>
#include <set>
#include "EnvImpact.h"
#include <limits>

/*
 * Function: calCO2
 * Usage: calCO2(bridgeInfo, year, repairID, conditionRating, repairCO2);
 * ----------------------------------------------------------------------
 * Calculate the C02 for given repair info;
 * BridgeInfo: [0]Length, [1]Width, [2]ADDT, [3]ADDTT, [4]Traffic Growth Rate, [5]discount rate 
 * RepairEnMat: [0]repairID, [1]improvement, [2]condition rating, [3]meanRepair, [4]meanTraffic, [5]days of repair, 
 * ImproveMat: improvement coefficient
 * Exceptions are hard coded here
 */
float calEnvImpact(BridgeInfo bridge, int year, int repairID, int rating, RepairEnvMat repairs, ImproveMat impMat) {
    float deckLength = bridge.bridgeLength;
    float deckWidth = bridge.bridgeWidth;
    float AADT = bridge.bridgeAADT;
    float growthRate = bridge.trafficGrowthRate;
    // int nSpan = bridgeInfo[6];
    float meanRepair;
    float meanTraffic;
    int days;
    float impCoeff;

	for ( int i = 0; i < impMat.size(); i++ ) {
		if (impMat[i].condition == rating)
			impCoeff = impMat[i].coef;
	}

   /* float CO2 = numeric_limits<float>::infinity();*/
	float CO2 = 0.0f;
	float randomName = 0.0f;
    
    /* calculations fall in to 11 categories depending on its repairID; each has its own equation */
    int categoryOne[] = {1, 7 , 15, 16};
    set<int> one(categoryOne,categoryOne+4);
    int categoryTwo[] = {2};
    set<int> two(categoryTwo,categoryTwo+1);
    int categoryThree[] = {3, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,45};
    set<int> three(categoryThree,categoryThree+14);
    int categoryFour[] = {4, 10};
    set<int> four(categoryFour, categoryFour+2);
    int categoryFive[] = {5};
    set<int> five(categoryFive,categoryFive+1);
    int categorySix[] = {6, 37, 38, 39, 40};
    set<int> six(categorySix, categorySix+5);
    int categorySeven[] = {8, 9, 41, 42, 43, 44, 46, 47, 48, 49, 50};
    set<int> seven(categorySeven, categorySeven+11);
    int categoryEight[] = { 11, 51 }; //need to be modified
    set<int> eight(categoryEight, categoryEight+2); 
    int categoryNine[] = {12, 13, 14};
    set<int> nine(categoryNine, categoryNine+3);
    int categoryTen[] = {17, 18 ,19, 20, 21, 35, 36};
    set<int> ten(categoryTen, categoryTen+ 7);
    int categoryEleven[] = {0}; // original crewID 45 was removed
    set<int> eleven(categoryEleven, categoryEleven +1 );
    
    if (one.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;

                CO2 = meanRepair*deckLength*deckWidth*impCoeff + meanTraffic*AADT*days*pow(1+growthRate, year);
                break;
            }
        } 
        
	} else if(two.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;

                CO2 = meanRepair* 10 * deckWidth*impCoeff + meanTraffic*AADT*days*pow(1+growthRate, year);
                return CO2;
            }
        }
        
    } else if(three.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;

                CO2 = meanRepair * deckWidth * meanTraffic * AADT * days * pow(1+growthRate, year);
                break;
            } 
        }
        
    } else if(four.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
			 if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;

                CO2 = meanRepair*deckLength* 2 * impCoeff;
                break;
             }  
        }
        
    } else if(five.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;

                CO2 = meanRepair*deckLength*deckWidth;
                break;
            }
        } 
        
    } else if(six.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;
                CO2 = meanRepair*deckLength*deckWidth*impCoeff;
                break;
            }
        } 
        
    } else if(seven.count(repairID) == 1) {
        // no information available
        CO2 = 0;
        
    } else if(eight.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;
                // warning: this need to be modified
                CO2 = meanRepair;
                break;
            }
        } 

        
    } else if(nine.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;
                CO2 = meanRepair*deckLength*2*impCoeff*meanTraffic*AADT*days*pow(1+growthRate, year);
                break;
            }
        }  
        
    } else if(ten.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;
                CO2 = meanRepair*deckLength*deckWidth + meanTraffic*AADT*days*pow(1+growthRate, year);
                break;
            }
        } 
      
    } else if(eleven.count(repairID) == 1) {
        
        for (int j = 0; j < repairs.size() ; j++) {
            if (repairs[j].repairID == repairID && (rating <= repairs[j].UB && rating >= repairs[j].LB) ) {
                meanRepair = repairs[j].repairMean;
                meanTraffic= repairs[j].trafficMean;
                days = repairs[j].duration;
                CO2 = meanRepair*deckLength*deckWidth*impCoeff * meanTraffic*AADT*days*pow(1+growthRate, year);
                break;
            }
        } 
    }
    
    
    return CO2;
}



/*
 * Function: calTotalCO2
 * Usage: calTotalCO2( bridgeInfo, optSchedule, repairCO2);
 * -------------------------------------------------------
 * Calculate the total CO2 emission for the optimal Schedule
 * repairCO2: [0]repairID, [1]improvement, [2]condition rating, [3]meanRepair, [4]meanTraffic, [5]days of repair, 
 * [6]improvement coefficient
 */

/* float calTotalCO2(float bridgeInfo[10], int optSchedule[][3], float repairCO2[][7]) {
    float totalCO2 = 0;
    int repairYear;
    int repairID;
    int conditionRating;
    
    for (int i = 0; i < 50; i++) {
        repairYear = optSchedule[i][0];
        repairID = optSchedule[i][1];
        conditionRating = optSchedule[i][2];
        
        if (repairYear == 0) {
            break;
        }
        
        totalCO2 = totalCO2 + calCO2(bridgeInfo, repairYear, repairID, conditionRating, repairCO2);
        
    }
    
    return totalCO2;
}
*/