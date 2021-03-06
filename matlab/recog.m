%/media/rick/8156-6047/audio/sounds/

function [samples,hzcrr,lster,samplefreq] = recog(filename,centervalue)

[y, freq, bits] = wavread(filename,'native');

samplefreq = freq;

y = transpose(y);

%
%fprintf('\nSampling frequency: %d, bitsize: %d, number of sample values: %d\n', freq, bits, size(y,2))
    
x = [1:size(y,2)];

%plot(x,y)

number_of_samples_per_second = 40;

y_1sec_sample = y(1:freq);
framesize_broken = freq/number_of_samples_per_second;

framesize = floor(framesize_broken);
total_frames = floor(size(y,2)/framesize);

x2 = 1:framesize_broken:total_frames*framesize;
y2 = zeros(1,total_frames);
y3 = zeros(1,total_frames);





for i=1:total_frames
   y_frame = y(((i-1)*framesize+1): i*framesize);
   
   y_frame_double = cast(y_frame, 'double');
   frame_ste = sum(abs(y_frame_double).^2); % norm(y_frame_double,Inf);
   
   %fprintf('Norm of frame %d: %d\n',i,frame_ste);
   
   lastposition = 0;
   currentposition = 0;
   frame_zcr = 0;
   
   
   for j=1:framesize
       if y_frame(j) >= centervalue
           currentposition = 2;
       else
           currentposition = 1;
       end
       if lastposition == 1 && currentposition == 2
          frame_zcr = frame_zcr + 1; 
       end
       if lastposition == 2 && currentposition == 1
          frame_zcr = frame_zcr + 1;
       end
       lastposition = currentposition;
   end   
 
   y2(i) = frame_zcr;
   y3(i) = frame_ste;
   
   %fprintf('Frame %d: ZCR: %d STE: %d\n',i,frame_zcr,frame_ste)
end


% %%
% figure('Name','Feature: ZCR','NumberTitle','off')
% 
% %fprintf('size x: %d, size y: %d, size x2: %d, size y2: %d\n',size(x,2),size(y,2),size(x2,2),size(y2,2));
% 
% [AX,H1,H2] = plotyy(x,y,x2,y2);
% %%
% set(H2,'LineWidth',2,'Color','Red');
% legend('Sample-data','ZCR per frame');
% 
% figure('Name','Feature: STE','NumberTitle','off')
% 
% [AX,H1,H2] = plotyy(x,y,x2,y3);
% %%
% set(H2,'LineWidth',2,'Color','Green');
% legend('Sample-data','STE per frame');
% %%



%bereken HZCRR
%fprintf('Total zcr: %d\n',sum(y2));
mean_zcr = mean(y2);
avg_zcr = 1.5 * mean_zcr(1);
%avg_zcr = sum(y2,2) / size(y2,2);
higher = 0;
lower = 0;

for k=1:size(y2,2)
    if (y2(k) >= avg_zcr)
       higher = higher + 1;
    else
       lower = lower + 1;
    end
end

hzcrr = higher/(higher+lower);

%
%fprintf('Gemiddelde ZCR: %3.4f\nHoger dan gem: %d, Lager dan gem: %d\nHZCRR = %1.2f\n',avg_zcr,higher,lower,hzcrr);


%bereken L(STE)R

mean_ste = mean(y3);
avg_ste = 0.5 * mean_ste(1);
%avg_ste = sum(y3,2) / size(y3,2);
higher_ste = 0;
lower_ste = 0;

for l=1:size(y3,2)
    if (y3(l) >= avg_ste)
        higher_ste = higher_ste + 1;
    else
        lower_ste = lower_ste + 1;
    end
end

lster = lower_ste/(lower_ste+higher_ste);

%
%fprintf('Gemiddelde STE: %3.4f\nHoger dan gem: %d, Lager dan gem: %d\nLSTER = %1.2f\n',avg_ste,higher_ste,lower_ste,lster);

%lster = 0;

samples = y;