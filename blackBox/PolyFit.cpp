
//  polyFit.cpp
//  optSchedule
//
//  Created by Bo Shen on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "PolyFit.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <string>
#include <math.h>
#include <stdlib.h>

using namespace std;
using namespace LCO;


/*
 * Function: polyFit
 * Usage: polyFit(n,3) for quadratic equation.
 * -------------------------------------------
 * Find coefficients of a linear polynomial model using least-square fitting.
 * for a linear polynomial model y = Xa + err
 * the coefficients vector a that gives the min err is given by inverse(X'X) * X'* y
 */
float* polyFit(int k, ComponentRatingMat ratings) 
{   float a[10];           /*  array contains coefficients */
    float b[10][10];       /* augmented matrix */ 
    float x[15],y[15];   /* sample points coordinates */
    int n; /* number of sample points */

    n = readData( x, y, ratings);
    
    /* augmented matrix used when solve the linear equation */
    for(int i=1;i<=k;i++)
    {
        for(int j=1;j<=k;j++)
            b[i][j]=f(i+j-2,n,x);
        b[i][k+1]=fy(i-1,n,x,y);
    }
    
    b[1][1]=n;
    gaussianElimination(k, a, b);
    //cout << endl;
    
    /* for quadratic equation only*/
    float *coeff = new float[3];
    for (int i = 3; i > 0; i--) {
        coeff[3-i] = a[i];
        //cout << coeff[3-i]<< endl;
    }
    return coeff;
}

/*
 * Function: f
 * Usage: f( k, n);
 * ----------------
 * Gives the sum of x raised to the kth power.
 * Needed to construct th augmented matrix.
 */
float f(int k,int n,float* x)//function gives sum of x[i]
{
    float sum=0;
    for(int i=0;i<n;i++)
        sum+=pow(x[i],k);
    return sum;
}

/*
 * Function: fy
 * Usage: f( k, n);
 * ----------------
 * Gives the sum of x raised to the kth power and multiplied by y
 * Needed to construct th augmented matrix.
 */
float fy(int k,int n, float *x, float *y) 
{
    float sum=0;
    for(int i=0;i<n;i++)
        sum+=y[i]*pow(x[i],k);
    return sum;
}


/* 
 * Function: gaussianElimination
 * Usage: gaussianElimnation(m);
 * -----------------------------
 * Solves m unknown linear equation by using gaussian elimination.
 */
void gaussianElimination(int m, float a[], float b[][10])
{
    for(int k=1;k<m;k++) 
    {
        for(int i=k+1;i<m+1;i++)
        {
            float p1;
            if(b[k][k]!=0)
                p1=b[i][k]/b[k][k];
            for(int j=k;j<m+2;j++) 
                b[i][j]=b[i][j]-b[k][j]*p1;
        }
    }
    a[m]=b[m][m+1]/b[m][m];
    for(int l=m-1;l>=1;l--)   
        a[l]=(b[l][m+1]-F(l+1,m,a,b))/b[l][l];
    //cout<<endl<<endl;
    //cout<<"Best fitting equation:y=";    // 4 decimal digits
    //if(a[1]!=0)
    //    cout<<setiosflags(ios::fixed)<< setprecision(4)<<a[1];
    //for(int i=2;i<m+1;i++) 
    //{
    //    if(a[i]>0)
    //        cout<<" + "<<setiosflags(ios::fixed)<< setprecision(4)<<a[i]<<"*X"<<"["<<i-1<<"]";
    //    else if(a[i]<0)
    //        cout<<setiosflags(ios::fixed)<< setprecision(4)<< a[i]<<"*X"<<"["<<i-1<<"]";
    //}
    
}

/*
 * Function: F
 * Usage: F(l,m,a);
 * ----------------
 * help function that help to solve linear equation
 */
float F(int l,int m,float c[],float b[][10])
{
    float sum=0;
    for(int i=l;i<=m;i++)
        sum+=b[l-1][i]*c[i];
    return sum; 
}

/*
 * Function: readData
 * Usgae: readData();
 * ------------------
 * Reads data file and returns the number of data points 
 */
int readData(float x[], float y[], ComponentRatingMat ratings){
    int n= 0; // number of the data points
  
	for(int i = 0; i < ratings.ratings.size(); i++) {
		x[i] = ratings.years[i]-ratings.years[0];
		y[i] = ratings.ratings[i];
		n++;
	}

    return n;
}


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
string promptUserForFile(ifstream & infile, string prompt) {
    //cin.get();
    while (true) {
        cout << prompt;
        string filename;
        cin >> filename;
        infile.open(filename.c_str());
        if (!infile.fail()) return filename;
        infile.clear();
        cout << "Unable to open that file. Try again." << endl;
        if (prompt == "") {
            prompt = "Please enter filename containing source text: ";
        }
    }
}
