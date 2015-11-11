

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

%% ���ٶι滮
[t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(V, Vs, Ve, Amax, Jmax );
Sacc = s3;
Sdec = s7_4;
%% �������������
if Sacc + Sdec < s
    t4 = (s - Sacc - Sdec)/V;    
%% �������ٶΣ�ǡ������ٶȵ�V
elseif Sacc + Sdec == s
    t4 = 0;    
%% �������ٶΣ�����ٶȴﲻ��V�������¼���Vmax    
else
    t4 = 0;
    Vmax_1 = max(Vs,Ve) + Amax^2/Jmax;
    %���ȼ��٣�5��
    %Vs=Ve,4��
    %���ȼ��٣�5��
    [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax_1, Vs, Ve, Amax, Jmax );
    Sacc = s3;
    Sdec = s7_4;
    Smax_1 = Sacc + Sdec;
    if Smax_1 == s
        Vmax = Vmax_1;
        %t��������
    elseif Smax_1 < s
        Vmax = -1*Amax^2/2/Jmax + sqrt(Amax^4 - 2*Jmax*(Amax^2*(Vs+Ve)-Jmax*(Vs^2+Ve^2)-2*Amax*Jmax*s))/2/Jmax;
        %�������ٹ滮��ʵ����������6��
        [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax, Vs, Ve, Amax, Jmax );
    else%Smax_1 > s,�ȼӡ��ȼ���ͬʱ����
        Vmax_2 = min(Vs,Ve) + Amax^2/Jmax;
        %���ٹ滮
        [t1,t2,t3,t5,t6,t7,v1,v2,v3,v4,v5,v6,s1,s2,s3,s7_6,s7_5,s7_4,Amax_real_1,Amax_real_2] = variedVelocityPlan(Vmax_2, Vs, Ve, Amax, Jmax );
        Sacc = s3;
        Sdec = s7_4;
        Smax_2 = Sacc + Sdec;
        if Smax_2 == s
            Vmax = Vmax_2;
            %t����
        else
            %Smax_2 < s,��Σ��ȼӻ��ȼ�ȡ����Vs Ve
            %Smax_2 > s,�Ķ�
            %��ͷ��ʼ�����˵�һ���ٶȹ滮��֮�󼸸��Ķ�����ȷ����
            %���ǻ��Ƕ����±Ƚ�,ȷ������������ֻ����һ������
            
            %Smax��Vmax�ĵ�����������������Vmaxȡֵ��Χ[Vmax_left, Vmax_right]
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
                %����Smax_n
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
            %��ʱ��t�ڸղŵ����һ��ѭ��������  
        end
    end
end%���¼���Vmax
%%
%sҲ�Ѽ���������ڼ��ٶ��õ����򣬿������٣���Ҫ��һ��
s4 = s3 + v3*t4; %v3����Vmax���������¹滮����V
s5 = s4 + (s7_4-s7_5);
s6 = s5 + (s7_5-s7_6);
s7 = s6 + s7_6;%��Ϊs
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
