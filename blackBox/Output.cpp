#include "Output.h"

/*
 * Implementation: writeToServer
 * ------------------------------------
 *
 */
int writeToServer(int bridgeID, int componentID, OptimizationObjective objective, double date, EnvImpactType indicator, Unit unit, float value)
{	using namespace std;
	using namespace SenStore;

	char ** fakeArgV = NULL;
	int fakeArgc = 0;
	int status = 0;
	Ice::CommunicatorPtr ic;
	try {
		ic = Ice::initialize(fakeArgc, fakeArgV);
		Ice::ObjectPrx base = ic->stringToProxy("SenStore:default -h panther.eecs.umich.edu -p 10004");
		SenStoreMngrPrx manager = SenStoreMngrPrx::checkedCast(base);
	
		if(!manager)
			throw "Invalid proxy";

		CompEnvBurdenMatrixFields result;
		result.id = bridgeID;
		result.mStructureComponent = componentID;
		result.mOptimizationObjective = objective;
		result. mAssessmentDate = date;
		result.mEnvImpactType = indicator;
		result.mUnits = unit;
		result.mEnvOptimizeValue = value;
		manager->addCompEnvBurdenMatrix(result);

	} catch (const Ice::Exception& ex) {
		std::cerr << ex << endl;
		status  = 1;
	} catch (const char* msg) {
		std::cerr << msg << endl;
		status = 1;
	}
	if (ic)
		ic-> destroy();

	return status;
}

/*
 * Implementation: findEnvImpactType
 * --------------------------------
 *
 */
EnvImpactType findEnvImpactType(int optObj){
	
	EnvImpactType impactType;
	switch (optObj) {
		case 1:
			impactType = EnvImpactTypeGHG;
			break;
		case 2:
			impactType = EnvImpactTypeOZONEDEP;
			break;			
		case 3:
			impactType = EnvImpactTypeSOx;
			break;	
		case 4:
			impactType = EnvImpactTypeEUTPOT;
			break;	
		case 5:
			impactType = EnvImpactTypeHEAVYMET;
			break;	
		case 6:
			impactType = EnvImpactTypeCarcinogens;
			break;	
		case 7:
			impactType = EnvImpactTypeSUMSMOG;
			break;	
		case 8:
			impactType = EnvImpactTypeWINSMOG;
			break;	
		case 9:
			impactType = EnvImpactTypeEnergy;
			break;	
		case 10:
			impactType = EnvImpactTypeSOLWASTE;
			break;	
		case 11:
			impactType = EnvImpactTypeCOST;
			break;	
	}

	return impactType;
}

/*
 * Implementation: findUnit
 * --------------------------------
 *
 */
Unit findUnit(int optObj){
	
	Unit unit;
	switch (optObj) {
		case 9:
			unit = UnitMJ;
			break;	
		case 11:
			unit = UnitMoneyUSD;
			break;	
		default:
			unit =  UnitKILOGRAM;	
	}

	return unit;
}

/*
 * Implementation: sysDate
 * ------------------------------
 *
 */
int sysDate(){
// current date/time based on current system
   time_t now = time(0);

   cout << "Number of sec since January 1,1970:" << now << endl;

   tm *ltm = localtime(&now);
   int year = 1900 + ltm->tm_year;
   int month = 1 + ltm->tm_mon;
   int day = ltm->tm_mday;

   int date = year*10000 + month*100+day;
   return date;
}