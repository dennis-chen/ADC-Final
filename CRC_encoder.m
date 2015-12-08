function encoded_message = CRC_encoder(message, gen_poly)
    % computes the remainder of the message divided by the gen_poly
    to_divide = [message zeros(1,length(gen_poly)-1, 1)];
    index = 1;
    while (index < length(message) + 1) 
        if(to_divide(index) == 1)
           for i = 0:length(gen_poly)-1
              compare_index = index +i;
              to_divide(compare_index) = xor(to_divide(compare_index), gen_poly(i+1));
           end        
        end
        index = index + 1;
    end
    encoded_message = [message to_divide(length(message)+1:length(to_divide))];

end