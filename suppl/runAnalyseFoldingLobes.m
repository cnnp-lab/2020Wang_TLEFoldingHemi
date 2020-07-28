clear all
close all


load('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN_lobes.mat')
load('~/GitHub/2020Wang_TLEFoldingHemi/data/TLE_lobes.mat')

%you will need the following libraries on your path:
%https://github.com/bastibe/Violinplot-Matlab
%https://uk.mathworks.com/matlabcentral/fileexchange/70120-beeswarm

%% Correct A_t and A_e for lobes

CamCAN_lobes.At_dash = 4 * pi * CamCAN_lobes.PialArea ./ CamCAN_lobes.GaussianCurvature;
CamCAN_lobes.Ae_dash = 4 * pi * CamCAN_lobes.SmoothPialArea ./ CamCAN_lobes.GaussianCurvature;

tle_controls_lobes.At_dash = 4 * pi * tle_controls_lobes.PialArea ./ tle_controls_lobes.GaussianCurvature;
tle_controls_lobes.Ae_dash = 4 * pi * tle_controls_lobes.SmoothPialArea ./ tle_controls_lobes.GaussianCurvature;

%%

lobes = ["FL" "PL" "TL" "OL"];
d_age=[];
d_TLE=[];

for k=1:4
    
    lobe = lobes(k);
    
    CamCAN = CamCAN_lobes(CamCAN_lobes.Lobe == k,:);
    TLE = tle_controls_lobes(tle_controls_lobes.Lobe == k,:);
    
    % Decides which plot to use
    modstr='';
    
    
    % CamCAN
    DataTable=CamCAN;
    age  = DataTable.Age;
    sex = DataTable.Sex;
    T=DataTable.AvgCortThickness;
    refIDs=find(age<30-2 & age>20+2 & T>2.2);
    cmpIDs=find(age<40-2 & age >30+2 & T>2.2);

    cpmstr='young (ref) vs old'

    pltpath=['figs_' char(lobe) modstr '/CamCAN_25vs35/'];

    close all

    [~,zKIS,~,zoc,At,Ae,Th,K,I,S]=analyseFoldingLobesKIS(DataTable,[],sex,refIDs,cmpIDs,cpmstr,pltpath);%no age regression%no plot

    d_age = [d_age; zoc zKIS];
    
    
    % TLE
    DataTable=TLE;
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

    pltpath=['figs_' char(lobe) modstr '/ipsiTLE/'];

    close all
    [~,zKIS,~,zoc,At,Ae,Th,K,I,S]=...
        analyseFoldingKVS(DataTable,age,sex,refIDs,cmpIDs,cpmstr,pltpath);%with age & sex regression
    close all

    d_TLE = [d_TLE; zoc zKIS];
    
end


%% Get d values for full hemisphere from runAnalyseFolding as d_hemis_age = [zoc zKIS], d_hemis_TLE = [zoc zKIS]

%% Plot differences as vectors

% Plot age vector for hemisphere
plot3([0 d_hemis_age(4)],[0 d_hemis_age(5)],[0 d_hemis_age(6)],'Color','k', 'DisplayName', 'Hemisphere ageing')

p = d_hemis_age(4:6);
a = 0.1;
b = 0.1;

hu = [d_hemis_age(4)-a*(p(1)+b*(p(2)+eps)); d_hemis_age(4); d_hemis_age(4)-a*(p(1)-b*(p(2)+eps))];
hv = [d_hemis_age(5)-a*(p(2)-b*(p(1)+eps)); d_hemis_age(5); d_hemis_age(5)-a*(p(2)+b*(p(1)+eps))];
hw = [d_hemis_age(6)-a*p(3);d_hemis_age(6);d_hemis_age(6)-a*p(3)];


hold on
plot3(hu(:),hv(:),hw(:),'Color','k','HandleVisibility','off')
grid on
xlabel('K')
ylabel('I')
zlabel('S')
title("Difference in mean of the z-scores for ageing (solid) and TLE (dashed)")


% Add TLE vector for hemisphere
plot3([0 d_hemis_TLE(4)],[0 d_hemis_TLE(5)],[0 d_hemis_TLE(6)],'Color','k','LineStyle','--', 'DisplayName', 'Hemisphere TLE')

p = d_hemis_TLE(4:6);
a = 0.1;
b = 0.1;

hu = [d_hemis_TLE(4)-a*(p(1)+b*(p(2)+eps)); d_hemis_TLE(4); d_hemis_TLE(4)-a*(p(1)-b*(p(2)+eps))];
hv = [d_hemis_TLE(5)-a*(p(2)-b*(p(1)+eps)); d_hemis_TLE(5); d_hemis_TLE(5)-a*(p(2)+b*(p(1)+eps))];
hw = [d_hemis_TLE(6)-a*p(3);d_hemis_TLE(6);d_hemis_TLE(6)-a*p(3)];

