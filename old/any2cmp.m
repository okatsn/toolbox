function [tf] = any2cmp(A,B,varargin)
%% compare any two inputs.
typeA = class(A);
typeB = class(B);

if ~strcmp(typeA,typeB)
    msg = sprintf('Type of the two variables are not equal, where 1: %s; 2: %s',typeA,typeB);
    tf = false;
else
    typeAB = typeA;
    switch typeAB
        case 'double'
            tf = isequaln(A,B);
            if tf
                msg = sprintf('They are totally the same (type: %s)',typeAB);
            else
                msg = sprintf('They are different.  (type: %s)',typeAB);
            end
            
        case 'table'
            A = A{:,:};
            B = B{:,:};
            tf = isequaln(A,B);
            
            if tf
                msg = sprintf('Contents of the tables are the same.');
            else
                msg = sprintf('They are different.');
            end

    end
    


   tf = true; 
end %strcmp(typeA,typeB)       

%% print info
if nargin == 3
        switch varargin{1}
            case {'Info','info'}
                fprintf('%s:%s',varargin{1},msg);

        end
end
        
end

