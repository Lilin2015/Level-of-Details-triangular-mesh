%% 将Obj文件转化为mat文件，存在Files子目录下
clear
close all
clc
%% 设置
addpath('Files');   addpath('Funcs');
name = '高速车头';
%% 读obj模型文件
fprintf('\n模型读取中...');
OBJ=readObj(strcat(name,'.obj'));
%% 存mat模型文件
V=OBJ.v;    F=OBJ.f.v;
[V,F] = uniformV(V,F); % 统一节点编号
save(strcat(pwd,'\Files\',name,'.mat'),'V','F');