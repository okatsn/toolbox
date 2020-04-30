function whiteImage2 =whiteimage(N,M,format1)
% create a white image
% imi = whiteimage(400,600,'RGB');
datatype = 'uint8';
switch format1
    case 'RGB'
        
        whiteImage2 = 255 * ones(N, M, 3, datatype);
    case 'gray'
        whiteImage2 = 255 * ones(N, M, datatype);
end

end

