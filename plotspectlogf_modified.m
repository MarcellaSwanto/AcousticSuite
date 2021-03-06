function plotspectlogf_modified(x, fs, f1, f2, mOrs, n)
% This function plots the spectrum: magnitude and phase
% -----------------------------------------------------
% plotspectlogf_modified(x, fs, f1, f2, smoothing, mOrs, n)
%
% Modified from the original script from Bill Gardner
% Copyright 1995 MIT Media Lab. All rights reserved.
%

%Defaults
if (nargin < 6)
n = max(size(x));
n = 2*2^nextpow2(n);
end

if (nargin < 5)
mOrs = 'mono-left';
end

if (nargin < 4)
   f2 = 10000;
end

if (nargin < 3)
   f1 = 100;
end

if (nargin < 2)
   fs = 44100;   
end

fx = fft(x,n);
assignin('base','fx',fx);
longfreq = ceil(n/2);
freq = (0 : longfreq) * fs / n;

for i = 1:size(x,2)     
    
   db = mag2db(abs(fx(1:(ceil(n/2) + 1), i)));
   myphase = unwrap(angle(fx(1:(ceil(n/2) + 1), i)));
   %assignin('base','myphase',myphase);
   % Calculation of group delay using the formula 1000*absolute value((absolute value(expressed in degrees of phase of the previous sample) - absolute value(expressed in degrees of phase of the sample))/(360*(frequency in Hz of the sample-frequency in Hz the previous sample)))
   myphase_1 = myphase(1:length(myphase)-1,1);
   myphase_2 = myphase(2:length(myphase),1);
   group_delay = 1000*(abs(abs(myphase_1)-abs(myphase_2)))/(360*(fs/n)); % 1000 is the factor used since we express the delay in ms
   % Shifting group delay down to 0 by the propagation delay (minimum value)
   group_delay = group_delay - min(group_delay);
   group_delay = [group_delay(1); group_delay];
   
   freqinit = f1;
   freqfinal = f2;
   limitinit = ceil(freqinit*n/fs);
   limitfinal = ceil(freqfinal*n/fs);
   [coefpoly, ~] = polyfit(freq(limitinit:limitfinal),myphase(limitinit:limitfinal)',1);
   myphase = -(coefpoly(1)*freq') - coefpoly(2) + myphase; 
   % lowering of the phase curve
   % to eliminate its slope and as close as possible to the horizontal axis
   myphase = myphase*180/pi;
   
  if strcmp(mOrs,'mono-left')
      db_left = db;
      myphase_left = myphase;
      group_delay_left = group_delay;
  elseif strcmp(mOrs,'mono-right')
       db_right = db;
       myphase_right = myphase;
       group_delay_right = group_delay;  
   else 
       if i == 1
           db_left = db;
           myphase_left = myphase;
           group_delay_left = group_delay;
       else
           db_right = db;
           myphase_right = myphase;
           group_delay_right = group_delay;
       end
    end

end

[m,lim1] = min(abs(freq-100));
[m,lim2] = min(abs(freq-1000));
[m,lim3] = min(abs(freq-50));
[m,lim4] = min(abs(freq-200));

% [k10, fcenter10] = OctaveSmooth(db, freq, 10); % 1/3 Base 10 Octave smooth
% [mag_bark, freq_bark] = rlogbark_short(freq, db); % Bark smoothing
% [trueOct, trueOct_f]=trueOctave(db, freq); % True octave Base 10 smooth

if strcmp(mOrs,'mono-left')
    %Left
    [mag_bark_left, freq_bark] = rlogbark_short(freq, db_left);
    [phase_bark_left, ~] = rgeobark_short(freq, myphase_left);
    [group_delay_bark_left, ~] = rgeobark_short(freq, group_delay_left);
    % Shifting group delay down to 0 by the propagation delay (minimum value)
    group_delay_bark_left = group_delay_bark_left - min(group_delay_bark_left);
    [trueOct_left, trueOct_f]=trueOctave(db_left, freq);
    [k10_left, fcenter10] = OctaveSmooth(db_left, freq, 10);
elseif strcmp(mOrs,'mono-right')
      %Right
    [mag_bark_right, freq_bark] = rlogbark_short(freq, db_right);
    [phase_bark_right, ~] = rgeobark_short(freq, myphase_right);
    [group_delay_bark_right, ~] = rgeobark_short(freq, group_delay_right);
    group_delay_bark_right = group_delay_bark_right - min(group_delay_bark_right);
    [trueOct_right, trueOct_f]=trueOctave(db_right, freq);
    [k10_right, fcenter10] = OctaveSmooth(db_right, freq, 10);
else 
    %Stereo
    [mag_bark_left, freq_bark] = rlogbark_short(freq, db_left);
    [phase_bark_left, ~] = rgeobark_short(freq, myphase_left);
    [group_delay_bark_left, ~] = rgeobark_short(freq, group_delay_left);
    group_delay_bark_left = group_delay_bark_left - min(group_delay_bark_left);
    [trueOct_left, ~]=trueOctave(db_left, freq);
    [k10_left, ~] = OctaveSmooth(db_left, freq, 10);
    
    [mag_bark_right, ~] = rlogbark_short(freq, db_right);
    [phase_bark_right, ~] = rgeobark_short(freq, myphase_right);
    [group_delay_bark_right, ~] = rgeobark_short(freq, group_delay_right);
    group_delay_bark_right = group_delay_bark_right - min(group_delay_bark_right);
    [trueOct_right, trueOct_f]=trueOctave(db_right, freq);
    [k10_right, fcenter10] = OctaveSmooth(db_right, freq, 10);
end

    
 if strcmp(mOrs,'mono-left')
     assignin('base','freq',freq);
     assignin('base','group_delay_left',group_delay_left);
     assignin('base','freq_bark',freq_bark);
     assignin('base', 'fcenter10', fcenter10);
     assignin('base', 'trueOct_f', trueOct_f);
     assignin('base','group_delay_bark_left',group_delay_bark_left);
     assignin('base','myphase_left',myphase_left);
     assignin('base','phase_bark_left',phase_bark_left);
     assignin('base','db_left',db_left);
     assignin('base','mag_bark_left',mag_bark_left);
     assignin('base', 'k10_left', k10_left);
     assignin('base', 'trueOct_left', trueOct_left);
     
     assignin('base','mOrs',mOrs);
     
  elseif strcmp(mOrs,'mono-right')
     assignin('base','freq',freq);
     assignin('base','group_delay_right',group_delay_right);
     assignin('base','freq_bark',freq_bark);
     assignin('base', 'fcenter10', fcenter10);
     assignin('base', 'trueOct_f', trueOct_f);
     assignin('base','group_delay_bark_right',group_delay_bark_right);
     assignin('base','myphase_right',myphase_right);
     assignin('base','phase_bark_right',phase_bark_right);
     assignin('base','db_right',db_right);
     assignin('base','mag_bark_right',mag_bark_right);
     assignin('base', 'k10_right', k10_right);
     assignin('base', 'trueOct_right', trueOct_right);
     
     assignin('base','mOrs',mOrs);
   else 
     assignin('base','freq',freq);
     assignin('base', 'trueOct_f', trueOct_f);
     assignin('base','freq_bark',freq_bark);
     assignin('base', 'fcenter10', fcenter10);
     
     assignin('base','group_delay_left',group_delay_left);
     assignin('base','group_delay_bark_left',group_delay_bark_left);
     assignin('base','myphase_left',myphase_left);
     assignin('base','phase_bark_left',phase_bark_left);
     assignin('base','db_left',db_left);
     assignin('base','mag_bark_left',mag_bark_left);
     assignin('base', 'trueOct_left', trueOct_left);
     assignin('base', 'k10_left', k10_left);
     
     assignin('base','mOrs',mOrs);
     
     assignin('base','group_delay_right',group_delay_right);
     assignin('base','group_delay_bark_right',group_delay_bark_right);
     assignin('base','myphase_right',myphase_right);
     assignin('base','phase_bark_right',phase_bark_right);
     assignin('base','db_right',db_right);
     assignin('base','mag_bark_right',mag_bark_right);
     assignin('base', 'trueOct_right', trueOct_right);
     assignin('base', 'k10_right', k10_right);
 end

 if strcmp(mOrs,'stereo')
    DIsplayIR_app_stereo;
 else
     DisplayIR_app;
 end
end

