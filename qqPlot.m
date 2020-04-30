function [] = qqPlot(data,varargin)
% qqPlot(data,'Normal',{mu,sigma},'Title',sprintf('Q-Q plot of %s',colNms{k}));
%    this plot on existing figures (ax handle).
% qqPlot(data,'Normal',{mu,sigma},'ChiSquare',6); 
%    this gives two figures
NoD = length(data);

errorStruct.identifier = 'Custom:Error';

%% default
P1.Normal = {0,1}; %[mean, std]
P1.Student_t = NaN; % dof
P1.ChiSquare = NaN; %dof
Property_list0 = fieldnames(P1);

P1.LineWidth = 1.5;
P1.Title = 'Q-Q Plot';
P1.YLabel = 'Quantiles for data';
P1.XLabel = 'Theoretic Quantiles';
Property_list_all = fieldnames(P1);


inputkeys = varargin(1:2:end);
inputvals = varargin(2:2:end);



[~,idxatPropList] = ismember(inputkeys,Property_list_all);
[~,idxatDistriFunc] = ismember(inputkeys,Property_list0);

if ~any(idxatDistriFunc)
    msg = 'At least one type of distribution is required. It may be: ';
    for i = 1:length(Property_list0)
        msg = [msg, Property_list0{i}, ' or '];
    end
    msg(end-3:end) = [];
    errorStruct.message = msg;
    error(errorStruct)
end

NoK = numel(idxatPropList);

for i = 1:NoK % update default values
    P1.(Property_list_all{idxatPropList(i)}) = inputvals{i};
end


%% code
% quantile01 = linspace(0,1,NoD);
%  quantile01 =((1:NoD)-0.5)/NoD;
% qqy=sort(data); %sort random numbers in ascending order
[quantile01,qqy] = ecdf(data);

if nnz(idxatDistriFunc)>1
    newfigure = true; 
else 
    newfigure = false;
end

for i = 1:NoK

    switch inputkeys{i}
        case 'Normal'
            if iscell(P1.Normal)      
                qqx=norminv(quantile01,P1.Normal{:}); % theoretic quantiles
            else
                errorStruct.message = "input MUST be an cell array {mean,std}. E.g. ...,'Normal',{0,1},...";
                error(errorStruct)
            end
        case 'ChiSquare'
            if ~isnan(P1.Student_t)
                qqx=chi2inv(quantile01,P1.ChiSquare);
            else
                errorStruct.message = "Degrees of freedom is required. E.g. ...,'ChiSquare',6,...";
                error(errorStruct)
            end
        case 'Student_t'
            if ~isnan(P1.ChiSquare)
                qqx=tinv(quantile01,P1.Student_t); %
            else
                errorStruct.message = "Degrees of freedom is required. E.g. ...,'Student_t',0,...";
                error(errorStruct)
            end
        otherwise
            continue
    end

    %Q-Q plot
    if newfigure
        figure;
    end

%     plot(quantile01,qqy,'*'); hold on; %definitely not true.
    plot(qqx,qqy,'*'); hold on;
    plot(qqx,qqx,'r','LineWidth',P1.LineWidth); grid on;
    xlabel(P1.XLabel);
    ylabel(P1.YLabel);
    title(P1.Title);


end


end

