clear; close all;

s=tf('s');
%G=1/(s^2+s+1);
G = (1.151*s+0.1774)/(s^3+0.739*s^2+0.921*s); %http://ctms.engin.umich.edu/CTMS/index.php?example=AircraftPitch&section=SystemModeling
ts=0.1;
t=0:ts:20;
nx=10;
u=[zeros(nx,1)',ones(length(t)-nx,1)'];
[y,t]=lsim(G,u,t);
z=iddata(y,u',0.1); %uを転置してカラムベクトルに直す
plot(z);

Options = tfestOptions;      
Options.Display = 'off';      
Options.WeightingFilter = [];

bestAIC = 99999;
m = 6;
n = 6;
bestm = [];
bestn= [];
for idx=1:m
    for jdx=0:n        
        if jdx>idx 
            continue;
        end
        current_tf = tfest(z, idx, jdx, Options);
        currentAIC = current_tf.report.Fit.AIC;
        fprintf('pole:%d, zero:%d, current AIC:%d, bestAIC: %d\n',idx,jdx,currentAIC,bestAIC);
        if currentAIC  < bestAIC
            bestAIC = currentAIC;
            bestm = idx;
            bestn = jdx;
        end        
    end   
end

besttf = tfest(z, bestm, bestn, Options);
[n,d] = tfdata(besttf);
n = cellfun(@(x) {x.*(abs(x)>1e-7)}, n);
d = cellfun(@(x) {x.*(abs(x)>1e-7)}, d);
besttf = tf(n, d)

figure();title('System ID result');
[y,t]=lsim(G,u,t);
plot(t,y);
hold on;
[y2,t2]=lsim(besttf,u,t);
plot(t2,y2);
legend('original','systemID');