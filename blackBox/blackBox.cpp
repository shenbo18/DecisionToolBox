#include <iostream>
#include "Input.h"
#include "Output.h"
#include "FindOptSchedule.h"
#include "LCO.h"
#include <Ice/Ice.h>
#include <ctime>
#include "SenStore.h"

using namespace std;
using namespace LCO;
using namespace SenStore;

class BlackBoxI : public BlackBox {
public:
	virtual void optSchedule(const UserInput& userIn, const ComponentRatingMat& ratings, const RepairInfoMat& repairInfo, const ::Ice::Current&);
};


/*
 * Class: BlackBoxI
 * -------------------------------------------------------
 * BlackBoxI is the incarnation of the interface BlackBox
 * It contains the implementation of the operation optSchedule
 */
void 
BlackBoxI::
optSchedule(const UserInput& userIn, const ComponentRatingMat& ratings, const RepairInfoMat& repairUserIn, const ::Ice::Current&)
{	
	int optObj = userIn.optObject;
	OptimizationObjective objective = (OptimizationObjective)(optObj -1);
	EnvImpactType impactType = findEnvImpactType(optObj);
	Unit unit = findUnit(optObj);
	int limit = userIn.ratingLowerLimit;

	/* Server Input */
	ServerInput serverIn;	
	serverIn = readServerInput(userIn.bridgeID, userIn.componentID);

	//ratingsdecay[x][y] is the years taken for rating "x" decreasing to "y" witout maintenance
	int ratingsDecay[10][10];
	ComponentRatingMat ServerRatings = readRatings(userIn.bridgeID,1); // Commented to use the ratings from userInput
	ratingDecay(ratingsDecay,ServerRatings,limit);
	BridgeInfo bridge = bridgeInfoCompiler(userIn, serverIn);
	CostMap costs = readRepairCost(repairUserIn);

	ImproveMat impMat;
	ImpCoef cond4;
	cond4.condition = 4;
	cond4.coef = 0.15;

	ImpCoef cond5;
	cond5.condition = 5;
	cond5.coef = 0.1;

	ImpCoef cond6;
	cond6.condition = 6;
	cond6.coef = 0.05;

	impMat.push_back(cond4);
	impMat.push_back(cond5);
	impMat.push_back(cond6);

	/* prepare envMat */
	RepairBasicInfoMat repairs;
	repairs = readRepairBasicInfo();
	//cout << repairs.size() << endl;
	
	EnvCoefMat envCos;
	envCos = readEnvCoef(optObj);

	//RepairEnvMat envMat;
	//string type = "joint";	
	//envMat = envInfoCompiler(repairUserIn, type, repairs, envCos);

	//RepairSchedule optSchedule;
	//findOptEnvSchedule(bridge, ratingsDecay, envMat, impMat, limit, optSchedule);
	////findOptCostSchedule(bridge, ratingsDecay, envMat, costs, impMat, limit, optSchedule);
	//cout << "Success" << endl;
	
	RepairEnvMat envMat;
	RepairEnvMat envMat2;
	RepairEnvMat envMat3;
	RepairEnvMat envMat4;
	string type;
	RepairSchedule optSchedule;

	switch(serverIn.componentType) {
		case StructureComponentTypeDeck:
			cout << "The selected component is StructureComponentTypeDECK" << endl;
			type = "Deck";
			envMat = envInfoCompiler(repairUserIn, type, repairs, envCos);
			break;
		case StructureComponentTypeAbutment:
			cout << "The selected component is StructureComponentTypeABUTMENT" << endl;
			type = "Foundation";
			envMat = envInfoCompiler(repairUserIn, type, repairs, envCos);
			break;
		case StructureComponentTypePinHanger:
			cout << "The selected component is StructureComponentTypePINHANGER" << endl;
			type = "PinHanger";
			envMat = envInfoCompiler(repairUserIn, type, repairs, envCos);
			break;
		case StructureComponentTypeSpan:
			cout << "The selected component is StructureComponentTypeSPAN" << endl;
			type = "Deck";
			envMat = envInfoCompiler(repairUserIn, type, repairs, envCos);
			type = "Barrier";
			envMat2 = envInfoCompiler(repairUserIn, type, repairs, envCos);
			type = "Joint";
			envMat3 = envInfoCompiler(repairUserIn, type, repairs, envCos);
			type = "Other";
			envMat4 = envInfoCompiler(repairUserIn, type, repairs, envCos);
			break;
		case StructureComponentTypeColumn:
			cout << "The selected component is StructureComponentTypeCOLUMN" << endl;
			type = "Column";
			envMat = envInfoCompiler(repairUserIn, type, repairs, envCos);
			break;
		default:
			throw BlackBoxError("Unidentified ComponentType");
	}
	/* initiate a clock to calculate the computational cost of the algorithm */
	std::clock_t start;
	double duration;
	start = std::clock();
	//date
	double date = sysDate();

	if(optObj == 11) {
			float minCost = findOptCostSchedule(bridge, ratingsDecay, envMat, costs, impMat, limit, optSchedule);
			if (serverIn.componentType==StructureComponentTypeSpan) {
				RepairSchedule optSchedule2;
				RepairSchedule optSchedule3;
				RepairSchedule optSchedule4;
				float minCost2 = findOptCostSchedule(bridge, ratingsDecay, envMat2, costs, impMat, limit, optSchedule2);
				float minCost3 = findOptCostSchedule(bridge, ratingsDecay, envMat3, costs, impMat, limit, optSchedule3);
				float minCost4 = findOptCostSchedule(bridge, ratingsDecay, envMat4, costs, impMat, limit, optSchedule4);
				minCost = minCost + minCost2 + minCost3 + minCost4;
				optSchedule = mergeFourSched(optSchedule,  optSchedule2,  optSchedule3, optSchedule4);
			}
			writeToServer(userIn.bridgeID, userIn.componentID, objective, date, impactType, unit, minCost);
	} else {
			float minCost = findOptEnvSchedule(bridge, ratingsDecay, envMat, impMat, limit, optSchedule);
			if (serverIn.componentType == StructureComponentTypeSpan) {
				RepairSchedule optSchedule2;
				RepairSchedule optSchedule3;
				RepairSchedule optSchedule4;
				float minCost2 = findOptEnvSchedule(bridge, ratingsDecay, envMat2, impMat, limit, optSchedule2);
				float minCost3 = findOptEnvSchedule(bridge, ratingsDecay, envMat3, impMat, limit, optSchedule3);
				float minCost4 = findOptEnvSchedule(bridge, ratingsDecay, envMat4, impMat, limit, optSchedule4);
				minCost = minCost + minCost2 + minCost3 + minCost4;
				optSchedule = mergeFourSched(optSchedule,  optSchedule2,  optSchedule3, optSchedule4);
			}
			writeToServer(userIn.bridgeID, userIn.componentID, objective, date, impactType, unit, minCost);
	}

	duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;
	std::cout<<"Computational Cost:"<< duration <<endl;
}

int main(int argc, char*argv[])
{	
	int status = 0;
	Ice::CommunicatorPtr ic;

	try {
		ic = Ice::initialize(argc, argv);
		Ice::ObjectAdapterPtr adapter
		= ic->createObjectAdapterWithEndpoints("BlackBoxAdapter", "default -p 10000");
		Ice::ObjectPtr object = new BlackBoxI;
		adapter->add(object,ic->stringToIdentity("BlackBox"));
		adapter->activate();
		ic->waitForShutdown();
	} catch (BlackBoxError& ex) {
		cout << ex.reason<<endl;
		status = 1;
	}

	if(ic) {
		try{
			ic->destroy();
		} catch(const Ice::Exception&e) {
			cerr << e << endl;
			status = 1;
		}
	}	

	system("PAUSE");
	return status;
}

