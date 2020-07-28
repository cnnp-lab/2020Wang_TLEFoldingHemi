function [mPC,zPC]=analyseFoldingPCA(DataTable,refIDs,cmpIDs,cpmstr,pltpath)


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


%% Plot of PCs


PC1 = DataTable(:,1);
PC2 = DataTable(:,2);
PC3 = DataTable(:,3);


data=[PC1(refIDs);PC1(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title('PC1')
[p,~,stats]=ranksum(PC1(refIDs),PC1(cmpIDs));

dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);

zPC(1)=d;
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/PC1'],fmstr)
end


data=[PC2(refIDs);PC2(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title('PC2')
[p,~,stats]=ranksum(PC2(refIDs),PC2(cmpIDs));

dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);

zPC(2)=d;
if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/PC2'],fmstr)
end


data=[PC3(refIDs);PC3(cmpIDs)];
group=[zeros(size(refIDs)); ones(size(cmpIDs))];
h=figure();
switch plt_format
    case 'beeswarm'
        beeswarm(group,data,'sort_style','hex','overlay_style','ci');
        d=cohensD(data,group);
    otherwise
        d=plotStdzdBootCI(group,data,0)
end
title('PC3')
[p,~,stats]=ranksum(PC3(refIDs),PC3(cmpIDs));

zPC(3)=d;
dim = [.4 .8 .2 .1];
str = ['p=' num2str(p) ' d=' num2str(d)];
a=annotation('textbox',dim,'String',str);

if p<=0.05
    a.Color = 'red';
end
if ~isempty(pltpath)
    print([pltpath '/PC3'],fmstr)
end



if size(DataTable, 2) == 6
    % In case of 6 PCs
    PC4 = DataTable(:,4);
    PC5 = DataTable(:,5);
    PC6 = DataTable(:,6);
    
    
    
    data=[PC4(refIDs);PC4(cmpIDs)];
    group=[zeros(size(refIDs)); ones(size(cmpIDs))];
    h=figure();
    switch plt_format
        case 'beeswarm'
            beeswarm(group,data,'sort_style','hex','overlay_style','ci');
            d=cohensD(data,group);
        otherwise
            d=plotStdzdBootCI(group,data,0)
    end
    title('PC4')
    [p,~,stats]=ranksum(PC4(refIDs),PC4(cmpIDs));

    zPC(4)=d;
    dim = [.4 .8 .2 .1];
    str = ['p=' num2str(p) ' d=' num2str(d)];
    a=annotation('textbox',dim,'String',str);

    if p<=0.05
        a.Color = 'red';
    end
    if ~isempty(pltpath)
        print([pltpath '/PC4'],fmstr)
    end
    
    
    data=[PC5(refIDs);PC5(cmpIDs)];
    group=[zeros(size(refIDs)); ones(size(cmpIDs))];
    h=figure();
    switch plt_format
        case 'beeswarm'
            beeswarm(group,data,'sort_style','hex','overlay_style','ci');
            d=cohensD(data,group);
        otherwise
            d=plotStdzdBootCI(group,data,0)
    end
    title('PC5')
    [p,~,stats]=ranksum(PC5(refIDs),PC5(cmpIDs));

    zPC(5)=d;
    dim = [.4 .8 .2 .1];
    str = ['p=' num2str(p) ' d=' num2str(d)];
    a=annotation('textbox',dim,'String',str);

    if p<=0.05
        a.Color = 'red';
    end
    if ~isempty(pltpath)
        print([pltpath '/PC5'],fmstr)
    end


    data=[PC6(refIDs);PC6(cmpIDs)];
    group=[zeros(size(refIDs)); ones(size(cmpIDs))];
    h=figure();
    switch plt_format
        case 'beeswarm'
            beeswarm(group,data,'sort_style','hex','overlay_style','ci');
            d=cohensD(data,group);
        otherwise
            d=plotStdzdBootCI(group,data,0)
    end
    title('PC6')
    [p,~,stats]=ranksum(PC6(refIDs),PC6(cmpIDs));

    zPC(6)=d;
    dim = [.4 .8 .2 .1];
    str = ['p=' num2str(p) ' d=' num2str(d)];
    a=annotation('textbox',dim,'String',str);

    if p<=0.05
        a.Color = 'red';
    end
    if ~isempty(pltpath)
        print([pltpath '/PC6'],fmstr)
    end
end


%% get 3D coords for vector

mPC1=(mean(PC1(cmpIDs))-mean(PC1(refIDs)));
mPC2=(mean(PC2(cmpIDs))-mean(PC2(refIDs)));
mPC3=(mean(PC3(cmpIDs))-mean(PC3(refIDs)));

mPC=[mPC1 mPC2 mPC3];


% 
% mPC1=(mean(At(cmpIDs))-mean(At(refIDs)));
% mPC2=(mean(T(cmpIDs))-mean(T(refIDs)));
% mPC3=(mean(Ae(cmpIDs))-mean(Ae(refIDs)));
% 
% moc=[mPC1 mPC2 mPC3];

end