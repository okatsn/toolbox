function [S2] = pullpushfields(S,varargin)
% 1. pull fields (of the first layer specified by field names) out of a
% structure.
% Input example:
%     S = struct('a',1,'b',2,'c',3);
%     S2 = pullpushfields(S,'a','b');
% Output example:
%         S2 = 
% 
%           struct with fields:
% 
%             a: 1
%             b: 2
% 
% 2. push (restore) fields back to the structure.
% example:
%     S = pullpushfields(S,S2);
%     
% This function is designed for axes restoration.
% For example, 
%     ax = gca;
%     XTick0 = ax.XTick;
%     XTickLabel0 = ax.XTickLabel;
%     YTick0 = ax.YTick;
%     YTickLabel0 = ax.YTickLabel;
%     XLim0 = ax.XLim;
%     YLim0 = ax.YLim;
%         
%     fx = gcf;
%     fx.Position = [100 100 400 300];
%     % The change in position often makes X, Y ticks changed.
%     % The following is for restoring the previous setting:
%     ax.XTick = XTick0;
%     ax.XTickLabel = XTickLabel0;
%     ax.YTick = YTick0;
%     ax.YTickLabel = YTickLabel0;
%     ax.XLim = XLim0;
%     ax.YLim = YLim0;
% and this can be simplified as
%     ax = gca;
%     ax0 = pullpushfields(ax,'XTick','XTickLabel','YTick','YTickLabel','XLim','YLim');
%     fx = gcf;
%     fx.Position = [100 100 400 300];
%     pullpushfields(ax,ax0);
do_pull = false;
if ischar(varargin{1})
    do_pull = true;
    if ~all(ismember(varargin,fieldnames(S)))
        error('Incorrect field names. Check the spelling.');
    end
end

if do_pull
    S2 = struct();
    for i = 1:length(varargin)
        fieldNm = varargin{i};
        S2.(fieldNm) = S.(fieldNm);
    end
else % do push
    S2 = varargin{1};
    fieldNms2 = fieldnames(S2);
    for i = 1:length(fieldNms2)    
        S.(fieldNms2{i}) = S2.(fieldNms2{i});
    end
    S2 = S;
end


end

