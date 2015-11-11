function [ t1,t2,t3,t5,t6,t7, v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_r, Amax_f ] = variedVelocityPlan( Vmax, Vs, Ve, Amax, Jmax )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

Amax_r = Amax;
Amax_f = Amax;
%% accelerate
if (Vmax - Vs)  > Amax^2/Jmax      %加速过程存在匀加速
   t1 = Amax/Jmax;
   t2 = (Vmax-Vs)/Amax - t1;
   t3 = t1;
   
   v1 = Vs + Jmax*t1^2/2;
   s1 = Vs*t1 + (Jmax*t1^3)/6;
   v2 = v1 + Amax*t2;
   s2 = s1 + v1*t2 + Amax*t2^2/2;
   v3 = v2 + Amax*t3 - Jmax*t3^2/2; % equ Vmax
   s3 = s2 + v2*t3 + Amax*t3^2/2 - Jmax*t3^3/6;
else                            %加速过程无匀加速
    t1 = sqrt((Vmax-Vs)/Jmax);
    t2 = 0;
    t3 = t1;
    Amax_r = sqrt((Vmax-Vs)*Jmax);%t1*Jmax
    
    v1 = Vs + Jmax*t1^2/2;
    s1 = Vs*t1 + (Jmax*t1^3)/6;
    v2 = v1 + Amax_r*t2;            %0
    s2 = s1 + v1*t2 + Amax_r*t2^2/2;%0
    v3 = v2 + Amax_r*t3 - Jmax*t3^2/2;
    s3 = s2 + v2*t3 + Amax_r*t3^2/2 - Jmax*t3^3/6;
end
%% decelerate
if (Vmax - Ve) > Amax^2/Jmax
    t5 = Amax/Jmax;
    t6 = (Vmax-Ve)/Amax - t5;
    t7 = t5;
    
    v6 = Ve + Jmax*t7^2/2;    
    s7_6 = Ve*t7 + (Jmax*t7^3)/6;
    v5 = v6 + Amax*t6;            
    s7_5 = s7_6 + v6*t6 + Amax*t6^2/2;
    v4 = v5 + Amax*t5 - Jmax*t5^2/2;                %V
    s7_4 = s7_5 + v5*t5 + Amax*t5^2/2 - Jmax*t5^3/6;
else
    t5 = sqrt((Vmax-Ve)/Jmax);
    t6 = 0;
    t7 = t5;
    Amax_f = sqrt((Vmax-Ve)*Jmax);
    
    v6 = Ve + Jmax*t7^2/2;    
    s7_6 = Ve*t7 + (Jmax*t7^3)/6;
    v5 = v6 + Amax_f*t6;            
    s7_5 = s7_6 + v6*t6 + Amax_f*t6^2/2;
    v4 = v5 + Amax_f*t5 - Jmax*t5^2/2;                %V
    s7_4 = s7_5 + v5*t5 + Amax_f*t5^2/2 - Jmax*t5^3/6;
end








end

