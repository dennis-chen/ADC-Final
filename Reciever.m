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
       times = linspace(0,length(signal)/dataRate,length(signal));
       corrected = signal .* exp(-times*2*pi*1i*freqOffset);
    end

signal = readDATFile('staircase.dat');
dataRate = 2.5e5;
freqOffset = findFreqOffset(signal);
correctedSignal = removeFreqOffset(signal,dataRate,freqOffset);
subplot(2,1,1);
plot(abs(fft(signal.^2)));
subplot(2,1,2);
plot(abs(fft(correctedSignal.^2)));
figure;
plot(abs(correctedSignal-signal));

end
