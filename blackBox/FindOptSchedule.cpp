#include <iostream>
#include <math.h>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <limits>
#include <set>
#include "FindOptSchedule.h"
#include "EnvImpact.h"
/* 
 * Function: findOptEnvSchedule
 * Usage: findOptEnvSchedule(bridgeInfo, ratingsDecay, reparis, repairs, impMat, optSchedule);
 * -----------------------------------------------------------------------------------------------------------
 * This function generates a optimal schedule for environmental impact by using a dynamic programing algorithm.
 * Returns the minimum envImpact
 */
float findOptEnvSchedule(BridgeInfo bridge, int ratingsDecay[][10], RepairEnvMat repairs, ImproveMat impMat, int limit, RepairSchedule &optSchedule) {
    
    //record the track to the target M[x][y] by memorizing its precessors
    int preX[101][9],preY[101][9],preRepair[101][9];
    
    //M[x][y] is the best cost achived so far for year "x" to get rating of "y"
    float M[101][9];
    //Initialization of M
    for(int i=0; i<101; i++)
        for(int j=0; j<9;j++)
            M[i][j]=0;
  
	int startRating = bridge.startRating;


    //boundary conditions
    for(int rating = startRating-1; rating >limit-1; rating--) {
        for (int year = ratingsDecay[startRating][rating+1]; year <= ratingsDecay[startRating][rating];year++){
            for(int i = 8; i> 0; i--){
                if (i >= rating)
                    M[year][i] = 0;
                else
                    M[year][i] = numeric_limits<float>::infinity();
                
                preX[year][i] = -1;
                preY[year][i] = 0;
                preRepair[year][i] = 0;
            }
        }
    }
	
	//cout << "\n";
	//cout << "output1:" << calEnvImpact(bridge, 0, repairs[0].repairID, 4, repairs, impMat) << endl;
	//cout << "output2:" <<  calEnvImpact(bridge, 0, repairs[0].repairID, 5, repairs, impMat) << endl;
	//cout << "output3:" <<   calEnvImpact(bridge, 0, repairs[0].repairID, 6, repairs, impMat) << endl;

    /* fill in the two dimension array M[x][y] is the best cost achived so far for year "x" to get rating of "y" */
    for(int year=0;year<101; year++){
        
        
        for(int rating=limit; rating<9; rating++ ){
            // boundary condition that has been defined previously
            if ( rating <= startRating && ratingsDecay[startRating][rating] >= year){

                continue;

            } else {

                // initialize the minimum cost to a very large number.
                // any number smaller than this will replace the original
                float min= numeric_limits<float>::infinity();
                float tempCost=0;
                
                for(int i=rating+1;i<9;i++){//i = rating, or i = rating+1 control whether year can be equal to yearDecay

                    int yearDecay=year-ratingsDecay[i][rating];
					// repairs can not happen before the startYear
                    if(yearDecay < 0)
						break;

                    float repairCost= numeric_limits<float>::infinity();
                    int repairId=0;
                    
                    for (int j=limit;j<i;j++){
                        for (int k=0;k<repairs.size();k++){
							float tempRepairCost;
		
							// improve rating to certain level, the condition is hard-coded
							if (i == 7 && repairs[k].improvement == 7 && (j <= repairs[k].UB && j >= repairs[k].LB)) {
								tempRepairCost = calEnvImpact(bridge, yearDecay, repairs[k].repairID, j, repairs, impMat);
								if (tempRepairCost < repairCost) {
									repairId = repairs[k].repairID;
									repairCost = tempRepairCost;
								}
							} else if (repairs[k].improvement==i-j && (j <= repairs[k].UB && j >= repairs[k].LB) ) {								
                        	    // improve rating by certain level
                                tempRepairCost = calEnvImpact(bridge, yearDecay, repairs[k].repairID, j, repairs, impMat);
								if (tempRepairCost < repairCost) {
									repairId = repairs[k].repairID;
									repairCost = tempRepairCost;
								}
							} 
                        }

       //                 if(year == 14 && yearDecay == 14 && i == 7 && j == 6)
							//cout << "Satisfied Condition";

                        tempCost=M[yearDecay][j]+ repairCost;
                        //cout << tempCost << endl;
                        if (tempCost <= min && tempCost!=0 && preX[yearDecay][j]!=yearDecay){//prevent multiple repairs happen in the same year
                            //cout <<"temp cost:"<< tempCost << "year" << year <<  "rating" << rating << endl;
                            min=tempCost;
                            preX[year][rating]=yearDecay;
                            preY[year][rating]=j;
                            preRepair[year][rating]=repairId;
                        }

                    }
                }

				M[year][rating]=min;

            }
            //cout << "updated" << "year" << year <<  "rating" << rating << "min" << min <<endl;
        }
    }
    
    /* outputs the optimal schedule to a text file */
    int x=100;
    int y=5;
    float minTotalCost = numeric_limits<float>::infinity();
    int optFinalCondition;
    ofstream ofile("Optimal Maintenance Schedule");
    for (int i = limit; i < 8; i++) {
        x = 100;
        y = i;
        
        ofile << "Final Condition:" << i << endl;
        ofile << "Best Estimate Cost:" << M[x][i] << endl;
        if (M[x][i] < minTotalCost) {
            minTotalCost = M[x][i];
            optFinalCondition = i;
        }
        ofile << "     Year  RepairID" << endl;
        
        while (preX[x][y]>= 0){
            ofile << setw(8) << preX[x][y];
            ofile << setw(8) << preRepair[x][y];
            ofile << setw(8) << preY[x][y] << endl;
            int temp = x;
            x=preX[x][y];
            y=preY[temp][y];
        }
    }
    ofile.close();
    
    /* update the optSchedule Matrix */
    x = 100;
    y = optFinalCondition;
    cout << "The Minimum Emission/Cost is " << minTotalCost << endl;
    int k = 0;
	RepairSchedule temp;
    while (preX[x][y]>-1 && preRepair[x][y]>0){
		Pair oneRepair;
        cout << setw(8) << preX[x][y];
		oneRepair.repairYear = preX[x][y] + bridge.startYear;
        cout  << setw(8) << preRepair[x][y];
        oneRepair.repairID = preRepair[x][y];
        cout << setw(8) << preY[x][y] << endl;
		temp.push_back(oneRepair);
        int temp = x;
        x=preX[x][y];
        y=preY[temp][y];
        k ++;
    }
	for( int n = temp.size()-1; n >-1;n--) {
		optSchedule.push_back(temp[n]);
	}

	return minTotalCost;
    
}


