#include <iostream>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>
#include <string>
#include <iterator>
#include <algorithm>
#include <windows.h>
#include "Input.h"
#include "EnumString.h"
#include <math.h>
#include <stdexcept>
#include "PolyFit.h"
#include "LCO.h"

using namespace std;


/*
 * Implementation: toUpper
 * ------------------------------------
 *
 */
string toUpper(string s) {
    transform(s.begin(),s.end(),s.begin(),::toupper);
    return s;
}

/*
 * Implementation: ratingDecay
 * ----------------------------------------
 * Calculate the years that takes for rating "x" decreasing to "y" witout maintenance
 * by using deteriorate curve obtained from polyFit.
 */
void ratingDecay(int ratingsDecay[][10], ComponentRatingMat ratings, int limit){
    float *coeff = polyFit(3,ratings);
    
    // coefficients of quadratic equation 
    float a = coeff[0];
    float b = coeff[1];
    float c = coeff[2];
    //cout << a << endl;
    //cout << b << endl;
    
    /* validate the data */
    if (a > 0) {
        if ( (-pow(b, 2)+4*a*c)/(4*a) > limit ) {
            throw BlackBoxError("Need more low condition rating data.");
        }
    } else {
        if ( (-pow(b, 2)+4*a*c)/(4*a) < 9 ) {
            throw BlackBoxError("Need more high condition rating data.");
        }
    }
    
    float timePoints[10];
    for (int i = 9; i >limit-1; i--) {
        c = coeff[2] - i;
        timePoints[i] =  (-1*b -sqrt(pow(b, 2)-4*a*c))/(2*a);
        //cout << timePoints[i] << endl;
    }
    
    for (int i = 9; i > limit-1; i--) {
        for (int j = i; j> limit-1; j--) {
            ratingsDecay[i][j] = floor(timePoints[j] - timePoints[i]);
            //cout << ratingsDecay[i][j] << " ";
        }
        //cout << endl;
    }
}

string ExePath() {

  char buffer[MAX_PATH];
  GetModuleFileNameA( NULL, buffer, MAX_PATH );
  return std::string(buffer);
}

/*
 * Implementation: readRepairBasicInfo
 * ------------------------------------
 *
 */
RepairBasicInfoMat readRepairBasicInfo()
{
    RepairBasicInfoMat repairInfoMat;
    
    ifstream infile;
    string filename = "Data\\basicInfo.txt";
	//cout << "my directory is " << ExePath() << "\n";
    infile.open(filename.c_str());
    
	// error handler
	if(!infile.is_open())
	{
		throw BlackBoxError("DataFile Not Found");
	}

	int i = 0;
    while (infile) {
        string line;
        getline(infile, line);
        istringstream stream(line);
        //cout << line << endl;
        
        RepairBasicInfo temp;
        string type;
        stream >> temp.repairID;
        stream >> temp.component;
        stream>> temp.LB >> temp.UB >> temp.improvement;
        repairInfoMat.push_back(temp);
		i ++;
    }
	repairInfoMat.erase(repairInfoMat.begin()+i-1);

    
    //cout << repairInfoMat[0].component;
    //cout << repairInfoMat[0].UB << repairInfoMat[0].LB << repairInfoMat[0].UB << repairInfoMat[0].improvement << endl;
    //
    //cout << repairInfoMat[1].component;
    //cout << repairInfoMat[1].UB << repairInfoMat[1].LB << repairInfoMat[1].UB << repairInfoMat[1].improvement << endl;
	infile.close();
	return repairInfoMat;
}


/*
 * Implementation: readEnvCoef
 * ------------------------------------
 *
 */
