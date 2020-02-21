clear all
close all

% addpath('~/Syncthing/Matlab/lib/')
% addpath('~/Syncthing/Matlab/lib/Violinplot-Matlab-master')

%you will need the following libraries on your path:
%https://github.com/bastibe/Violinplot-Matlab
%https://uk.mathworks.com/matlabcentral/fileexchange/70120-beeswarm

load('~/GitHub/CorticalFoldingTLE/data/CamCAN_MasterTable.mat')
load('~/GitHub/CorticalFoldingTLE/data/tle_controls.mat')

%this decides which plot we want to see, beeswarm is the raw data. '' is
%the bootstrapped mean zscores as in the main paper.
modstr='_beeswarm';
% modstr='';

%% CAMCAN===============================
DataTable=CamCAN_MasterTable;

age  = DataTable.Age;
sex = DataTable.Sex;


T=DataTable.AvgCortThickness;
agecats=[20:10:60];%this defines the rough bounds of the age categories - a bit confusing...


zKIS_CamCAN=zeros(length(agecats)-2,3);
zoc_CamCAN=zeros(length(agecats)-2,3);


slopes_CamCAN=zeros(length(agecats)-2,2);
for ak=1:length(agecats)-2


refIDs=find(age<agecats(ak+1)-2 & age>agecats(ak)+2 & T>2.2);%this defines the actual bounds for age
cmpIDs=find(age<agecats(ak+2)-2 & age >agecats(ak+1)+2 & T>2.2);%this defines the actual bounds for age

cpmstr='young (ref) vs old'

pltpath=['figs' modstr '/CamCAN_' num2str(agecats(ak)+5) 'vs' num2str(agecats(ak)+15) '/']%for shorter folder names just used the center age here

close all
% [mKVS,zKVS]=analyseFoldingKVS(DataTable,age,refIDs,cmpIDs,cpmstr,pltpath)%if you want age regression
% [mKVS,zKVS,moc,zoc,coeff,At,Ae,Th,K,V,S]=analyseFoldingKVS(DataTable,[],sex,refIDs,cmpIDs,cpmstr,pltpath);%no age regression
[~,zKIS,~,zoc,At,Ae,Th,K,I,S]=analyseFoldingKVS(DataTable,[],sex,refIDs,cmpIDs,cpmstr,pltpath);%no age regression%no plot

zKIS_CamCAN(ak,:)=zKIS;
zoc_CamCAN(ak,:)=zoc;


end


%% TLE===============================
DataTable=tle_controls;

age  = DataTable.Age;
sex=DataTable.IsFemale;

T=DataTable.AvgCortThickness;
ctrl = DataTable.IsControl;
lTLE=DataTable.IsLeftTLE;
hemi=DataTable.Hemisphere;


% run ipsilateral TLE vs control
refIDs=find(ctrl==1 & T>2.2);
cmpIDs=find(ctrl==0 & T>2.2 & ((lTLE==1 & hemi=="left") | (lTLE==0 & hemi=="right")));

cpmstr='Ctrl (ref) vs ipsilateral TLE';

pltpath=['figs' modstr '/ipsiTLE/'];

close all
[~,zKIS_ipsiTLE,~,zoc_ipsiTLE,At,Ae,Th,K,I,S]=...
    analyseFoldingKVS(DataTable,age,sex,refIDs,cmpIDs,cpmstr,pltpath)%with age & sex regression



%%
close all
clc
%plots data for last figure on trajectory hypothesis - just with all age categories.
figure(10)

scatter3(zKIS_ipsiTLE(1),zKIS_ipsiTLE(2),zKIS_ipsiTLE(3),30,[0 0.2 1],'filled')
hold on
plot3([0 zKIS_ipsiTLE(1)],[0 zKIS_ipsiTLE(2)],[0 zKIS_ipsiTLE(3)],'Color',[0 0.2 1])

L=length(agecats)-2;
for ak=1:length(agecats)-2
scatter3(zKIS_CamCAN(ak,1),zKIS_CamCAN(ak,2),zKIS_CamCAN(ak,3),30,[ak/L, 0.3, ak/L],'filled')
plot3([0 zKIS_CamCAN(ak,1)],[0 zKIS_CamCAN(ak,2)],[0 zKIS_CamCAN(ak,3)],'Color',[ak/L, 0.3, ak/L])
end


hold off

xlabel('K')
ylabel('V')
zlabel('S')
title('z score KVS')
xlim([-1.5 1.5])
ylim([-1.5 1.5])
zlim([-1.5 1.5])





% 
% figure(12)
% 
% scatter3(zoc_ipsiTLE(1),zoc_ipsiTLE(2),zoc_ipsiTLE(3),30,[0 0.2 1],'filled')
% hold on
% plot3([0 zoc_ipsiTLE(1)],[0 zoc_ipsiTLE(2)],[0 zoc_ipsiTLE(3)],'Color',[0 0.2 1])
% 
% L=length(agecats)-2;
% for ak=1:length(agecats)-2
% scatter3(zoc_CamCAN(ak,1),zoc_CamCAN(ak,2),zoc_CamCAN(ak,3),30,[ak/L, 0.3, ak/L],'filled')
% plot3([0 zoc_CamCAN(ak,1)],[0 zoc_CamCAN(ak,2)],[0 zoc_CamCAN(ak,3)],'Color',[ak/L, 0.3, ak/L])
% end
% 
% hold off
% 
% xlabel('At')
% 
% zlabel('Ae')
% ylabel('T')
% title('mean z scores')
% 
% xlim([-1.5 1.5])
% ylim([-1.5 1.5])
% zlim([-1.5 1.5])
