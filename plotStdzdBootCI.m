function d=plotStdzdBootCI(group,data,refID)

% 
rng(1)
% data=[randn(50,1);randn(50,1)-0.1];
% group=[zeros(50,1);ones(50,1)];
grpi=unique(group);
% refID=0;
%% calculate ref mean & std;

dg=data(group==refID);
m=mean(dg);
s=std(dg);

clrs=[[0 .3 .7];[0.7 0.1 0.1]];

%% get CI after standardisation
% clc
% close all
% figure()
% hold on
bootstats_all=[];
grp_all=[];
for k=1:length(grpi)

    dg=data(group==grpi(k));
    dg=(dg-m)/s;
    
    [ci_grp,bootstats] = bootci(100,@mean,dg);
    m_grp = mean(bootstats);
    md_grp = median(bootstats);
    
    x=[k-0.2 k+0.2 k+0.2 k-0.2];
    y=[ci_grp(1) ci_grp(1) ci_grp(2) ci_grp(2)];

    %patch(x,y,'red','FaceColor',clrs(k,:),'FaceAlpha',0.3,'LineStyle','none')
    
    %plot([k-0.2 k+0.2],[m_grp m_grp],'LineWidth',3,'Color',clrs(k,:))
    %plot([k-0.2 k+0.2],[md_grp md_grp],'LineWidth',1,'Color',clrs(k,:))

    bootstats_all=[bootstats_all; bootstats];
    grp_all=[grp_all; bootstats*0+k];
end
%hold off

violinplot(bootstats_all,grp_all,'Bandwidth',0.1,'ShowData',false,'ShowMean',true);

d=mean(bootstats_all(grp_all==2)-bootstats_all(grp_all==1));

xlim([0 length(grpi)+1])
ylim([-1.2 1.2])
