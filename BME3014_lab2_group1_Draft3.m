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

% Subtract the users weight from the entire dataset <- This is the data you
%   will use for the remainder of the analysis
zforce = zdir-userwt;
zforce(zforce == -userwt) = [];

% Create a time array (use the Fs variable from above)
time = []; %Create a time array using the sampling frequency
time(1) = 0;
temptime = 1/Fs;
for k = 2:length(zforce)
    time(k) = time(k-1) + temptime;%iterate over the entire zforce data to create a time array of the same size
end

%% Programmatically identify start and end of "air" time
%(the time when user is actually in the air)

%First we create a figure to determine to get a visual representation of the data for te coding process
%This is commented out for the final function

%figure
%plot(time, zforce);
%title('Z Force of Stiff 1 (N) v Time (s)')
%xlabel('Time(s)')
%ylabel('Z Force (N)')
% Hint: plot the data first. Think of a SIMPLE method to identify the
%   beginning and end of the "air" region of the data

level = min(zforce)+50;  %create a threshold because the bottom of the jump trough in the data isn't constant

threshdata = false(size(zforce)); % Create a thresholded array
threshdata(zforce < level) = true;  %anything below the threshold is true

air = find(threshdata == true);   %gives booleans of 1s for all times the subject is in the air and 0 for when they are not

BeginningofAirtime = find(threshdata, 1, 'first') %finds the first 1 in the array denoting the beginning of the jump
EndofAirtime = find(threshdata, 1, 'last')%find hte final 1 denoting the end of the jump

airtime = time(EndofAirtime) - time(BeginningofAirtime) %finally the entire airtime is time at the end of the jump minus the time at the beginning

%% Programmatically identify the start of the jump impulse and end of landing impulse

% Hint: the data before the jump impulse or after ther landing impulse is
%   going to be approximately zero. It will be easiest to identify the
%   start of the jump or end of the landing by finding where the data
%   begins to deviate from zero

level = std(zforce(15:50))*20; %to find the force we determined to find the std from first 15 to the 50th samples in the data
%We chose this since some of our data points had issues at the beginning of
%the data, so this 15th starting point helps deal with that, and it goes to
%the 50th point since that seems to be earlier the jump starts for our data
%sets. We chose to mulitply the std by 20 since that seems to work for our
%data sets after some testing

threshdata = false(size(zforce)); % Create a thresholded array
threshdata(zforce > level) = true;
threshdata(zforce < -level) = true;%anything below the threshold is true

BeginImpulse = find(threshdata, 1, 'first') %we use the find function again to find the beginning of the initial impulse andend of the landing impulse
EndImpulse = find(threshdata, 1, 'last')


%% Calculate the value of the jumping impulse and landing impulse in N*s
% "trapz" is a built in function that can be used to numerically integrate
%   discrete  data.

%Using the trapz function we found the intergral of the graph between the
%beginning of each impulse and the end for the jump impulse this is from
%the beginimpulse to the beginning of the airtime and of the landing
%impulse it is from the ending of the air time to the ending of the landing
%impulse

Jumpimpulse = trapz(zforce(BeginImpulse:BeginningofAirtime),time(BeginImpulse:BeginningofAirtime))
Landingimpulse = trapz(zforce(EndofAirtime:EndImpulse),time(EndofAirtime:EndImpulse))


%% Calculate peak landing force

maxlandingforce = max(zforce(EndofAirtime:EndImpulse))%we use these same time frames to find the max force

%% Use the air time to determine theoretical jump height
% Based on conservation of momentum/projectile motion or energy equations.
% The subject can be considered a "projectile" when in the air

vf = 0; %vf is when the subject is at peak height
t = 0.5*airtime; %airtime is half when jumper as at max height
g = -9.81; %(m/s^2)
v0 = vf - g*t; %find inital velocity

height = (vf^2-v0^2)/(2*g) %height is 0.338m

%% Report target values (just use disp function)
% Use the form: disp(['MEASURED PARAMETER ',num2str(VALUE), ' UNITS'])
% Report total jumping impulse and landing impulse
% Report total jumping impulse and landing impulse

disp(['JUMP IMPULSE: ', num2str(Jumpimpulse), 'Ns      ', 'LANDING IMPULSE: ', num2str(Landingimpulse), 'Ns '])

% Report peak force

disp(['PEAK FORCE: ', num2str(maxlandingforce), 'N '])


% Report estimated jump height

disp(['ESTIMATED JUMP HEIGHT: ', num2str(height), 'm'])

% Report jumping impulse normalized to (divided by) jumping height

disp(['NORMALIZED LANDING IMPULSE: ', num2str(Jumpimpulse/height), 'Ns ','        NORMALIZED LANDING IMPULSE: ', num2str(Landingimpulse/height), 'Ns '])

% Report peak force normalized to jump height

disp(['PEAK FORCE NORMALIZED:   ', num2str(maxlandingforce/height), 'N '])

%% Plot data in the following way
% Plot your data (the data with the user's weight removed) as a black line
close all
figure
plot(time, zforce, '-k');
title('Z Force (N) v Time (s)')
xlabel('Time(s)')
ylabel('Z Force (N)')
hold on

% Plot the time in air as a red line (use the "hold on" command below to
%   add to the original plot
hold on
plot(time(BeginningofAirtime:EndofAirtime),zforce(BeginningofAirtime:EndofAirtime), 'r-')

% Plot blue circles at the locations where the jump starts and landing ends
hold on
ImpulseLocations = [BeginImpulse EndImpulse];
plot(time(ImpulseLocations), zforce(ImpulseLocations),'bo')

%% Convert your script to a function
% Comment out everything in lines 2-10 (the inputs section at the top of
% this file

% Uncomment the very top line in the file

% You can now use this file as a function --> If you need help with this,
% ask the professor/TA for help