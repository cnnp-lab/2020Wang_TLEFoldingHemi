Age=CamCAN_MasterTable.Age;
I=log10(CamCAN_MasterTable.AvgCortThickness.^2)+log10(CamCAN_MasterTable.PialArea)+log10(CamCAN_MasterTable.SmoothPialArea);
SPV=log10(CamCAN_MasterTable.SmoothPialFullVol);
GMV=log10(CamCAN_MasterTable.GreymatterVol);
PFV=log10(CamCAN_MasterTable.PialFullVol);

ids=CamCAN_MasterTable.AvgCortThickness>2.2;

figure(1)
subplot(1,3,1)
scatter(I(ids),SPV(ids),50,Age(ids));
c=corr(I(ids),SPV(ids));
title(['c=' num2str(c)])
xlabel('I')
ylabel('Exposed surface brain volume')
h = colorbar;
set(get(h,'label'),'string','Age (years)');

subplot(1,3,2)
scatter(I(ids),GMV(ids),50,Age(ids));
c=corr(I(ids),GMV(ids));
title(['c=' num2str(c)])
xlabel('I')
ylabel('Grey matter volume')
h = colorbar;
set(get(h,'label'),'string','Age (years)');

subplot(1,3,3)
scatter(I(ids),PFV(ids),50,Age(ids));
c=corr(I(ids),PFV(ids));
title(['c=' num2str(c)])
xlabel('I')
ylabel('Pial surface brain volume')
h = colorbar;
set(get(h,'label'),'string','Age (years)');