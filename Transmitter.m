function r = Transmitter()

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
       fwrite(file, toWrite, 'float32');
       fclose(file);
    end

    function img = getGreyscale(fileName)
       %returns matrix w/ byte vals from 0 to 255 representing
       %grayscale values of image stored in file.
       img = rgb2gray(imread(fileName));
    end

    function bits = byteToBitVector(bytes)
        bits = zeros(length(bytes)*8,1);
        for i = 1:length(bytes)
           bits(8*(i-1)+1:8*(i-1)+8) = de2bi(bytes(i),8); 
        end
    end

    function imageBits = imageToBitVector(fileName)
       %returns image file as a bit vector (column).
       %the image is reshaped by concatenating rows, ex. the first 16
       %elements of the vector will represent byte vals of the first 2 
       %pixels in the top ROW of the image.
       img = getGreyscale(fileName);
       bytes = reshape(img.',1,[]);
       imageBits = byteToBitVector(bytes);
    end

    function img = bitVectorToImage(bits,shape)
       %takes bit vector and image shape (ex) [400 400] for a 400 by 400
       %pixel image, and creates the image.
       
       %TODO: IMPLEMENT ME
    end

    function stringBits = stringToBitVector(string)
       %converts a string to a bit vector array (column). Unicode
       %chars, so each letter is a byte.
       bytes = uint8(string); %the char function will convert back
       stringBits = byteToBitVector(bytes);
    end

    function string = bitVectorToString(bits)
        %converts a bit vector into a string
        
        %TODO: IMPLEMENT ME
    end

    function encoded = encodeBits(bits,amplitude)
       %converts bit array of ones and zeros to bit array of +V and -V
       %where V is the amplitude specified.
       signal = bits;
       signal(signal == 0) = -1;
       signal = signal * amplitude;
    end

    function bits = decodeSignal(signal)
       %converts signal to bits with the assumption
       %that signal is entirely real and that > 0 = 1 and < 0 = 0
       
    end

    function void = transmitImage(fileName)
        SIGNAL_AMP = 50;
        imgBits = imageToBitVector(fileName);
        signal = padSignal(encodeBits(imgBits,SIGNAL_AMP));
        writeToDATFile(signal,'image.dat');
    end

    function void = transmitString(string)
        SIGNAL_AMP = 50;
        stringBits = stringToBitVector(string);
        signal = padSignal(encodeBits(stringBits,SIGNAL_AMP));
        writeToDATFile(signal,'string.dat');
    end

    function void = testImgEncodeDecode(fileName)
       %encodes to and decodes from bit vector in order
       %to test img encoding functions.
    end

    function void = testStringEncodeDecode(string)
       %encodes to and decodes from bit vector in order
       %to test string encoding functions.
    end

    %transmitImage('sidhartan.jpg');
    transmitString('hello');
    
end
