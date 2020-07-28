clear all
close all


load('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN_MasterTable.mat')
load('~/GitHub/2020Wang_TLEFoldingHemi/data/tle_controls.mat')

Cam_area_lh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN/aparc_area_lh.txt');
Cam_area_rh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN/aparc_area_rh.txt');
Cam_meancurv_lh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN/aparc_meancurv_lh.txt');
Cam_meancurv_rh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN/aparc_meancurv_rh.txt');

TLE_area_lh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/data/TLEall/aparc_area_lh.txt');
TLE_area_rh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/data/TLEall/aparc_area_rh.txt');
TLE_meancurv_lh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/TLEall/data/aparc_meancurv_lh.txt');
TLE_meancurv_rh = readtable('~/GitHub/2020Wang_TLEFoldingHemi/TLEall/data/aparc_meancurv_rh.txt');

%you will need the following libraries on your path:
%https://github.com/bastibe/Violinplot-Matlab
%https://uk.mathworks.com/matlabcentral/fileexchange/70120-beeswarm

% Decides which plot to use
modstr='';

%% Compute weighted average mean curvature for each subject

% For CamCAN
for k = 1:size(Cam_meancurv_lh,1)
    % lh
    Cam_meancurv_lh.AvgCurv(k) = sum(table2array(Cam_meancurv_lh(k,2:35)) .* table2array(Cam_area_lh(k,2:35)))/sum(table2array(Cam_area_lh(k,2:35)));
    
    % rh
    Cam_meancurv_rh.AvgCurv(k) = sum(table2array(Cam_meancurv_rh(k,2:35)) .* table2array(Cam_area_rh(k,2:35)))/sum(table2array(Cam_area_rh(k,2:35)));

end

% For TLE
for k = 1:size(TLE_meancurv_lh,1)
    % lh
    TLE_meancurv_lh.AvgCurv(k) = sum(table2array(TLE_meancurv_lh(k,2:35)) .* table2array(TLE_area_lh(k,2:35)))/sum(table2array(TLE_area_lh(k,2:35)));
    
    % rh
    TLE_meancurv_rh.AvgCurv(k) = sum(table2array(TLE_meancurv_rh(k,2:35)) .* table2array(TLE_area_rh(k,2:35)))/sum(table2array(TLE_area_rh(k,2:35)));

end


%% Join sets for CamCAN

Cam_meancurv_lh.Hemisphere = repmat("left", [size(Cam_meancurv_lh,1),1]);
Cam_meancurv_rh.Hemisphere = repmat("right", [size(Cam_meancurv_rh,1),1]);

Cam_meancurv_lh.Properties.VariableNames{1} = 'SubjectID';
Cam_meancurv_rh.Properties.VariableNames{1} = 'SubjectID';

Cam_meancurv = vertcat(Cam_meancurv_lh(:,[1 38 39]), Cam_meancurv_rh(:,[1 38 39]));

Cam_meancurv.SubjectID = string(Cam_meancurv.SubjectID);
Cam_meancurv.SubjectID = strip(Cam_meancurv.SubjectID, 'right', '/');

CamCAN = innerjoin(CamCAN_MasterTable, Cam_meancurv);

%% Join sets for TLE

TLE_meancurv_lh.Hemisphere = repmat("left", [size(TLE_meancurv_lh,1),1]);
TLE_meancurv_rh.Hemisphere = repmat("right", [size(TLE_meancurv_rh,1),1]);

TLE_meancurv_lh.Properties.VariableNames{1} = 'SubjectID';
TLE_meancurv_rh.Properties.VariableNames{1} = 'SubjectID';

TLE_meancurv = vertcat(TLE_meancurv_lh(:,[1 38 39]), TLE_meancurv_rh(:,[1 38 39]));

TLE_meancurv.SubjectID = string(TLE_meancurv.SubjectID);
TLE_meancurv.SubjectID = extractBefore(TLE_meancurv.SubjectID, ["_"]);

TLE = innerjoin(tle_controls, TLE_meancurv);

%% Regress out sex/ sex&age

% Regress sex out of CamCAN
DataTable = CamCAN;
age  = DataTable.Age;
sex = DataTable.Sex;
T=DataTable.AvgCortThickness;
refIDs_Cam=find(age<30-2 & age>20+2 & T>2.2);
cmpIDs_Cam=find(age<40-2 & age >30+2 & T>2.2);

At = DataTable.PialArea;
Ae = DataTable.SmoothPialArea;
GM = DataTable.GreymatterVol;
WV = DataTable.WhiteFullVol;
AC = DataTable.AvgCurv;

At = log10(At); Ae = log10(Ae); T = log10(T); GM = log10(GM); WV = log10(WV); AC = log10(AC);