plot3(hu(:),hv(:),hw(:),'Color','k','HandleVisibility','off')  % Plot arrow head

col = ['r' 'b' 'g' 'm'];

for k = 1:4
    
    lobe = lobes(k);
    
    % Add age vector
    plot3([0 d_age(k,4)],[0 d_age(k,5)],[0 d_age(k,6)],'Color',col(k), 'DisplayName', [char(lobe) ' ageing'])

    p = d_age(k,4:6);
    a = 0.1;
    b = 0.1;

    hu = [d_age(k,4)-a*(p(1)+b*(p(2)+eps)); d_age(k,4); d_age(k,4)-a*(p(1)-b*(p(2)+eps))];
    hv = [d_age(k,5)-a*(p(2)-b*(p(1)+eps)); d_age(k,5); d_age(k,5)-a*(p(2)+b*(p(1)+eps))];
    hw = [d_age(k,6)-a*p(3);d_age(k,6);d_age(k,6)-a*p(3)];

    plot3(hu(:),hv(:),hw(:),'Color',col(k),'HandleVisibility','off')

    
    % Add TLE vector
    plot3([0 d_TLE(k,4)],[0 d_TLE(k,5)],[0 d_TLE(k,6)],'Color',col(k),'LineStyle','--', 'DisplayName', [char(lobe) ' TLE'])

    p = d_TLE(k,4:6);
    a = 0.1;
    b = 0.1;

    hu = [d_TLE(k,4)-a*(p(1)+b*(p(2)+eps)); d_TLE(k,4); d_TLE(k,4)-a*(p(1)-b*(p(2)+eps))];
    hv = [d_TLE(k,5)-a*(p(2)-b*(p(1)+eps)); d_TLE(k,5); d_TLE(k,5)-a*(p(2)+b*(p(1)+eps))];
    hw = [d_TLE(k,6)-a*p(3);d_TLE(k,6);d_TLE(k,6)-a*p(3)];

    plot3(hu(:),hv(:),hw(:),'Color',col(k),'HandleVisibility','off')
    
end

legend()
hold off


%% Bar chart


% Raw variables
all_AAT = [];
for k  = 1:3
    all_AAT = [all_AAT  d_hemis_TLE(k) d_hemis_age(k) d_TLE(1,k) d_age(1,k) d_TLE(2,k) d_age(2,k) d_TLE(3,k) d_age(3,k) d_TLE(4,k) d_age(4,k)];
end

colour = ['k','k','r','r','b','b','g','g','m','m'];
x = [1:10 13:22 25:34];
h_list = []

h=figure, hold on

m = length(colour);
for k = 1:30
    i = mod(k-1,m);
    i = i+1;    
    if mod(k,2) == 0
        h=bar(x(k),all_AAT(k),'LineStyle',':','LineWidth',1.5);
    else
        h=bar(x(k),all_AAT(k));
    end
    set(h,'FaceColor',colour(i));
    h_list(i)=h;
end

ylabel("d")
set(gca,'xticklabel',{'';'\fontsize{20}At';'';'';'\fontsize{20}Ae';'';'\fontsize{20}T';''})
title("Difference in mean of the z-scores for TLE (left, solid bar) and ageing (right, dashed bar) by lobe/hemisphere in raw variables")
legend(h_list(1:2:10),'Hemisphere','FL','PL','TL','OL') 

hold off


% KIS space
all_KIS = [];
for k  = 4:6
    all_KIS = [all_KIS  d_hemis_TLE(k) d_hemis_age(k) d_TLE(1,k) d_age(1,k) d_TLE(2,k) d_age(2,k) d_TLE(3,k) d_age(3,k) d_TLE(4,k) d_age(4,k)];
end

colour = ['k','k','r','r','b','b','g','g','m','m'];
x = [1:10 13:22 25:34];
h_list = []

h=figure, hold on

m = length(colour);
for k = 1:30
    i = mod(k-1,m); 
    i = i+1;    
    if mod(k,2) == 0
        h=bar(x(k),all_KIS(k));
    else
        h=bar(x(k),all_KIS(k),'LineStyle',':','LineWidth',3);
    end
    set(h,'FaceColor',colour(i));
    h_list(i)=h;
end

ylabel("d")
title('\fontsize{20}Difference in mean of the z-scores for TLE (left, dashed bar) and ageing (right, solid bar) by lobe/hemisphere')
legend(h_list(1:2:10),'Hemisphere','Frontal Lobe','Parietal Lobe','Temporal Lobe','Occipital Lobe', 'Location','southeast')
xticks([5.5 17.5 29.5])
set(gca,'xticklabel',{'\fontsize{30}K';'\fontsize{30}I';'\fontsize{30}S'})
set(gca,'TickLength',[0, 0])

hold off


