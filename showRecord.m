%% ��ʾ�򻯹���
clear
close all
clc
%% ����
addpath('Record');
name = '�����г�ת���';
%% ��ʾ����
load(strcat(name,'_record.mat'));
for i = 1 : size(Vrecord,2)
    figure;
    trimesh(Frecord{i}, Vrecord{i}(:,1), Vrecord{i}(:,2), Vrecord{i}(:,3),'LineWidth',1,'EdgeColor','k');
end