EnvCoefMat readEnvCoef(int optObj) {
    string filename;
	
	switch (optObj)
{	
  case 1:
    filename = "Data\\GW.txt";
     break;
	case 2:
     filename = "Data\\ODP.txt";
     break;
    case 3:
     filename = "Data\\AP.txt";
     break;
	   case 4:
      filename = "Data\\EP.txt";
     break;
	   case 5:
      filename = "Data\\HM.txt";
     break;
	case 6:
      filename = "Data\\CG.txt";
     break;
	 case 7:
      filename = "Data\\SS.txt";
     break;
	 case 8:
      filename = "Data\\WS.txt";
     break;
	 case 9:
      filename = "Data\\ER.txt";
     break;
	 case 10:
      filename = "Data\\SW.txt";
     break;
	 case 11:
     filename = "Data\\ER.txt";
     break;
}
	
	EnvCoefMat envCos;
    ifstream infile;
    infile.open(filename.c_str());
    
	// error handler
	if(!infile.is_open())
	{
		throw BlackBoxError("DataFile Not Found");
	}

	int i = 0;
    while (infile) {
        string line;
        getline(infile, line);
        istringstream stream(line);
        EnvCoef temp;
        
		stream >> temp.repairID;
        stream >> temp.repairMean;
        stream >> temp.trafficMean;
        envCos.push_back(temp);
		i++;
    }
    envCos.erase(envCos.begin()+i-1);
    //cout << envCos[0].repairID << envCos[0].repairMean << envCos[0].trafficMean;
    
	infile.close();
	return envCos;
}


/*
 * Implementation: bridgeInfoCompiler
 * ------------------------------------
 *
 */
BridgeInfo bridgeInfoCompiler(UserInput userIn, ServerInput serverIn) {
	BridgeInfo bridge;
	bridge.bridgeID = userIn.bridgeID;
	bridge.bridgeWidth = serverIn.bridgeWidth;//*0.3048;			//Unit Conversion from ft to m
	bridge.bridgeLength = serverIn.bridgeLength;//*0.3048;			//Unit Conversion from ft to m
	bridge.bridgeAADT = userIn.bridgeAADT;
	bridge.bridgeAADTT = userIn.bridgeAADTT;
	bridge.startYear = userIn.startYear;
	bridge.startRating = userIn.startRating;
	bridge.discountRate = userIn.discountRate;
	bridge.trafficGrowthRate = userIn.trafficGrowthRate;
	
	return bridge;
}

/*
 * Implementation: envInfoCompiler
 * ------------------------------------
 *
 */
RepairEnvMat envInfoCompiler(RepairInfoMat repairUserIn, string componentType, RepairBasicInfoMat &basicInfo, EnvCoefMat &envMat) {
	
	RepairEnvMat repairEnv;
	
	for(int i = 0; i < repairUserIn.size(); i++) {
		if( repairUserIn[i].avail == true) {
			int countBasic = 0; // cout whether find basicInfo
			int countBasicType = 0; // count whether find basicInfo with matched Type
			int countEnv = 0; // cout whether find envCoeff
			RepairEnv temp;
			temp.repairID = repairUserIn[i].repairID;		
			temp.duration = repairUserIn[i].duration;
			
			for(int j = 0; j < basicInfo.size(); j++) {
				if( basicInfo[j].repairID == repairUserIn[i].repairID) {
					countBasic++;
					if(basicInfo[j].component == componentType) {
						temp.LB = basicInfo[j].LB;
						temp.UB = basicInfo[j].UB;
						temp.improvement = basicInfo[j].improvement;
						countBasicType++;
						break;
					}
				}
			}

			if (countBasic == 0)
				throw BlackBoxError("Repair Basic Info Not Found");
			
			for(int k = 0; k < envMat.size(); k++) {
				if( envMat[k].repairID == repairUserIn[i].repairID) {
					temp.repairMean = envMat[k].repairMean;
					temp.trafficMean = envMat[k].trafficMean;
					countEnv ++;
					break;
				}
			}
			
			if (countEnv == 0)
				throw BlackBoxError("Repair Env Coeff Not Found");
				
			if (countBasicType == 1 && countEnv == 1)
				repairEnv.push_back(temp);
		}
	}

	return repairEnv;

} 

/*
 * Implementation: readRepairCost
 * --------------------------------
 *
 */
