%% �����񣬽��򻯹��̼�¼��Record��Ŀ¼��
clear
close all
clc
warning off
%% ����
addpath('Files');   addpath('Funcs');
name = '�����г�ת���';
step = 0.1; %ÿһ���������ٶ���
rate = 0.4; %�ܹ��������ٶ���
%% ��matģ���ļ�
load(strcat(name,'.mat'));
%% ��ģ��
simV = V; simF = F;
Vn = size(simV,1);  Vnum = Vn;
Vtarget = Vnum*rate;
count = 1;
Vrecord{1} = simV; Frecord{1} = simF;
while Vnum > Vtarget
    fprintf('\n��%d�ּ򻯣���ǰ�ڵ㱣������%0.2f%%',[count,100*Vnum/Vn]);
    [ simV,simF ] = simplification( simV,simF,1-step);
    count = count + 1;
    Vrecord{count} = simV; Frecord{count} = simF;
    Vnum = size(simV,1);
end
fprintf('\n����ϣ���ǰ�ڵ㱣������%0.2f%%',100*Vnum/Vn);
%% ����򻯹��̵ļ�¼��Record�ļ���
save(strcat(pwd,'\Record\',name,'_record.mat'),'Vrecord','Frecord');
