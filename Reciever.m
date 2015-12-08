function r = Reciever()

    function signal = readDATFile(fileName)
        %reads DAT file produced by rx_samples_to_file, returns
        %complex signal as a row vector
        f1 = fopen(fileName,'r');
        x = fread(f1,'int16');
        real = x(1:2:end);
        imaginary = x(2:2:end);
        signal = (real + imaginary * 1i)';
    end

    function freqOffset = findFreqOffset(signal)
       %takes FFT of complex signal to determine
       %the frequency offset between reciever and transmitter
       %returns value between (-pi/2 and pi/2)
       f = fftshift(fft(signal.^2));
       frequencies = linspace(-pi,pi,length(f));
       [foo, maxFreqIndex] = max(f);
       freqOffset = frequencies(maxFreqIndex)/2;
    end

    function corrected = removeFreqOffset(signal,dataRate,freqOffset)
       %multiplies signal by correct complex exponential
       %to remove phase offset. Operates with assumption
       %that phase offset is not changing significantly over
       %the duration of the signal
       times = [0:length(signal)-1];
       corrected = signal .* exp(-times*2*pi*1i*freqOffset);
    end

    function stripped = stripZeros(signal)
       %removes values beneath threshold at beginning and end of 
       %block
       THRESHOLD = 50;
       SIGNAL_START = 100; %start scanning from after the weird spike
                         %at the beginning of recieved signal
       i = SIGNAL_START;
       while signal(i) < THRESHOLD
           i = i+1;
       end
       j = length(signal);
       while signal(j) < THRESHOLD
           j = j-1;
       end
       stripped = signal(i:j);
    end

signal = stripZeros(readDATFile('staircase.dat'));
plot(abs(stripZeros(signal)));
dataRate = 2.5e5;
freqOffset = findFreqOffset(signal);
correctedSignal = removeFreqOffset(signal,dataRate,freqOffset);
 subplot(2,1,1);
 plot(real(signal));
 subplot(2,1,2);
 plot(real(correctedSignal));
% figure;
% plot(abs(correctedSignal-signal));

end
