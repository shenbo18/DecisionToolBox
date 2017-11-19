#ifndef blackBox_Output_h
#define blackBox_Output_h

#include "SenStore.h"
#include <Ice/Ice.h>
#include <iostream>
#include <ctime>

using namespace std;
using namespace SenStore;

/*
 * Function: writeToServer
 * Usage: writeToServer();
 * -----------------------------------------------------------------------------
 * Write the optimization results to the corresponding table in the data server.
 */
int writeToServer(int bridgeID, int componentID, OptimizationObjective objective, double date, EnvImpactType indicator, Unit unit, float value);

/* 
 * Function: findEnvImpactType
 * Usage: findEnvImpactType(optObj);
 * -----------------------------------------------------------
 * find corresponding EnvImpactType given the optimization Obj;
 */
EnvImpactType findEnvImpactType(int optObj);

/* 
 * Function: findUnit
 * Usage: findUnit(optObj);
 * -----------------------------------------------------------
 * find corresponding Unit given the optimization Obj;
 */
Unit findUnit(int optObj);

/*
 * Function: sysDate
 * Usage: sysDate();
 * -----------------------------------------------
 * Return the date in required format in Senstore
 */
int sysDate();























# endif