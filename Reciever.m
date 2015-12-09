function r = Reciever()

    function signal = readDATFile(fileName)
        %reads DAT file produced by rx_samples_to_file, returns
        %complex signal as a row vector
        f1 = fopen(fileName,'r');
        x = fread(f1,'int16');
        real = x(1:2:end);
        imaginary = x(2:2:end);
        signal = (real + imaginary * 1i);
    end

    function stripped = stripZeros(signal)
       %removes values beneath threshold at beginning and end of 
       %block
       THRESHOLD = 50;
       SIGNAL_START = 100; %start scanning from after the weird spike
                         %at the beginning of recieved signal
       i = SIGNAL_START;
       while abs(signal(i)) < THRESHOLD && i < length(signal)
           i = i+1;
       end
       j = length(signal);
       while abs(signal(j)) < THRESHOLD && j > 0
           j = j-1;
       end
       stripped = signal(i:j);
    end

    function strippedSignal = getAndStripSignal(fileName)
        signal = stripZeros(readDATFile(fileName));
        signalWithoutInitialPeak = signal(2000:length(signal));
        strippedSignal = stripZeros(signalWithoutInitialPeak);
    end

    function void = plotComplex(signal)
       %creates a new figure and plots real and imaginary parts of signal
       %in subplots
       figure;
       subplot(2,1,1);
       plot(real(signal));
       xlabel('Real component');
       subplot(2,1,2);
       plot(imag(signal));
       xlabel('Imaginary component');
    end

    function freqOffset = findFreqOffset(signal)
       %takes FFT of complex signal to determine
       %the frequency offset between reciever and transmitter
       %returns value between (-pi/2 and pi/2)
       f = fftshift(fft(signal.^2));
       frequencies = linspace(-1,1,length(f));
       [foo, maxFreqIndex] = max(f);
       freqOffset = frequencies(maxFreqIndex)/4;
    end

    function [freqOffset, corrected] = removeFreqOffset(signal)
       %multiplies signal by correct complex exponential
       %to remove phase offset. Operates with assumption
       %that phase offset is not changing significantly over
       %the duration of the signal
       freqOffset = findFreqOffset(signal);
       times = (0:length(signal)-1)';
       corrected = signal .* exp(-times*2*pi*1i*freqOffset);
    end

signal = getAndStripSignal('squareWaveWithImag.dat');
%Siddhartan's timing sync code
[yI, yQ, siddFreqOffset]  = bpsk_timing_sync(real(signal), imag(signal));
plotComplex(yI+1j*yQ);
disp(siddFreqOffset);
%Our timing sync code
[freqOffset, correctedSignal] = removeFreqOffset(signal);
plotComplex(correctedSignal);
disp(freqOffset);

end
