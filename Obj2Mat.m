%% ��Obj�ļ�ת��Ϊmat�ļ�������Files��Ŀ¼��
clear
close all
clc
%% ����
addpath('Files');   addpath('Funcs');
name = '���ٳ�ͷ';
%% ��objģ���ļ�
fprintf('\nģ�Ͷ�ȡ��...');
OBJ=readObj(strcat(name,'.obj'));
%% ��matģ���ļ�
V=OBJ.v;    F=OBJ.f.v;
[V,F] = uniformV(V,F); % ͳһ�ڵ���
save(strcat(pwd,'\Files\',name,'.mat'),'V','F');