/* 
 * Function: findOptCostSchedule
 * Usage: findOptCostSchedule(bridgeInfo, ratingsDecay, repairsER, costs, impMat, optSchedule);
 * -----------------------------------------------------------------------------------------------------------
 * This function generates a optimal schedule for environmental impact by using a dynamic programing algorithm.
 * Returns the minimum envImpact
 */
float findOptCostSchedule(BridgeInfo bridge, int ratingsDecay[][10], RepairEnvMat repairs, CostMap costs, ImproveMat impMat, int limit, RepairSchedule &optSchedule) {
    
    //record the track to the target M[x][y] by memorizing its precessors
    int preX[101][9],preY[101][9],preRepair[101][9];
    
    //M[x][y] is the best cost achived so far for year "x" to get rating of "y"
    float M[101][9];
    //Initialization of M
    for(int i=0; i<101; i++)
        for(int j=0; j<9;j++)
            M[i][j]=0;
  
	int startRating = bridge.startRating;
	float r = bridge.discountRate;

    //boundary conditions
    for(int rating = startRating-1; rating >limit-1; rating--) {
        for (int year = ratingsDecay[startRating][rating+1]; year <= ratingsDecay[startRating][rating];year++){
            for(int i = 8; i> 0; i--){
                if (i >= rating)
                    M[year][i] = 0;
                else
                    M[year][i] = numeric_limits<float>::infinity();
                
                preX[year][i] = -1;
                preY[year][i] = 0;
                preRepair[year][i] = 0;
            }
        }
    }
	
	//cout << "\n";
	//cout << "output1:" << calEnvImpact(bridge, 0, repairs[0].repairID, 4, repairs, impMat) << endl;
	//cout << "output2:" <<  calEnvImpact(bridge, 0, repairs[0].repairID, 5, repairs, impMat) << endl;
	//cout << "output3:" <<   calEnvImpact(bridge, 0, repairs[0].repairID, 6, repairs, impMat) << endl;

    /* fill in the two dimension array M[x][y] is the best cost achived so far for year "x" to get rating of "y" */
    for(int year=0;year<101; year++){
        
        
        for(int rating=limit; rating<9; rating++ ){
            // boundary condition that has been defined previously
            if ( rating <= startRating && ratingsDecay[startRating][rating] >= year){

                continue;

            } else {

                // initialize the minimum cost to a very large number.
                // any number smaller than this will replace the original
                float min= numeric_limits<float>::infinity();
                float tempCost=0;
                
                for(int i=rating;i<9;i++){

                    int yearDecay=year-ratingsDecay[i][rating];
                    if(yearDecay < 0)
						break;

                    float repairCost= numeric_limits<float>::infinity();
                    int repairId=0;
                    
                    for (int j=limit;j<i;j++){
                        for (int k=0;k<repairs.size();k++){
							float tempRepairCost;
		
							// improve rating to certain level, the condition is hard-coded
							if (i == 7 && repairs[k].improvement == 7 && (j <= repairs[k].UB && j >= repairs[k].LB)) {
								float factor = costs[repairs[k].repairID];
								tempRepairCost = calEnvImpact(bridge, yearDecay, repairs[k].repairID, j, repairs, impMat)*factor/pow(r+1, yearDecay);
								if (tempRepairCost < repairCost) {
									repairId = repairs[k].repairID;
									repairCost = tempRepairCost;
								}
							} else if (repairs[k].improvement==i-j && (j <= repairs[k].UB && j >= repairs[k].LB) ) {								
                        	    // improve rating by certain level
								float factor = costs[repairs[k].repairID];
                                tempRepairCost = calEnvImpact(bridge, yearDecay, repairs[k].repairID, j, repairs, impMat)*factor/pow(r+1, yearDecay);
								if (tempRepairCost < repairCost) {
									repairId = repairs[k].repairID;
									repairCost = tempRepairCost;
								}
							} 
                        }
                        
                        tempCost=M[yearDecay][j]+ repairCost;
                        //cout << tempCost << endl;
                        if (tempCost < min && tempCost!=0 && preX[yearDecay][j]!=yearDecay){//every year only perform one repair
                            //cout <<"temp cost:"<< tempCost << "year" << year <<  "rating" << rating << endl;
                            min=tempCost;
                            preX[year][rating]=yearDecay;
                            preY[year][rating]=j;
                            preRepair[year][rating]=repairId;
                        }

                    }
                }

				M[year][rating]=min;

            }
            //cout << "updated" << "year" << year <<  "rating" << rating << "min" << min <<endl;
        }
    }
    
    /* outputs the optimal schedule to a text file */
    int x=100;
    int y=5;
    float minTotalCost = numeric_limits<float>::infinity();
    int optFinalCondition;
    ofstream ofile("Optimal Maintenance Schedule");
    for (int i = limit; i < 8; i++) {
        x = 100;
        y = i;
        
        ofile << "Final Condition:" << i << endl;
        ofile << "Best Estimate Cost:" << M[x][i] << endl;
        if (M[x][i] < minTotalCost) {
            minTotalCost = M[x][i];
            optFinalCondition = i;
        }
        ofile << "     Year  RepairID" << endl;
        
        while (preX[x][y]>= 0){
            ofile << setw(8) << preX[x][y];
            ofile << setw(8) << preRepair[x][y];
            ofile << setw(8) << preY[x][y] << endl;
            int temp = x;
            x=preX[x][y];
            y=preY[temp][y];
        }
    }
    ofile.close();
    
    /* update the optSchedule Matrix */
    x = 100;
    y = optFinalCondition;
    cout << "The Minimum Emission/Cost is " << minTotalCost << endl;
    int k = 0;
	RepairSchedule temp;
    while (preX[x][y]>-1 && preRepair[x][y]>0){
		Pair oneRepair;
        cout << setw(8) << preX[x][y];
		oneRepair.repairYear = preX[x][y] + bridge.startYear;
        cout  << setw(8) << preRepair[x][y];
        oneRepair.repairID = preRepair[x][y];
        cout << setw(8) << preY[x][y] << endl;
		temp.push_back(oneRepair);
        int temp = x;
        x=preX[x][y];
        y=preY[temp][y];
        k ++;
    }
	for( int n = temp.size()-1; n >-1;n--) {
		optSchedule.push_back(temp[n]);
	}

	return minTotalCost;
    
}