vars = table(At(refIDs_Cam),Ae(refIDs_Cam),T(refIDs_Cam),GM(refIDs_Cam),WV(refIDs_Cam),AC(refIDs_Cam), sex(refIDs_Cam));
vars.Properties.VariableNames={'At','Ae','T','GM','WV','AC','sex'};
vars.sex = categorical(vars.sex);
fitAt = fitlm(vars,'At~sex');
fitAe = fitlm(vars,'Ae~sex');
fitT = fitlm(vars,'T~sex');
fitGM = fitlm(vars,'GM~sex');
fitWV = fitlm(vars,'WV~sex');
fitAC = fitlm(vars,'AC~sex');

vars = table(At,Ae,T,GM,WV,AC,sex);
vars.Properties.VariableNames={'At','Ae','T','GM','WV','AC','sex'};
vars.sex = categorical(vars.sex);
ypred=predict(fitAt,vars);At = At - ypred;
ypred=predict(fitAe,vars);Ae = Ae - ypred;
ypred=predict(fitT,vars);T = T - ypred;
ypred=predict(fitGM,vars);GM = GM - ypred;
ypred=predict(fitWV,vars);WV = WV - ypred;
ypred=predict(fitAC,vars);AC = AC - ypred;

% Use 2*log(T)
CamCAN = [At,Ae,2*T,GM,WV,AC];



% Regress sex and age out of TLE
DataTable = TLE;
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
GM = DataTable.GreymatterVol;
WV = DataTable.WhiteFullVol;
AC = DataTable.AvgCurv;

At = log10(At); Ae = log10(Ae); T = log10(T); GM = log10(GM); WV = log10(WV); AC = log10(AC);

vars = table(At(refIDs_TLE),Ae(refIDs_TLE),T(refIDs_TLE),GM(refIDs_TLE),WV(refIDs_TLE),AC(refIDs_TLE),age(refIDs_TLE), sex(refIDs_TLE));
vars.Properties.VariableNames={'At','Ae','T','GM','WV','AC','age','sex'};
vars.sex = categorical(vars.sex);
fitAt = fitlm(vars,'At~age+sex');
fitAe = fitlm(vars,'Ae~age+sex');
fitT = fitlm(vars,'T~age+sex');
fitGM = fitlm(vars,'GM~age+sex');
fitWV = fitlm(vars,'WV~age+sex');
fitAC = fitlm(vars,'AC~age+sex');

vars = table(At,Ae,T,GM,WV,AC,age, sex);
vars.Properties.VariableNames={'At','Ae','T','GM','WV','AC','age','sex'};
vars.sex = categorical(vars.sex);
ypred=predict(fitAt,vars);At = At - ypred;
ypred=predict(fitAe,vars);Ae = Ae - ypred;
ypred=predict(fitT,vars);T = T - ypred;
ypred=predict(fitGM,vars);GM = GM - ypred;
ypred=predict(fitWV,vars);WV = WV - ypred;
ypred=predict(fitAC,vars);AC = AC - ypred;

TLE = [At,Ae,2*T,GM,WV,AC];

%% Standardise data

CamCAN_std = (CamCAN - mean(CamCAN(refIDs_Cam,:))) ./ std(CamCAN(refIDs_Cam,:));
TLE_std = (TLE - mean(TLE(refIDs_TLE,:))) ./ std(TLE(refIDs_TLE,:));

%% PCA on both sets of controls individually

coeff_Cam = pca(CamCAN_std(refIDs_Cam,:))
coeff_TLE = pca(TLE_std(refIDs_TLE,:))

%% PCA on combined controls

controls = [CamCAN_std(refIDs_Cam,:); TLE_std(refIDs_TLE,:)];
[coeff, ~, ~, ~, expl] = pca(controls)

plot(expl)
title("Percent of variation explained by PCs")
xlabel("PC")
ylabel("Percent")

CamCAN_PCA = CamCAN_std*coeff;
TLE_PCA = TLE_std*coeff;

%% Plot TLE

cpmstr='Ctrl (ref) vs ipsilateral TLE';

pltpath=['figs_full_PCA' modstr '/ipsiTLE/'];

[mPC,zPC]=analyseFoldingPCA(TLE_PCA,refIDs_TLE,cmpIDs_TLE,cpmstr,pltpath);

%% Plot CamCAN

cpmstr='young (ref) vs old'

pltpath=['figs_full_PCA' modstr '/CamCAN_25vs35/']

[mPC,zPC]=analyseFoldingPCA(CamCAN_PCA,refIDs_Cam,cmpIDs_Cam,cpmstr,pltpath);






