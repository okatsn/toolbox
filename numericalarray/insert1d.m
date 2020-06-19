function [to_this2] = insert1d(items,to_this,rigth_after)
% rigth_after = [1,3,5,11];
% items = [99.2, 38.2, 1.5, 43.3];
shift1 = 1;
isitchar = false;
itemclass = class(items);
k = 0;
switch itemclass
    case 'cell'
%          isitcell = true;
        if isa(items{1},'char')
            isitchar = true;
%             k=1;
        else
%             k = 0;
        end
        
    case 'char'
        items = {items};
        isitchar = true;
%         k=0;
        
    otherwise
%         k = 0;
end

ArraySz = size(to_this);
if isequal(ArraySz,[1,1]) 
    catdir = 2;% to prevent error of cat(1,x(1:1),'to_insert',x(2:end))
    %  cat(2,x(1:1),'to_insert',x(2:end)) is okay.
else
    [~,catdir]  = max(ArraySz);
end
insert = @(a, x, n) cat(catdir,  x(1:n), a, x(n+1:end));

shift1 = length(items{1});
for iii = rigth_after
    if isitchar
%         if k~=1
            iii = iii+k*shift1; k=k+1; % shift as the increase of element of to_this.
%         end
        itemk = items{k};
        
        shift1 = length(itemk);
        to_this = insert(itemk,to_this,iii); % insert item to to_this after iii.
        

    else
        iii = iii+k; k=k+1; % shift as the increase of element of to_this.
        to_this = insert(items(k),to_this,iii); % insert item to to_this after iii.    
    end
    
    
end
to_this2 = to_this;

end


% for i = range1
%     i = i+k; k=k+1; % shift as the increase of element of inputcell.
%     fpos = inputcell{i}.Position(3:4);
%     inputcell = insert(fpos,inputcell,i); % insert fpos to inputcell after i.
%     
% end