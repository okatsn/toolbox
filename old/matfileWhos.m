function [outputTable] = matfileWhos(matfile1)
details = whos(matfile1);
field2remove = {'global','persistent','nesting'}; % since it is not a valid name when converting to table
details = rmfield(details,field2remove); % since
Tb = struct2table(details);
NoR = size(Tb,1);
Tb.value = cell(NoR,1);
Nms = Tb.name;
for i = 1:NoR
    if Tb.bytes(i)<500
        content_i = matfile1.(Nms{i});
    else
        content_i = 'Too large';
    end
    Tb.value{i} = content_i;
end

outputTable = tableTranspose(Tb);

end

