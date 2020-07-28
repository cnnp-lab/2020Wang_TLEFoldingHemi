clear all
close all

%you will need the following libraries on your path:
%https://github.com/bastibe/Violinplot-Matlab
%https://uk.mathworks.com/matlabcentral/fileexchange/70120-beeswarm

load('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN_MasterTable.mat')
load('~/GitHub/2020Wang_TLEFoldingHemi/data/tle_controls.mat')

% Decides which plot to use
modstr='';

%%

% Regress sex out of CamCAN
DataTable = CamCAN_MasterTable;
age  = DataTable.Age;
sex = DataTable.Sex;
T=DataTable.AvgCortThickness;

refIDs_Cam=find(age<30-2 & age>20+2 & T>2.2);
cmpIDs_Cam=find(age<40-2 & age >30+2 & T>2.2);

At = DataTable.PialArea;
Ae = DataTable.SmoothPialArea;

At = log10(At); Ae = log10(Ae); T = log10(T);

vars = table(At(refIDs_Cam),Ae(refIDs_Cam),T(refIDs_Cam), sex(refIDs_Cam));
vars.Properties.VariableNames={'At','Ae','T','sex'};
vars.sex = categorical(vars.sex);
fitAt = fitlm(vars,'At~sex');
fitAe = fitlm(vars,'Ae~sex');
fitT = fitlm(vars,'T~sex');

vars = table(At,Ae,T,sex);
vars.Properties.VariableNames={'At','Ae','T','sex'};
vars.sex = categorical(vars.sex);
ypred=predict(fitAt,vars);At = At - ypred;
ypred=predict(fitAe,vars);Ae = Ae - ypred;
ypred=predict(fitT,vars);T = T - ypred;

% Convert to log(T^2)
CamCAN = [At,Ae,2*T];


% Regress sex and age out of TLE
DataTable = tle_controls;
age  = DataTable.Age;
sex=DataTable.IsFemale;
T=DataTable.AvgCortThickness;
ctrl = DataTable.IsControl;
lTLE=DataTable.IsLeftTLE;
hemi=DataTable.Hemisphere;
refIDs_TLE=find(ctrl==1 & T>2.2);
cmpIDs_TLE=find(ctrl==0 & T>2.2 & ((lTLE==1 & hemi=="left") | (lTLE==0 & hemi=="right")));

At = DataTable.PialArea;
Ae = DataTable.SmoothPialArea;
T  = DataTable.AvgCortThickness;
At = log10(At); Ae = log10(Ae); T = log10(T);

vars = table(At(refIDs_TLE),Ae(refIDs_TLE),T(refIDs_TLE),age(refIDs_TLE), sex(refIDs_TLE));
vars.Properties.VariableNames={'At','Ae','T','age','sex'};
vars.sex = categorical(vars.sex);
fitAt = fitlm(vars,'At~age+sex');
fitAe = fitlm(vars,'Ae~age+sex');
fitT = fitlm(vars,'T~age+sex');

vars = table(At,Ae,T,age, sex);
vars.Properties.VariableNames={'At','Ae','T','age','sex'};
vars.sex = categorical(vars.sex);
ypred=predict(fitAt,vars);At = At - ypred;
ypred=predict(fitAe,vars);Ae = Ae - ypred;
ypred=predict(fitT,vars);T = T - ypred;

TLE = [At,Ae,2*T];

%% Standardise data wrt. reference cohorts

CamCAN_std = (CamCAN - mean(CamCAN(refIDs_Cam,:))) ./ std(CamCAN(refIDs_Cam,:));
TLE_std = (TLE - mean(TLE(refIDs_TLE,:))) ./ std(TLE(refIDs_TLE,:));


%% PCA on both sets of controls individually

coeff_Cam = pca(CamCAN_std(refIDs_Cam,:))
coeff_TLE = pca(TLE_std(refIDs_TLE,:))


%% PCA on combined controls

controls = [CamCAN_std(refIDs_Cam,:); TLE_std(refIDs_TLE,:)];
coeff = pca(controls)

CamCAN_PCA = CamCAN_std*coeff;
TLE_PCA = TLE_std*coeff;

%% Plot TLE

cpmstr='Ctrl (ref) vs ipsilateral TLE';

pltpath=['figs_PCA' modstr '/ipsiTLE/'];

[mPC,zPC]=analyseFoldingPCA(TLE_PCA,refIDs_TLE,cmpIDs_TLE,cpmstr,pltpath);


%% Plot CamCAN

cpmstr='young (ref) vs old';

pltpath=['figs_PCA' modstr '/CamCAN_25vs35/']

[mPC,zPC]=analyseFoldingPCA(CamCAN_PCA,refIDs_Cam,cmpIDs_Cam,cpmstr,pltpath);




