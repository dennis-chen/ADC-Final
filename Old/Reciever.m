function r = Reciever()

close all;

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
       THRESHOLD = 200;
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

    function strippedSignal = getAndStripUHDSignal(fileName)
        %reads a DAT file generated by the UHD and strips
        %it of the initial peak that occurs during transmission
        %as well as any zeros. Returns complex signal.
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
       var(real(signal))
       var(imag(signal))
       subplot(2,1,2);
       plot(imag(signal));
       
       xlabel('Imaginary component');
    end

    function freqOffset = findFreqOffset(signal)
       %takes FFT of complex signal to determine
       %the frequency offset between reciever and transmitter
       %returns value between (-pi/2 and pi/2)
       f = fftshift(fft(signal.^2));
       frequencies = linspace(-1, 1, length(f));
%        plot(frequencies,f);
       [foo, maxFreqIndex] = max(abs(f));
       freqOffset = frequencies(maxFreqIndex)/2;
    end

    function [freqOffset, corrected] = removeFreqOffset(signal)
       %multiplies signal by correct complex exponential
       %to remove phase offset. Operates with assumption
       %that phase offset is not changing significantly over
       %the duration of the signal
       freqOffset = findFreqOffset(signal);
       times = (0:length(signal)-1)';
       corrected = signal .* exp(-times*1i*pi*freqOffset);
       
    end

    function [freqOffsets, corrected, actual] = removeFreqOffsetChunkSized(signal,chunkSize)
       %splits signal into chunks of chunkSize, corrects phase offset in 
       %each of them and then stitches them back together.
       corrected = zeros(length(signal), 1);
       actual = zeros(length(signal), 1);
       freqOffsets = [];
       j = 1;
       for i = 1:chunkSize:length(signal)
           if(i+chunkSize > length(signal))
            chunk = signal(i:end);
           else
            chunk = signal(i:i+chunkSize);    
           end
           [freqOffset, chunkCorrected] = removeFreqOffset(chunk);
           chunkActual = findActualSignal(chunkCorrected);
           freqOffsets(j) = freqOffset; 
           j = j+1;
           if(i+chunkSize > length(signal))
            corrected(i:end) = chunkCorrected;
            actual(i:end) = chunkActual;
           else
            corrected(i:i+chunkSize) = chunkCorrected;
            actual(i:i+chunkSize) = chunkActual;
           end
       end
    end

    function [freqOffsets, corrected, actual] = removeFreqOffsetChunkNum(signal,chunkNum)
       %splits signal into chunkNum of chunks, corrects phase offset in 
       %each of them and then stitches them back together.
       chunkSize = floor(length(signal)/chunkNum);
       [freqOffsets, corrected, actual] = removeFreqOffsetChunkSized(signal,chunkSize);
    end
   
    function actualSig = findActualSignal(signal)
        %Takes a signal and returns real or imag portion of it that has
        %has the greater variance (greater amplitude)
        if(var(real(signal)) > var(imag(signal)))
            actualSig = real(signal);
        else
            actualSig = imag(signal);
        end              
    end

    function bits = sigToBits(signal, sampleStart, sampleRate)
       %interprets every sampleRate bits of the signal as a bit
       %starting at the sampleStart index
       samples = downsample(signal(sampleStart:end),sampleRate);
       signs = sign(samples);
       bits = (signs+1)/2;
    end

    function flipped = flipCheckBits(signal)
        %for every 10 bits of the signal, the first two are check bits
        %that we expect to be 1 0
        flipped = zeros(length(signal),1);
        for i = 1:10:length(signal)
           checkBits = signal(i:i+1);
           if(checkBits == [0; 1])
               flipped(i:i+9) = not(signal(i:i+9));
           else
               flipped(i:i+9) = signal(i:i+9);
           end
        end
    end

%Siddhartan's timing sync code
% [yI, yQ, siddFreqOffset]  = bpsk_timing_sync(real(signal), imag(signal));
% plotComplex(yI+1j*yQ);

%Our timing sync code
signal = stripZeros(readDATFile('lessRepeat.dat'));

[freqOffsets, correctedSignal, actual] = removeFreqOffsetChunkSized(signal,2000);
plot(actual);
recoveredBits = sigToBits(actual,12,25); %pulse width of 25, start sampling at index 12 (halfway through the pulse)
corrected = flipCheckBits(recoveredBits);

bytes = uint8('hello world'); %the char function will convert back
disp(sum(xor(bits,recoveredBits)));
disp(sum(xor(bits,corrected)));
%disp([bits corrected]);

end