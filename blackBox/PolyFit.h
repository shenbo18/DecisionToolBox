//
//  polyFit.h
//  optSchedule
//
//  Created by Bo Shen on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef blackBox_PolyFit_h
#define blackBox_PolyFit_h

#include <fstream>
#include "LCO.h"

using namespace std;
using namespace LCO;

/* function declaration */

/*
 * Function: polyFit
 * Usage: polyFit(3, ratings) for quadratic equation.
 * ----------------------------------------------------------------------------------
 * Find coefficients of a linear polynomial model using least-square fitting.
 * for a linear polynomial model y = Xa + err
 * the coefficients vector a that gives the min err is given by inverse(X'X) * X'* y
 */
float* polyFit (int, ComponentRatingMat ratings);  

/*
 * Function: f
 * Usage: f( k, n);
 * ------------------------------------------------------
 * Gives the sum of x raised to the kth power.
 * Needed to construct th augmented matrix.
 */
float f(int,int, float[]);  

/*
 * Function: fy
 * Usage: f( k, n);
 * ---------------------------------------------------------------
 * Gives the sum of x raised to the kth power and multiplied by y
 * Needed to construct th augmented matrix.
 */
float fy(int ,int, float [], float []); 

/* 
 * Function: gaussianElimination
 * Usage: gaussianElimnation(m);
 * ---------------------------------------------------------------
 * Solves m unknown linear equation by using gaussian elimination.
 */
void gaussianElimination(int,float [], float [][10]);    

/*
 * Function: F
 * Usage: F(l,m,a);
 * ------------------------------------------------
 * help function that help to solve linear equation
 */
float F(int,int,float [], float [][10]); 

/*
 * Fuction: promptUserForFile
 * Usage: string filename = prompt UsersForFile(infile,prompt);
 * -----------------------------------------------------------
 * Asks the user for the name of an iput file and opens that reference
 * parameter infile using that name, which is returned as the result of 
 * the function. If the requested file does not exist, the user is 
 * is given additional chances to enter a valid file name. The optional
 * prompt argument is used to give the user more information about the
 * desited iput file.
 */
string promptUserForFile(ifstream & infile, string prompt = "");

/*
 * Function: readData
 * Usgae: readData(x, y, ratings);
 * -----------------------------------------------------------------------------------
 * Convert struct ComponentRatingMat which contains the years and corresponding ratings 
 * into two array of float  
 */
int readData(float[], float[],ComponentRatingMat ratings);

#endif
