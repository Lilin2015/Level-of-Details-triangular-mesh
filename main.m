%% 简化网格，将简化过程记录在Record子目录下
clear
close all
clc
warning off
%% 设置
addpath('Files');   addpath('Funcs');
name = '高速列车转向架';
step = 0.1; %每一步消除多少顶点
rate = 0.4; %总共保留多少顶点
%% 读mat模型文件
load(strcat(name,'.mat'));
%% 简化模型
simV = V; simF = F;
Vn = size(simV,1);  Vnum = Vn;
Vtarget = Vnum*rate;
count = 1;
Vrecord{1} = simV; Frecord{1} = simF;
while Vnum > Vtarget
    fprintf('\n第%d轮简化，当前节点保留比例%0.2f%%',[count,100*Vnum/Vn]);
    [ simV,simF ] = simplification( simV,simF,1-step);
    count = count + 1;
    Vrecord{count} = simV; Frecord{count} = simF;
    Vnum = size(simV,1);
end
fprintf('\n简化完毕，当前节点保留比例%0.2f%%',100*Vnum/Vn);
%% 保存简化过程的记录到Record文件夹
save(strcat(pwd,'\Record\',name,'_record.mat'),'Vrecord','Frecord');
