function r = Transmitter()

close all;

    function padded = padSignal(signal)
        %pads signal vector with 1e5 zeros in the beginning.
        padded = [zeros(1e5,1); signal];
    end

    function void = writeToDATFile(signal,fileName)
       %writes a signal vector to a DAT file with specified name. The
       %real part of the vector is interleaved with the imaginary part
       %of the vector. Ex [1+2i,3+4i,0+1i...] is converted to 
       %[1,2,3,4,0,1...] and then written to the DAT file since the UHD
       %expects this format.
       file = fopen(fileName, 'w');
       realSignal = real(signal);
       imagSignal = imag(signal);
       toWrite = zeros(1,2*length(signal));
       toWrite(1:2:end) = realSignal;
       toWrite(2:2:end) = imagSignal;
       plot(toWrite);
       fwrite(file, toWrite, 'float32');
       fclose(file);
    end

    function img = getGreyscale(fileName)
       %returns matrix w/ byte vals from 0 to 255 representing
       %grayscale values of image stored in file.
       img = rgb2gray(imread(fileName));
    end

    function bits = byteToBit(bytes)
        bits = zeros(length(bytes)*8,1);
        for i = 1:length(bytes)
           bits(8*(i-1)+1:8*(i-1)+8) = de2bi(bytes(i),8); 
        end
    end

    function bytes = bitToByte(bits)
        bytes = zeros(length(bits)/8,1);
        for i = 1:length(bytes)
           bytes(i) = bi2de(bits(8*(i-1)+1:8*(i-1)+8)');
        end
    end

    function imageBits = imageToBitVector(fileName)
       %returns image file as a bit vector (column).
       %the image is reshaped by concatenating columns, ex. the first 16
       %elements of the vector will represent byte vals of the first 2 
       %pixels in the top ROW of the image.
       img = getGreyscale(fileName);
       bytes = reshape(img,1,[]);
       imageBits = byteToBit(bytes);
    end

    function img = bitsToImage(bits,shape)
       %takes bit vector and image shape (ex) [400 400] for a 400 by 400
       %pixel image, and creates the image.
       bytes = bitToByte(bits);
       img = reshape(bytes,shape(0),shape(1));
    end

    function stringBits = stringToBitVector(string)
       %converts a string to a bit vector array (column). Unicode
       %chars, so each letter is a byte.
       bytes = uint8(string); %the char function will convert back
       stringBits = byteToBit(bytes);
    end

    function string = bitsToString(bits)
        %converts a bit vector into a string
        bytes = bitToByte(bits);
        string = char(bytes');
    end

    function encoded = encodeBits(bits,amplitude)
       %converts bit array of ones and zeros to bit array of +V and -V
       %where V is the amplitude specified.
       encoded = (bits*2-1) * amplitude;
    end

    function bits = decodeSignal(signal)
       %converts signal to bits with the assumption
       %that signal is entirely real and that > 0 = 1 and < 0 = 0
       bits = signal(:);
       bits(bits >= 0) = 1;
       bits(bits < 0) = 0;
    end

    function void = transmitImage(fileName)
        SIGNAL_AMP = 50;
        imgBits = imageToBitVector(fileName);
        signal = padSignal(encodeBits(imgBits,SIGNAL_AMP));
        writeToDATFile(signal,'image.dat');
    end

    function void = transmitString(string)
        SIGNAL_AMP = 1;
        stringBits = stringToBitVector(string);
        signal = padSignal(encodeBits(stringBits,SIGNAL_AMP));
        plot(signal);
        writeToDATFile(signal,'string.dat');
    end

    function void = testImgEncodeDecode(fileName)
       %encodes to and decodes from bit vector in order
       %to test img encoding functions.
       SIGNAL_AMP = 50;
       originalImg = getGreyScale(fileName);
       imgBits = imageToBitVector(originalImg);
       encoded = encodeBits(imgBits,SIGNAL_AMP);
       decoded = decodeSignal(encoded);
       %IMPLEMENT ME
    end

    function void = testStringEncodeDecode(string)
       %encodes to and decodes from bit vector in order
       %to test string encoding functions.
       SIGNAL_AMP = 50;
       stringBits = stringToBitVector(string);
       encoded = encodeBits(stringBits,SIGNAL_AMP);
       decoded = decodeSignal(encoded);
       string = bitsToString(decoded);
       disp(string);
    end

    function pulsed = convPulse(encoded,pulse)
       %Expects vector of +-Vs in encoded.
       upSampled = upsample(encoded, length(pulse));
       pulsed = conv(upSampled,pulse);
    end

    function h = raisedCosineIR(t, alpha, T)
        %   siddhartan's function
        %   returns the impuse response of a raised cosine filter
        %   t - time indices to evaluate the impulse response at
        %   alpha - roll-off factor
        %   T - symbol period
        h = sinc(t/T).*(cos(pi*alpha*t/T)./(1-4*alpha^2*t.^2/T^2));
    end

    stringToBitVector('hello world');
    %testImgEncodeDecode('sidhartan.jpg');
    %testStringEncodeDecode('abcdefghijklmnopqrstuvwxyz');
    %transmitImage('sidhartan.jpg');
    %transmitString('hello');
    encoded = encodeBits(stringToBitVector('hello'),5)
    pulsed = convPulse(encoded,ones(200,1));
    plot(pulsed);
end
