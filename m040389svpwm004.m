function [sys,x0,str,ts] = m040389svpwm004(t,x,u,flag,Udc)
 tsam=0.02/20/100;
switch flag,
      case 0,
    [sys,x0,str,ts]=Initialization(tsam,Udc);
      case {1,2,4,9},
    sys=[];
      case 3,
    sys=mdlOutputs(t,x,u,Udc);
      otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end
function [sys,x0,str,ts]=Initialization(tsam,Udc)
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 3;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   %1个采样时间
sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [tsam 0];

function sys=mdlOutputs(t,x,u,Udc)
%输入电压矢量的幅值Ve和相位Ph
Ve=u(1);
Ph=u(2);
te=u(3);
du=pi/3;
%定义控制每个矢量的开关信号
u0=[0 0 0];
u4=[1 0 0];
u6=[1 1 0];
u2=[0 1 0];
u3=[0 1 1];
u1=[0 0 1];
u5=[1 0 1];
u7=[1 1 1];
%判断输入矢量位于哪个扇区，从而选择相应的ua,ub,Phe.(为计算ta,tb,t0);
if Ph>0&&Ph<=du
    Phe=Ph;
    h=1;
    ua=u4;
    ub=u6;
elseif Ph>du&&Ph<=2*du
    Phe=2*du-Ph;
    h=2;
    ua=u2;
    ub=u6;
elseif Ph>2*du&&Ph<=3*du
    Phe=Ph-2*du;
    h=3;
    ua=u2;
    ub=u3;
elseif Ph>-3*du&&Ph<=-2*du;
    Phe=-Ph-2*du;
    h=4;
    ua=u1;
    ub=u3;
elseif Ph>-2*du&&Ph<=-du;
    Phe=Ph+2*du;
    h=5;
    ua=u1;
    ub=u5;
else
    Phe=-Ph;
    h=6;
    ua=u4;
    ub=u5;
end
%计算ta,tb,tc(ms)
ta=1.5*(cos(Phe)-1/sqrt(3)*sin(Phe))*Ve*te/Udc;
tb=sqrt(3)*Ve*sin(Phe)*te/Udc;
t0=te-ta-tb;
if t0<0;
    ta=ta/(ta+tb)*te;
    tb=te-ta;
end
%判断开关时间
tw=0.02/20;
t1=rem(t,tw);
if t1<t0/4;
    y=u0;
elseif t1<(t0/4+ta/2)
    y=ua;
elseif t1<(t0/4+ta/2+tb/2)
    y=ub;
elseif t1<(t0/4+ta/2+tb/2+t0/2)
    y=u7;
elseif t1<(t0/4+ta/2+tb/2+t0/2+tb/2)
    y=ub;
elseif t1<(t0/4+ta/2+tb/2+t0/2+tb/2+ta/2)
    y=ua;
else y=u0;
end
%输出
sys=[y(1,1),y(1,2),y(1,3)];

