function [mKVS,zKIS,moc,zoc,varargout]=analyseFoldingKVS(DataTable,age,sex,refIDs,cmpIDs,cpmstr,pltpath)

if ~isempty(pltpath)
    mkdir(pltpath)

    if contains(pltpath,'beeswarm')
        plt_format='beeswarm';
    else
        plt_format='mean_ci';
    end
    
    if contains(pltpath,'normedKSV')%makes no difference when using z-scores
        normKIS=1;
    else
        normKIS=0;
    end
else
    normKIS=0;
    plt_format='mean_ci';

end






savepdf=1;
if savepdf==1
    fmstr='-dpdf';
else
    fmstr='-dpng';
end

close all;
%% load features
At = DataTable.PialArea;
Ae = DataTable.SmoothPialArea;
T  = DataTable.AvgCortThickness;
GM = DataTable.GreymatterVol;



% log all main features
At = log10(At); Ae = log10(Ae); T = log10(T); GM = log10(GM);


if isempty(age) && isempty(sex) % no age or sex correction
    
    b = mean(At(refIDs));
    At = At - b;

    b = mean(Ae(refIDs));
    Ae = Ae - b;

    b = mean(T(refIDs));
    T = T - b;

    b = mean(GM(refIDs));
    GM = GM - b;
elseif isempty(sex) && ~isempty(age)%apply age correction only
    factors = [ones(size(refIDs)), age(refIDs)]; % offset, age

    b = regress(At(refIDs), factors);
    At = At - (b(1)+b(2)*age);

    b = regress(Ae(refIDs), factors);
    Ae = Ae - (b(1)+b(2)*age);

    b = regress(T(refIDs), factors);
    T = T - (b(1)+b(2)*age);

    b = regress(GM(refIDs), factors);
    GM = GM - (b(1)+b(2)*age);
elseif ~isempty(sex) && isempty(age)%apply sex correction only
    vars = table(At(refIDs),Ae(refIDs),T(refIDs),GM(refIDs), sex(refIDs));
    vars.Properties.VariableNames={'At','Ae','T','GM','sex'};
    vars.sex = categorical(vars.sex);
    fitAt = fitlm(vars,'At~sex');
    fitAe = fitlm(vars,'Ae~sex');
    fitT = fitlm(vars,'T~sex');
    fitGM = fitlm(vars,'GM~sex');
    
    vars = table(At,Ae,T,GM,sex);
    vars.Properties.VariableNames={'At','Ae','T','GM','sex'};
    vars.sex = categorical(vars.sex);
    ypred=predict(fitAt,vars);At = At - ypred;
    ypred=predict(fitAe,vars);Ae = Ae - ypred;
    ypred=predict(fitT,vars);T = T - ypred;
    ypred=predict(fitGM,vars);GM = GM - ypred;
    
else % age & sex regression
    %factors = [ones(size(refIDs)), age(refIDs), sex(refIDs)]; % offset, age
    vars = table(At(refIDs),Ae(refIDs),T(refIDs),GM(refIDs),age(refIDs), sex(refIDs));
    vars.Properties.VariableNames={'At','Ae','T','GM','age','sex'};
    vars.sex = categorical(vars.sex);
    fitAt = fitlm(vars,'At~age+sex');
    fitAe = fitlm(vars,'Ae~age+sex');
    fitT = fitlm(vars,'T~age+sex');
    fitGM = fitlm(vars,'GM~age+sex');
    
    vars = table(At,Ae,T,GM,age, sex);
    vars.Properties.VariableNames={'At','Ae','T','GM','age','sex'};
    vars.sex = categorical(vars.sex);
    ypred=predict(fitAt,vars);At = At - ypred;
    ypred=predict(fitAe,vars);Ae = Ae - ypred;
    ypred=predict(fitT,vars);T = T - ypred;
    ypred=predict(fitGM,vars);GM = GM - ypred;
    

end

%% plot Ae, At & T


data=[At(refIDs);At(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];

h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0);
end
title(['A_t - ' cpmstr])
[~,p,~,stats]=ttest2(At(refIDs),At(cmpIDs));%for those who love p-values... I use a ttest in any case, as comparing bootstrapped mean values in a ttest would not be fair.

