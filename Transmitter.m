function r = Transmitter()

    function void = writeToDATFile(signal,fileName)
       %writes a signal vector to a DAT file with specified name. The
       %real part of the vector is interleaved with the imaginary part
       %of the vector. Ex [1+2i,3+4i,0+1i...] is converted to 
       %[1,2,3,4,0,1...] and then written to the DAT file since the UHD
       %expects this format.
       
       %TODO implement the rest of this
    end

    function img = getGreyscale(fileName)
       %returns matrix w/ byte vals from 0 to 255 representing
       %grayscale values of image stored in file.
       img = rgb2gray(imread(fileName));
    end

    function bits = byteToBitVector(bytes)
        bits = 'IMPLEMENT ME';
    end

    function imageBits = imageToBitVector(fileName)
       %returns image file as a bit vector (column).
       %the image is reshaped by concatenating rows, ex. the first 16
       %elements of the vector will represent byte vals of the first 2 
       %pixels in the top ROW of the image.
       img = getGreyscale(fileName);
       size(img)
       bytes = reshape(img.',[],1);
       imageBits = byteToBitVector(bytes);
       %TODO implement the rest of this
    end

    function stringBits = stringToBitVector(string)
       %converts a string to a bit vector array (column). Unicode
       %chars, so each letter is a byte.
       bytes = uint8(string); %the char function will convert back
       stringBits = byteToBitVector(bytes);
    end

    imageToBitVector('baboon.jpg');
    stringToBitVector('hello');

end
