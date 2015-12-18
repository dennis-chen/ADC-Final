classdef T 
    methods(Static)
        
function padded = padSignal(signal)
    %pads signal vector with 1e5 zeros in the beginning.
    padded = [zeros(1e5,1); signal; zeros(1e5,1)];
end

function packetized = packetizeSignal(signal, packet_size, zero_no)
    %given a packet size, breaks up the signal into the appropriate number
    %of packets with the number of zeros between packets supplied by
    %zero_no
    packet_no = ceil(length(signal)/packet_size);
    disp('Number of packets ');
    disp(packet_no);
    packetized = zeros(length(signal) + packet_no*zero_no, 1);
    for i=1:packet_no
        start = (i-1)*length(signal)/packet_no +1;
        finish = i*length(signal)/packet_no;
        disp('PACKET SIZE '); 
        if finish >length(signal)
            x = [signal(start:end); zeros(finish-length(signal)+zero_no, 1)];
            disp(length(x)-zero_no);
        else 
            x = [signal(start:finish); zeros(zero_no, 1)];
            disp(length(x)-zero_no);
        end
        packetized((i-1)*(length(signal)/packet_no+zero_no)+1:i*length(signal)/packet_no+zero_no*i) = x;
    end
end

function datFormat = signalToDATFormat(signal)
    %write the signal out in the dat format that we exepct where every odd
    %element is the real part and every even element is the imaginary part
   realSignal = real(signal);
   imagSignal = imag(signal);
   datFormat = zeros(2*length(signal),1);
   datFormat(1:2:end) = realSignal;
   datFormat(2:2:end) = imagSignal;
end

function void = writeToDATFile(vector,fileName)
   %writes a vector to a DAT file with specified name.
   file = fopen(fileName, 'w');
   fwrite(file, vector, 'float32');
   fclose(file);
end

function void = writeSigToDATFile(signal,fileName)
   %writes a signal vector to a DAT file with specified name. The
   %real part of the vector is interleaved with the imaginary part
   %of the vector. Ex [1+2i,3+4i,0+1i...] is converted to 
   %[1,2,3,4,0,1...] and then written to the DAT file since the UHD
   %expects this format.
   file = fopen(fileName, 'w');
   realSignal = real(signal);
   imagSignal = imag(signal);
   toWrite = signalToDATFormat(signal);
   plot(toWrite);
   fwrite(file, toWrite, 'float32');
   fclose(file);
end

function img = getGreyscale(fileName)
   %returns matrix w/ byte vals from 0 to 255 representing
   %grayscale values of image stored in file
   img = rgb2gray(imread(fileName));
end

function bits = byteToBit(bytes)
    %takes in a vector of bytes, converts each byte to a vector of bits to
    %return a bit vector
    bits = zeros(length(bytes)*8,1);
    for i = 1:length(bytes)
       bits(8*(i-1)+1:8*(i-1)+8) = de2bi(bytes(i),8,'left-msb'); 
    end
end

function imageBits = imageToBitVector(fileName)
   %returns image file as a bit vector (column).
   %the image is reshaped by concatenating columns, ex. the first 16
   %elements of the vector will represent byte vals of the first 2 
   %pixels in the top ROW of the image. Assumes image is grayscale alredy
   img = imread(fileName);
   bytes = reshape(img,1,[]);
   imageBits = T.byteToBit(bytes);
end

function bytes = bitToByte(bits)
    bytes = zeros(length(bits)/8,1);
    for i = 1:length(bytes)
       bytes(i) = bi2de(bits(8*(i-1)+1:8*(i-1)+8)','left-msb');
    end
end
    
function img = bitsToImage(bits,shape)
   %takes bit vector and image shape (ex) [400 400] for a 400 by 400
   %pixel image, and creates the image.
   bytes = T.bitToByte(bits);
   img = reshape(bytes,shape(1),shape(2));
end

function stringBits = stringToBitVector(string)
   %converts a string to a bit vector array (column). Unicode
   %chars, so each letter is a byte.
   bytes = uint8(string); %the char function will convert back
   stringBits = T.byteToBit(bytes);
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
    %test function to determine if converting image to bits, padding, and
    %wrtiing to dat file was working
    SIGNAL_AMP = 50;
    imgBits = imageToBitVector(fileName);
    signal = padSignal(encodeBits(imgBits,SIGNAL_AMP));
    writeToDATFile(signal,'image.dat');
end

function void = transmitString(string)
    %test function to determine if converting string to bits, padding, and
    %wrtiing to dat file was working
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
   pulsed = pulsed(1:length(encoded)*length(pulse));
end

function res = addCheckBits(vector)
    disp('Number of bits in total ');
    disp(length(vector)/8*10)
    res = zeros((length(vector)/8)*10,1);
    for i = 1:8:length(vector)
       res(10*(i-1)/8+1:10*(i-1)/8+2) = [1 0];
       res(10*(i-1)/8+3:10*(i-1)/8+10) = vector(i:i+7);
    end
end


    end
end
