function [ EMG ] = emgProcessing( emgSignal )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    Rectified_EMG = abs(emgSignal);
    Fe=1000; %Samling frequenc
    Fc=3; % Cut-off frequency (from 2 Hz to 6 Hz depending to the type of your electrod)
    N=4; % Filter Order
    [B, A] = butter(N,Fc*2/Fe, 'low'); %filter's parameters 
    EMG=filtfilt(B, A, Rectified_EMG); %in the case of Off-line treatment
end

