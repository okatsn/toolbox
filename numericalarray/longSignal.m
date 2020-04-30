function [inputXY2] = longSignal(Files,varargin)
%     Ts_List = datalist('[TW]20070201*','G:\CWBMagnetism2','Search','**');
%     XYcell4plot = longSignal(Ts_List,'Column',7); 
%     figure; 
%     plot(XYcell4plot{:});
% OR
%     XYcell4plot = longSignal(Ts_List,'Column',[7,8]); 
%     Mcol7 = XYcell4plot{1};
%     Mcol8 = XYcell4plot{2};
%     plot(Mcol7,Mcol8);
% 2020/04/29: new feature!
%     [inputXY2] = longSignal(Files,'Preprocess',{@windowAverage, 'WindowWidth',100});
%     - In this way the output long signal is window averaged, and won't exceed maximum memory!
%     - the 1st argument of the function of 'Preprocess' must be M that
%     from M = importdata() in this function. If the function of
%     'Preprocess' requires two or more required arguments, error will
%     occur.

do_nothing = @(M) M;
default_read = @(x) importdata(x);
p = inputParser;
addParameter(p,'Row',0); % the index (indices) for the row of Y (X and Y). 
addParameter(p,'Column',0); % the index (indices) for the column of Y (X and Y). 
addParameter(p,'Preprocess',0); % 'Preprocess',{@windowAverage, 'WindowWidth',100} that will do M = windowAverage(M, 'WindowWidth',100);
addParameter(p,'ReadFunction',0); % 'ReadFunction' allows alternative ways other than importdata() to read the numerical array out from the file.
parse(p,varargin{:});
idR = p.Results.Row;
idC = p.Results.Column;
preprocess = p.Results.Preprocess;
readfunction = p.Results.ReadFunction;


if ~isequal(preprocess, 0)
    do_preprocess = true;
  switch class(preprocess)
      case 'cell'
          preprocessfunc = preprocess{1};
          if ~isa(preprocessfunc,'function_handle')
                error("Value for 'Preprocess' must be {a_function_handle, optional_input, ...}");
          end
          
          varargin1 = preprocess(2:end);
      case 'function_handle'
          preprocessfunc = preprocess;
          varargin1 = {};
  end
else
    do_preprocess = false;
%     preprocessfunc = do_nothing;
end

if isequal(readfunction, 0)
    readdata = default_read; % default method of reading the file.
elseif isequal(readfunction, 0) && isa(readfunction,'function_handle')
    readdata = readfunction;
else
    error("Value for 'ReadFunction' must be a function handle.");
end

if ~isequal(idR,0) && ~isequal(idC,0) 
    error("Specifying both 'Row' or 'Column' at the same time is not acceptable.");
end

if ~isequal(idR,0) % that is idC ~= 0
    alongDir = 2; % dataY is 1 by N
    nid = numel(idR);
elseif ~isequal(idC,0) 
    alongDir = 1; % data Y is N by 1
    nid = numel(idC);
else
    error("You must specify the number of either 'Row' or 'Column' .");
end


% isNby1 = false;
% if (isequal(idR,0) && isequal(idC,0)) || ~isequal(idC,0)
%     isNby1 = true;
% end 
% isequal(idR,0) && isequal(idC,0): default is N by 1
% ~isequal(idC,0) means that Column index is specified, and hence N by 1.


if isstring(Files) && isfolder(Files)
    TsDatalist = datalist('*',Files,'Search','**FileOnly');
elseif isa(Files,'table') && strcmp(Files.Properties.Description,'datalist')
    TsDatalist = Files;
elseif isa(Files,'matlab.io.MatFile')
    TsDatalist = 0;
    error('under construction');
else
    error('Invalid file input.');
end

NoR = size(TsDatalist,1);
inputXY2 = [];
for i = 1:NoR
    target_dir = TsDatalist.fullpath{i};
%     M = importdata(target_dir);
    M = readdata(target_dir);
    if do_preprocess
        M = preprocessfunc(M, varargin1{:});
    end
    
%     [SzMR,SzMC] = size(M);
    
    if alongDir==1
        inputXY = M(:,idC);       
    elseif alongDir==2
        inputXY = M(idR,:);
        inputXY = inputXY';
    else
        error("This error should never occured, please check. Data can only along in direction '1' (vertical) or '2' (horizontal).");
    end
    
    inputXY2 = [inputXY2;inputXY];
%     if autocalculate
%             if isNby1
%                 switch SzMC
%                     case 1
%                         inputXY = {M(:,1)};
%                         
% %                         Yi = M(:,1);
% %                         Xi = [1:length(Yi)]';
%                     case 2
%                         inputXY = {M(:,1),M(:,2)};
% %                         Yi = M(:,2);
% %                         Xi = M(:,1);
%                     otherwise
% 
%                 end
%             else % 1 by N (or m by N, normally m<N)
%                 switch SzMR
%                     case 1
%                         inputXY = {M(1,:)};
% %                         Yi = M(1,:);
% %                         Xi = [1:length(Yi)];
%                     case 2
%                         inputXY = {M(1,:),M(2,:)};
% %                         Yi = M(2,:);
% %                         Xi = M(1,:);
%                     otherwise
% 
%                 end
%             end
%     else % use idR and idC
%         if isNby1
%             if numel(idC)~=1
%                 inputXY = {M(:,idC(1)), M(:,idC(2))};
%             else % idC has only one element
%                 inputXY = {M(:,idC)};
% %                 Xi = [1:length(Yi)]';
%             end
%         else
%             if numel(idR)~=1
%                 inputXY = {M(idR(1),:), M(idR(2),:)};
%             else % idR has only one element
%                 inputXY = {M(idR,:)};
% %                 Xi = [1:length(Yi)]';
%             end
%         end
%     end
    
    
    
    
    

end

[NoR2,NoC2] = size(inputXY2);
% inputXY2 = cell2mat(inputXY2);
inputXY2 = mat2cell(inputXY2,NoR2,ones(1,NoC2)); % also may be output as varargout
% if nargout >1
%     varargout = inputXY2;
% else
%     varargout{1} = inputXY2;
% end
end
