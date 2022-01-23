clear; close all;

dat = readtable('data.csv');
co2 = dat.CO2;
co2 = rmoutliers(co2,'mean');
co2 = fillmissing(co2, 'movmedian',10);
co2 = decimate(co2,100);
plot(co2);
T = array2table(co2);
T.Properties.VariableNames(1) = {'CO2'};
writetable(T,'co2.csv');
