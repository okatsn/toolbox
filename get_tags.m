function [O] = get_tags(inputchar, varargin)
% inputchar = 'XXXX_trn[20190510].matXXXX_frc[20190808].mat';
% Example 1:
%     O = get_tags(inputstring,'Prefix',{'trn','frc'},'reshape',{'Row',pf_iters},'unique',1);
%     tags_trn = O.trn;
%     tags_frc = O.frc;
% Example 2:
%     tag = get_tags(inputstring,'trn','once');% 
%     if the last argument is 'once', Name_value pair is not supported.
%
% Name-value pairs:
%     get_tags(...,'unique',1,...)
%     do_unique will only get non-repeat values from a string with multiple
%     identical tag names. 
%     E.g. 
%         for inputchar is 
%             '[XX]_trn[2020]_1.mat[XX]_trn[2020]_2.mat[XX]_trn[2021]_1.mat'
%         O.trn will be 
%             {2020,2021}
% 


default_expr = '(?<=%s\\[).+?(?=\\])';

        match_expr_func = @(x) sprintf(default_expr,x);
% if nargin == 1 
%     tags = regexp(inputchar,match_expr_func('[a-zA-Z]'),'match');
%     for i = 1:length(tags)
%         name_i = regexp(tags,sprintf('[a-zA-Z]'),'match','once');    
%     end
%     
%     disp('Automatically ')
%     return
% end



if strcmp(varargin{end},'once')
    prefix = varargin{1};
    switch class(prefix)
        case 'char'
            O = regexp(inputchar,match_expr_func(prefix),'match','once');
        case 'cell'
            O = struct();
            for i = 1:length(prefix)
                fieldnm = prefix{i};
                O.(fieldnm) = regexp(inputchar,match_expr_func(fieldnm),'match','once');
            end
        otherwise
            error("Incorrect input format. 2nd argument have to be prefix of class 'char' or 'cell'.");
    end
    
    if nargin~=3
        error("[get_tags] Incorrect numbers of input. Wrong use of 'once', please check.");
    end
    return % if the last argument is 'once', the following is ignored.
end

validreshape = @(x) iscell(x) && length(x) ==2 && any(validatestring(x{1},{'Row','Column'}));
p = inputParser;
% addParameter(p,'datalist',0);
addParameter(p,'Prefix',''); % e.g. 'trn' for inputstring 'xxxx_trn[name_of_tag]'
addParameter(p,'unique',0);
addParameter(p,'ExpressionHandle',match_expr_func);
addParameter(p,'reshape',{},validreshape); % e.g. 'reshape,'{'Row',3} will reshape the output cell array to 3 by N
% addParameter(p,'Train',0);
parse(p,varargin{:});
prefix = p.Results.Prefix;
do_unique = p.Results.unique;
do_reshape = p.Results.reshape;
match_expr_func = p.Results.ExpressionHandle;



% do_datalist = p.Results.datalist;

% if ~isequal(do_datalist,0) && iszeroinput


if ~isempty(do_reshape)
    reshape2N =  do_reshape{1}; % 'Row' or 'Column'
    pf_iters = do_reshape{2};
    do_reshape = true;
else
    do_reshape = false; % if it is empty
end

switch class(prefix)
    case 'char'
        prefix = {prefix};
    case 'cell'
        
end


for i = 1:numel(prefix)
    prefix_i = prefix{i};
     % '(?<=%s\\[).+?(?=\\])'
%     switch prefix_i
%         case 'trn' % training tag like 'trn[20060101-20120202]'
%     match_expr = sprintf('(?<=%s\\[).+?(?=\\])',prefix_i);
%     trn_tags = regexp(inputchar,match_expr,'match');
    trn_tags = regexp(inputchar,match_expr_func(prefix_i),'match');   
    
    if do_unique
        trn_tags = unique(trn_tags);
    end
    
    if do_reshape % this is usually for parfor
        numeltrntags = length(trn_tags); % must unique first.
        N_col = ceil(numeltrntags/pf_iters);
        N_addEmptyCells = N_col*pf_iters - numeltrntags;
        trn_tags =  [trn_tags, cell(1,N_addEmptyCells)]; % add empty cells in order to reshape
        switch reshape2N
            case 'Row'
                trn_tags = reshape(trn_tags,[],N_col);
            case 'Column'
                trn_tags = reshape(trn_tags,N_col,[]);
        end
    end
    
    O.(prefix_i) = trn_tags;

end

end