CostMap readRepairCost(RepairInfoMat repairUserIn){
	CostMap costs;
	for(int i = 0; i < repairUserIn.size(); i++) {
		if( repairUserIn[i].avail == true) {	
			costs[repairUserIn[i].repairID] = repairUserIn[i].cost;
		}
	}
	return costs;
}

/*
 * Implementation: readServerInput
 * --------------------------------
 *
 */
ServerInput readServerInput(int bridgeID, int componentID){

using namespace SenStore;
int status = 0;

//int argc;
//char* argv[];
ServerInput serverIn;

Ice::CommunicatorPtr ic;
char ** fakeArgV = NULL;
int fakeArgc = 0;
try {
	ic = Ice::initialize(fakeArgc, fakeArgV);
	Ice::ObjectPrx base = ic->stringToProxy("SenStore:default -h panther.eecs.umich.edu -p 10004");
	SenStoreMngrPrx manager = SenStoreMngrPrx::checkedCast(base);

	if(!manager)
		throw "Invalid proxy";
	
	IdList OIDs;

	BridgeDetailsFields bridgeDetails;
	bridgeDetails.mStructure = bridgeID;
	//FieldNameList names(1,"Structure");

	//OIDs = manager->findEqualBridgeDetails(bridgeDetails,names);
	//if (OIDs.size() == 0)
	//	throw BlackBoxError("Bridge Details Not Found");
	bridgeDetails = manager->getBridgeDetailsFields(bridgeID);
	
	StructureComponentFields componentDetails;
	componentDetails = manager->getStructureComponentFields(componentID);

	serverIn.bridgeLength = bridgeDetails.mBridgeLength;
	serverIn.bridgeWidth = bridgeDetails. mOutToOutWidth;
	serverIn.componentType = componentDetails.mType;

	//if(componentDetails.mType == StructureComponentTypeDeck)
	//	cout << "Deck";

	cout << "the bridge length is " << bridgeDetails.mBridgeLength << endl;
	cout << "the deck width is " << bridgeDetails. mOutToOutWidth << endl;

} catch (const Ice::Exception& ex) {
	std::cerr << ex << endl;
	throw ex;
} catch (const char* msg) {
	std::cerr << msg << endl;
	throw msg;
	status = 1;
}
if (ic)
ic-> destroy();

return serverIn;
}

/*
 * Implementation: readRatings
 * ----------------------------
 * 
 */
ComponentRatingMat readRatings(int bridgeID, int componentID){

	using namespace SenStore;

	ComponentRatingMat ratings;
	vector<int> comRat;
	vector<int> years;

	int status = 0;
	Ice::CommunicatorPtr ic;
	char ** fakeArgV = NULL;
	int fakeArgc = 0;
	try {
		ic = Ice::initialize(fakeArgc, fakeArgV);
		Ice::ObjectPrx base = ic->stringToProxy("SenStore:default -h panther.eecs.umich.edu -p 10004");
		SenStoreMngrPrx manager = SenStoreMngrPrx::checkedCast(base);
	
		if(!manager)
			throw "Invalid proxy";
		
			StructureComponentAssessmentFields assessment;
			StructureComponentAssessmentFieldsList allAssess;

			assessment.mComponent = componentID;
			assessment.mBridgeInspection = bridgeID;
			IdList list;
			FieldNameList names;
			names.push_back("Component");
			names.push_back("BridgeInspection");

			list = manager->findEqualStructureComponentAssessment(assessment,names);
			if (list.size() < 3) 
				throw BlackBoxError( "More Ratings Are Needed");

			allAssess = manager->getStructureComponentAssessmentFieldsList(list);

			for (int j = 0; j < allAssess.size(); j++) {
				years.push_back(allAssess[j].mAssessmentDate/10000);
				comRat.push_back(allAssess[j].mRating);
			}   
    
			ratings.ratings = comRat;
			ratings.years = years;
			
	} catch (const Ice::Exception& ex) {
		std::cerr << ex << endl;
		status  = 1;
	} catch (const char* msg) {
		std::cerr << msg << endl;
		status = 1;
	}
	if (ic)
		ic-> destroy();

    return ratings;
}

