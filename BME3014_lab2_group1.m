% function(fname,Fs,userwt)
%% Function inputs
%These 3 inputs should be the only sections of the file that should be
%changed when analyzing a different dataset
%%

fname = importdata('Trial1_straightlanding.txt'); % name of dataset file
Fs = 200; % Hz Sampling rate 
userwt = 580.72; %N Weight of subject in newtons

%----------------------------------------------------
%EVERYTHING BELOW THIS LINE SHOULD REMAIN CONSTANT FOR ANY DATASET YOU
%ANALYZE

%% Import data, create time and z-direction arrays and account for user weight

% Use the import data command to import data (See previous lab)

% Extract the z-direction data (column 3)
zdir = fname(:,3);

% Create a time array (use the Fs variable from above)
time = [];
time(1) = 0; 
time(2) = 1/Fs;
temptime = 1/Fs;
for k = 2:length(zdir)
    time(k) = time(k-1) + temptime;
end
% Subtract the users weight from the entire dataset <- This is the data you
%   will use for the remainder of the analysis
zforce = zdir-userwt;

zforce(zforce == -userwt) = [];
time = (1:length(zforce))


%% Programmatically identify start and end of "air" time
%(the time when user is actually in the air)

figure(1)
plot(time, zforce);
title('Z Force of Stiff 1 (N) v Time (s)')
xlabel('Time(s)')
ylabel('Z Force (N)')
% Hint: plot the data first. Think of a SIMPLE method to identify the
%   beginning and end of the "air" region of the data

level = min(zforce)+50;  %create a threshold because the bottom of the jump trough in the data isn't constant

threshdata = false(size(zforce)); % Create a thresholded array
threshdata(zforce < level) = true;  %anything below the threshold is true

air = find(threshdata == true);   %air time

BeginningofAirtime = find(threshdata, 1, 'first')
EndofAirtime = find(threshdata, 1, 'last')

airtime = time(EndofAirtime) - time(BeginningofAirtime) 


%% Programmatically identify the start of the jump impulse and end of landing impulse

% Hint: the data before the jump impulse or after ther landing impulse is
%   going to be approximately zero. It will be easiest to identify the
%   start of the jump or end of the landing by finding where the data
%   begins to deviate from zero

level = 150;

threshdata = false(size(zforce)); % Create a thresholded array
threshdata(zforce > level) = true;
threshdata(zforce < -level) = true;%anything below the threshold is true

BeginImpulse = find(threshdata(15:end), 1, 'first') + 15

EndImpulse = find(threshdata, 1, 'last')

%% Calculate the value of the jumping impulse and landing impulse in N*s
% "trapz" is a built in function that can be used to numerically integrate
%   discrete  data.

Jumpimpulse = trapz(zforce(BeginImpulse:BeginningofAirtime),time(BeginImpulse:BeginningofAirtime))

Landingimpulse = trapz(zforce(EndofAirtime:EndImpulse),time(EndofAirtime:EndImpulse))


%% Calculate peak landing force

maxlandingforce = max(zforce(EndofAirtime:EndImpulse))
maxjumpforce = max(zforce(BeginImpulse:BeginningofAirtime))
if maxlandingforce > maxjumpforce
    maxforce = maxlandingforce
else
    maxforce = jumpforce
end

%% Use the air time to determine theoretical jump height
% Based on conservation of momentum/projectile motion or energy equations.
% The subject can be considered a "projectile" when in the air

airtime = time(EndofAirtime) - time(BeginningofAirtime) 
vi = 0
a = 9.81

airtime =airtime/200

Jumpheight = vi*airtime +(a*(airtime)^2)/2



%% Report target values (just use disp function)
% Use the form: disp(['MEASURED PARAMETER ',num2str(VALUE), ' UNITS'])
% Report total jumping impulse and landing impulse

fprintf('JUMP IMPULSE ') disp(Jumpimpulse) fprintf('Ns ') fprintf('LANDING IMPULSE ') disp(Landingimpulse) fprintf('Ns ')

% Report peak force

disp('PEAK FORCE ', maxlandingforce, 'N ')


% Report estimated jump height

disp('ESTIMATED JUMP HEIGHT ', Jumpheight, 'm')

% Report jumping impulse normalized to (divided by) jumping height

disp('NORMALIZED LANDING IMPULSE ', Jumpimpulse/Jumpheight, 'Ns ','NORMALIZED LANDING IMPULSE ', Landingimpulse/Jumpheight, 'Ns ')

% Report peak force normalized to jump height

disp('PEAK FORCE NORMALIZED', maxlandingforce/Jumpheight, 'N ')

%% Plot data in the following way
% Plot your data (the data with the user's weight removed) as a black line
close all
figure
plot(time, zforce);
title('Z Force of Stiff 1 (N) v Time (s)')
xlabel('Time(s)')
ylabel('Z Force (N)')
hold on
plot(time, userwt, 'bl-')

% Plot the time in air as a red line (use the "hold on" command below to
%   add to the original plot
hold on
plot(time(BegginningofAirtime:EndofAirtime),zforce(BegginningofAirtime:EndofAirtime), 'r-')

% Plot blue circles at the locations where the jump starts and landing ends
hold on
ImpulseLocations = [BeginImpulse EndofLandingDown]
plot(time(ImpulseLocations), zforce,'o')

%% Convert your script to a function
% Comment out everything in lines 2-10 (the inputs section at the top of
% this file

% Uncomment the very top line in the file

% You can now use this file as a function --> If you need help with this,
% ask the professor/TA for help