/*
 * Implementation: mergeFourSched
 * ------------------------------
 *
 */
RepairSchedule mergeFourSched(RepairSchedule vec1, RepairSchedule vec2, RepairSchedule vec3, RepairSchedule vec4) {

	RepairSchedule result;
	RepairSchedule::iterator itStart[4];
	RepairSchedule::iterator itEnd[4];
	
	itStart[0] = vec1.begin();
	itStart[1] = vec2.begin();
	itStart[2] = vec3.begin();
	itStart[3] = vec4.begin();
	
	itEnd[0] = vec1.end();
	itEnd[1] = vec2.end();
	itEnd[2] = vec3.end();
	itEnd[3] = vec4.end();

	bool ends[4];

	for (int j = 0; j < 4; j ++){
		ends[j] = false;
	}


	while(!(ends[0] && ends[1] && ends[2] && ends[3])) {

		int min = 9999;
		int min_i = 5;

		for (int i = 0; i < 4; i ++) {
			if ( (!ends[i]) && (itStart[i]->repairYear <= min)) {
				min_i = i;
				min = itStart[i]->repairYear;
			}
		}

		if (min_i == 5) break;

		result.push_back(*(itStart[min_i]));

		
		if (itStart[min_i] != itEnd[min_i]) {
			itStart[min_i] ++;
			if (itStart[min_i] == itEnd[min_i])
			ends[min_i] = true;
		}
	}

	return result;
	
}
