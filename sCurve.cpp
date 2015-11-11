// sCurve.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <iostream>
using namespace std;

void planVelocity(double distance, double timeLimit, double t1AccScale, double period);


int _tmain(int argc, _TCHAR* argv[])
{
	planVelocity(1100, 9.75, 0.22,0.00025);

	return 0;
}

/*	
*	Function Name	:
*	Description		: 没有匀速运动阶段，在一定时间内走固定距离；走的距离短，没有匀速阶段
*	Parameter			:
					Name			Type		Description
					---------------------------------------
					distance		double		reference unit
					timeLimit		double		ms,Motion should be completed in the timeLimit time.
					t1AccScale	double		T1/(T1+T2+T3), generally T1=T3,so it's in (0,0.5]
					period			double		s
*
*
*/

void planVelocity(double distance, double timeLimit, double t1AccScale, double period)
{
	double Vmax = 0;
	double Amax = 0;
	double Jmax = 0;

	Vmax = (distance/timeLimit)*2*1000;// rfu/s  //Vmax/2 = Vaverage
	Amax = Vmax/(timeLimit*(1-t1AccScale)/2)*1000;// rfu/s2
	Jmax = Amax/(timeLimit*t1AccScale/2)*1000;// rfu/s3

	double T1,T2,T3,T4,T5,T6,T7;//s
	T1 = timeLimit/2*t1AccScale/1000;
	T2 = timeLimit/2/1000 - 2*T1;
	T3 = T1;
	T4 = 0;
	T5 = T1;
	T6 = T2;
	T7 = T1;
	

	double v1,v2,v3,v4,v5,v6,v7;//rfu/s
	v1 = Jmax*T1*T1/2;
	v2 = v1 + Amax*T2;
	v3 = Vmax;
	v4 = v3;//Vmax
	v5 = v2;
	v6 = v1;
	v7 = 0;

	double s1,s2,s3,s4,s5,s6,s7;// rfu
	s1 = Jmax*T1*T1*T1/6;
	s2 = s1 + v1*T2 + Amax*T2*T2/2;
	s3 = s2 + v2*T3 + Amax*T3*T3/2 - Jmax*T3*T3*T3/6;
	s4 = s3;
	s5 = s4 + s3 - s2;
	s6 = s5 + s2 - s1;
	s7 = s6 + s1;//distance
	
	double v[50];
	int n1,n2,n3,n4,n5,n6,n7;
	n1 = T1/period;
	n2 = T2/period;
	n3 = n1;
	n4 = 0;
	n5 = n1;
	n6 = n2;
	n7 = n1;

	int count = 0;
	int i;
	for(i=1; i<n1; i++)
	{
		v[count] = Jmax*period*i*period*i/2;
		count++;
	}
	for(i = 0; i<=n2; i ++)
	{
		v[count] = v1 + Amax*i*period;
		count++;
	}
	for(i=0; i<n3; i++)
	{
		v[count] = v2 + Amax*i*period - Jmax*i*period*i*period/2;
		count++;
	}
	for(i=0; i<n5+n6+n7; i++)
	{
		v[count] = v[count-2*i-1];
		count++;
	}

	double length1Cycle[50];
	for(i=0; i<count; i++)
	{
		length1Cycle[i] = v[i]*period;
	}

	double lengthRemain;
	double sLength[50];
	sLength[0] = length1Cycle[0];
	for(i=1; i<count; i++)
	{
		sLength[i] = sLength[i-1] + length1Cycle[i];
	}
	lengthRemain = distance - sLength[count-1];
	//////////////////////////////////////////////////////////////////
	for(i=0; i<count; i++)
	{
		v[i] = v[i] + lengthRemain/count/period;
	}
	for(i=0; i<count; i++)
	{
		length1Cycle[i] = length1Cycle[i]+ lengthRemain/count;
	}
	sLength[0] = length1Cycle[0];
	for(i=1; i<count; i++)
	{
		sLength[i] = sLength[i-1] + length1Cycle[i];
	}
	lengthRemain = distance - sLength[count-1];

	double sum;
	int pulse[50];
	int totalPulse[50];
	pulse[0] = (int)(sLength[0] + 0.5);
	totalPulse[0] = pulse[0]  ;
	for(i=1; i<count; i++)
	{
		pulse[i] = (int)(sLength[i] - sLength[i-1] + 0.5);
		totalPulse[i] = totalPulse[i-1] + pulse[i];
	}
	cout << totalPulse[count-1] <<endl;
	////////////////////////////////////////////////////////////////////
	cout << lengthRemain << endl;
	cout <<"T:"<< T1 <<","<<T2<<","<<T3<<","<<T4<<","<<T5<<","<<T6<<","<<T7 <<endl;
	cout <<"V:"<< v1 <<","<<v2<<","<<v3<<","<<v4<<","<<v5<<","<<v6<<","<<v7 <<endl;
	cout <<"S:"<< s1 <<","<<s2<<","<<s3<<","<<s4<<","<<s5<<","<<s6<<","<<s7<< endl;
	cout <<"N:"<< n1 <<","<<n2<<","<<n3<<","<<n4<<","<<n5<<","<<n6<<","<<n7<< endl;

	FILE * fp0 = fopen("vs_v.txt", "w");
	FILE * fp1 = fopen("vs_lenCycle.txt", "w");
	FILE * fp2 = fopen("vs_length.txt", "w");
	FILE * fp3 = fopen("vs_pulse.txt", "w");
	/*FILE * fp4 = fopen("test5.txt", "w");*/
	for (int i= 0; i < count; i++)
	{
		fprintf(fp0, "%.3f", v[i]);
		fprintf(fp0, "%s", "\n");
	}
	fclose(fp0);

	for (int i= 0; i < count; i++)
	{
		fprintf(fp1, "%.3f", length1Cycle[i]);
		fprintf(fp1, "%s", "\n");
	}
	fclose(fp1);
	for (int i= 0; i < count; i++)
	{
		fprintf(fp2, "%.3f", sLength[i]);
		fprintf(fp2, "%s", "\n");
	}
	fclose(fp2);

	for (int i= 0; i < count; i++)
	{
		fprintf(fp3, "%d", totalPulse[i]);
		fprintf(fp3, "%s", "\n");
	}
	fclose(fp3);

	cin >> i;

}

//按照正常，没有时间限制，重载函数
//void planVelacity()