zoc(1)=d;
dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/At'],fmstr)
end

data=[Ae(refIDs);Ae(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title(['A_e - ' cpmstr])
[~,p,~,stats]=ttest2(Ae(refIDs),Ae(cmpIDs));

zoc(2)=d;
dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/Ae'],fmstr)
end

data=[T(refIDs);T(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title(['T - ' cpmstr])
[~,p,~,stats]=ttest2(T(refIDs),T(cmpIDs));

zoc(3)=d;
dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/T'],fmstr)
end

% data=[GM(refIDs);GM(cmpIDs)];
% group=[zeros(size(refIDs)); ones(size(cmpIDs))];
% h=figure();
% switch plt_format
%     case 'beeswarm'
%         beeswarm(group,data,'sort_style','hex','overlay_style','ci');
%         d=cohensD(data,group);
%     otherwise
%         d=plotStdzdBootCI(group,data,0)
% end
% title(['Vol - ' cpmstr])
% [~,p,~,stats]=ttest2(GM(refIDs),GM(cmpIDs));
% 
% dim = [.4 .8 .2 .1];
% str = ['p=' num2str(p) ' d=' num2str(d)];
% a=annotation('textbox',dim,'String',str);
% if p<=0.05
%     a.Color = 'red';
% end
% if ~isempty(pltpath)
%     print([pltpath '/Vol'],fmstr)
% end



%% KIS

if normKIS==0
    K=At + 1/4*(2*T) - 5/4*Ae;
    I=At + (2*T) + Ae;
    S=3/2*At - 9/4*(2*T) + 3/4*Ae;
else
    K=At + 1/4*(2*T) - 5/4*Ae;n=norm([1 1/4 -5/4]);K=K/n;
    I=At + (2*T) + Ae;n=norm([1 1 1]);I=I/n;
    S=3/2*At - 9/4*(2*T) + 3/4*Ae;n=norm([3/2 -9/4 3/4]);S=S/n;
end

varargout{1} = At;
varargout{2} = Ae;
varargout{3} = T;

varargout{4} = K;
varargout{5} = I;
varargout{6} = S;



data=[K(refIDs);K(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title(['K - ' cpmstr])
[~,p,~,stats]=ttest2(K(refIDs),K(cmpIDs));

dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);
zKIS(1)=d;
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/K'],fmstr)
end

data=[I(refIDs);I(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title(['I - ' cpmstr])
[~,p,~,stats]=ttest2(I(refIDs),I(cmpIDs));

dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);
zKIS(2)=d;
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/I'],fmstr)
end

data=[S(refIDs);S(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title(['S - ' cpmstr])
[~,p,~,stats]=ttest2(S(refIDs),S(cmpIDs));

zKIS(3)=d;
dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/S'],fmstr)
end




%% get 3D coords for vector

mK=(mean(K(cmpIDs))-mean(K(refIDs)));
mV=(mean(I(cmpIDs))-mean(I(refIDs)));
mS=(mean(S(cmpIDs))-mean(S(refIDs)));

mKVS=[mK mV mS];


% mK=(mean(K(cmpIDs))-mean(K(refIDs)))/std(K(refIDs));
% mV=(mean(V(cmpIDs))-mean(V(refIDs)))/std(V(refIDs));
% mS=(mean(S(cmpIDs))-mean(S(refIDs)))/std(S(refIDs));

% zKVS=[mK mV mS];





mK=(mean(At(cmpIDs))-mean(At(refIDs)));
mV=(mean(T(cmpIDs))-mean(T(refIDs)));
mS=(mean(Ae(cmpIDs))-mean(Ae(refIDs)));

moc=[mK mV mS];

% 
% mK=(mean(At(cmpIDs))-mean(At(refIDs)))/std(At(refIDs));
% mV=(mean(T(cmpIDs))-mean(T(refIDs)))/std(T(refIDs));
% mS=(mean(Ae(cmpIDs))-mean(Ae(refIDs)))/std(Ae(refIDs));

% zoc=[mK mV mS];

