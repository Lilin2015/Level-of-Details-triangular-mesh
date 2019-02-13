%% 显示简化过程
clear
close all
clc
%% 设置
addpath('Record');
name = '高速列车转向架';
%% 显示过程
load(strcat(name,'_record.mat'));
for i = 1 : size(Vrecord,2)
    figure;
    trimesh(Frecord{i}, Vrecord{i}(:,1), Vrecord{i}(:,2), Vrecord{i}(:,3),'LineWidth',1,'EdgeColor','k');
end