load('~/GitHub/2020Wang_TLEFoldingHemi/data/CamCAN_MasterTable.mat')

DataTable=CamCAN_MasterTable;
age  = DataTable.Age;
sex = DataTable.Sex;
T=DataTable.AvgCortThickness;
refIDs=find(age>=22 & age<=28 & T>2.2)

figure(1)
subplot(2,1,1)
histogram(T(refIDs),15)
title('thickness')
subplot(2,1,2)
histogram(log10(T(refIDs).^2),15)
title('log( thickness^2 )')


figure(2)
subplot(2,1,1)
x=T(refIDs);
[h,p] = kstest(x);
cdfplot(x)
hold on
x_values = linspace(min(x),max(x),30);
plot(x_values,normcdf(x_values,mean(x),std(x)),'r-')
legend('Empirical CDF','Standard Normal CDF','Location','best')
% title(['p=' num2str(p)])
title('thickness')
hold off

subplot(2,1,2)
x=log10(T(refIDs).^2);
[h,p] = kstest(x);
cdfplot(x)
hold on
x_values = linspace(min(x),max(x),30);
plot(x_values,normcdf(x_values,mean(x),std(x)),'r-')
legend('Empirical CDF','Standard Normal CDF','Location','best')
% title(['p=' num2str(p)])
title('log( thickness^2 )')
hold off