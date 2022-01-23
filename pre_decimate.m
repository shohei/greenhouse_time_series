clear; close all;

dat = readtable('data.csv');
n_movmedian = 10;
n_decimate = 100;
co2 = filloutliers(dat.CO2,'linear');
co2 = decimate(co2(1:end-1), n_decimate);
rh = filloutliers(dat.Humidity,'linear');
rh = decimate(rh(1:end-1), n_decimate);
temp = filloutliers(dat.Temperature,'linear');
temp = decimate(temp(1:end-1), n_decimate);
soil = filloutliers(dat.SoilMoisture,'linear');
soil = decimate(soil(1:end-1), n_decimate);
time = dat.Time;
time = decimate(time(1:end-1),n_decimate);

T = table(time,temp,rh,co2,soil);
T.Properties.VariableNames(1:5) = {'Time','Temperature','Humidity','CO2','Soil Moisture'};
writetable(T,'dat_pre.csv');
