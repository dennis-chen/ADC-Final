function valid = CRC_verifier(encoded_message, gen_poly)
    % computes the remainder of the message divided by the gen_poly
    to_divide = [encoded_message];
    index = 1;
    while (index < length(encoded_message) + 1) 
        if(to_divide(index) == 1)
           for i = 0:length(gen_poly)-1
              compare_index = index +i;
              to_divide(compare_index) = xor(to_divide(compare_index), gen_poly(i+1));
           end        
        end
        index = index + 1;        
    end
    
    if to_divide(length(encoded_message)+1:length(to_divide)) == zeros(1, length(parity_bits))
        valid = true;
    else
        valid = false;
    end

end