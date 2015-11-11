

%20 30  100 30
%20 30  100 9 
%20 60  100 30
%20 60  100 8
%60 30  100 30
%60 20  100 7
%20 30  50  30
%20 30  70  5
%mm

Amax = 1500;        %mm/s2
Jmax = 50000;       %mm/s3
Vs = 20;
Ve = 30;
V = 100;
s = 9; 

Amax_real_1 = Amax;%acc
Amax_real_2 = Amax;%dec

%% 变速段规划
[t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(V, Vs, Ve, Amax, Jmax );
Sacc = s3;
Sdec = s7_4;
%% 典型情况含匀速
if Sacc + Sdec < s
    t4 = (s - Sacc - Sdec)/V;    
%% 不含匀速段，恰好最大速度到V
elseif Sacc + Sdec == s
    t4 = 0;    
%% 不含匀速段，最大速度达不到V，需重新计算Vmax    
else
    t4 = 0;
    Vmax_1 = max(Vs,Ve) + Amax^2/Jmax;
    %无匀加速，5段
    %Vs=Ve,4段
    %无匀减速，5段
    [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax_1, Vs, Ve, Amax, Jmax );
    Sacc = s3;
    Sdec = s7_4;
    Smax_1 = Sacc + Sdec;
    if Smax_1 == s
        Vmax = Vmax_1;
        %t如上所求
    elseif Smax_1 < s
        Vmax = -1*Amax^2/2/Jmax + sqrt(Amax^4 - 2*Jmax*(Amax^2*(Vs+Ve)-Jmax*(Vs^2+Ve^2)-2*Amax*Jmax*s))/2/Jmax;
        %再来变速规划，实际上现在是6段
        [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax, Vs, Ve, Amax, Jmax );
    else%Smax_1 > s,匀加、匀减不同时存在
        Vmax_2 = min(Vs,Ve) + Amax^2/Jmax;
        %变速规划
        [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax_2, Vs, Ve, Amax, Jmax );
        Sacc = s3;
        Sdec = s7_4;
        Smax_2 = Sacc + Sdec;
        if Smax_2 == s
            Vmax = Vmax_2;
            %t如上
        else
            %Smax_2 < s,五段，匀加或匀减取决于Vs Ve
            %Smax_2 > s,四段
            %从头开始，除了第一个速度规划，之后几个的段数是确定的
            %但是还是都重新比较,确定段数，可以只调用一个函数
            
            %Smax是Vmax的单增函数，迭代法，Vmax取值范围[Vmax_left, Vmax_right]
            if Smax_2 < s
                Vmax_left = Vmax_2;
                Vmax_right = Vmax_1;
            else
                Vmax_left = min(Ve,Vs);
                Vmax_right = Vmax_2;
            end
            
            Vmax_n = [];
            n = 1;
            Smax_n = 0;
            maxErr = 0.0001;
            while( abs(Smax_n-s) > maxErr)
                Vmax_n(n) = (Vmax_left+Vmax_right)/2;
                %计算Smax_n
                [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax_n(n), Vs, Ve, Amax, Jmax );
                Sacc = s3;
                Sdec = s7_4;
                Smax_n = Sacc + Sdec;
                
                if(Smax_n < s)
                    Vmax_left = Vmax_n(n);
                else
                    Vmax_right = Vmax_n(n);
                end
                n = n + 1;
            end
            Vmax = Vmax_n(n-1);
            %此时的t在刚才的最后一次循环中已有  
        end
    end
end%重新计算Vmax
%%
%s也已计算出，由于减速段用的逆向，看作加速，还要算一下
s4 = s3 + v3*t4; %v3就是Vmax，不需重新规划则是V
s5 = s4 + (s7_4-s7_5);
s6 = s5 + (s7_5-s7_6);
s7 = s6 + s7_6;%即为s
T1 = t1;
T2 = T1 + t2;
T3 = T2 + t3;
T4 = T3 + t4;
T5 = T4 + t5;
T6 = T5 + t6;
T7 = T6 + t7;

t = 0:0.001:T7;
%v = (t<t1)*(Vs + Jmax*t^2/2);
v = ((t<T1) & (t>=0)).*(Vs + Jmax*t.^2/2) + (t<T2 & t>= T1).*(v1 + Amax_real_1*(t-T1)) + (t<T3 & t>= T2).*(v2 + Amax_real_1*(t-T2) - Jmax*(t-T2).^2/2) +  (t<T4 & t>= T3)*v3 +    (t<T5 & t>= T4).*(v4 - Jmax*(t-T4).^2/2)  +    (t<T6 & t>= T5).*(v5 - Amax_real_2*(t-T5)) + (t<T7 & t>= T6).*(v6 - Amax_real_2*(t-T6) + Jmax*(t-T6).^2/2);

plot(t,v, 'r');
%axis([0,0.45,0,110]);
