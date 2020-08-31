function [C,varargout] = split_by_thr(Y_i,thr)
% split the input time series by a certain threshold thr.
% [segments_all,desired,undesired] = split_by_thr(Y_i,threshold)
%     - desired: the segments where Y>thr.
%     - undesired: the segments where Y<thr, the data are all replaced by NaN.

errorStruct.identifier = 'Custom:Error';

% if le(thr,0) %thr<=0
% %     errorStruct.message = 'Threshold (2nd argument) cannot be zero.';
% %     error(errorStruct);
%     warning('Threshold is zero. If input timeseries is all positive, then this function do nothing (no split at all).')
% end

Y = Y_i(:); % to make sure Y is N by 1.
Y2 = Y;

lenthr = length(thr);
if lenthr == 1
    Y2(Y2<thr) = NaN;
elseif lenthr
    thr = sort(thr); 
    Y2(Y>thr(1) & Y<thr(2)) = NaN;
else
    error('thr must be scalar or 2-element vector.');
end

id_nan = isnan(Y2);
notNaN = ~id_nan;

id_nansplit = diff(id_nan); % indicates the midpoints that separate NaN and non-NaN elements.
id_cross = adjMultiply(Y2) < 0; % indicates the midpoints where Y(i)*Y(i - 1) are negative.
% ... that is, Y transits from positive to negative, or vice versa.
id_bothOutside = adjAND(notNaN); % indicates the midpoints where both Y(i) and Y(i - 1) are not NaN.
% ... that is, Y(i) and Y(i - 1) are outside thr.
id_nonansplit = and(id_cross, id_bothOutside);
id_split = or(id_nansplit,id_nonansplit);
id_split_ext = [1;id_split;1];
edges = find(id_split_ext); % the edges/boundaries for segments.
id_nonansplit_ext = [0;id_nonansplit;0];
edges2 = sort([edges; find(id_nonansplit_ext)]);
durations = diff(edges2); % the duration/numel of each segment.
C = mat2cell(Y2,durations(:),size(Y2,2));


if nargout>1
    firstseg = C{1};
    if all(isnan(firstseg)) || isempty(firstseg) % all is faster than any
        desired_segment = C(2:2:end);
        undesired_segment = C(1:2:end);
    else
        desired_segment = C(1:2:end);
        undesired_segment = C(2:2:end);
    end
    
    varargout{1} = desired_segment;%
    if nargout>2
        varargout{2} = undesired_segment;
        
        if nargout>3
            undesired_segment_combined = cell2mat(undesired_segment);
            validation = all(isnan(undesired_segment_combined));
            varargout{3} = validation;
            if ~validation
                error('Split failed. The undesired segments should be all NaN, but it is not.');
            else
                disp('Time series split_by_thr validated.');
            end
        end
        
    end
    
end


% https://www.mathworks.com/matlabcentral/answers/335333-split-array-into-separate-arrays-at-row-with-nans
%% test example

% M = [NaN;NaN;0;2;NaN;NaN;NaN;4;6;NaN;NaN;8;9;10;NaN;NaN];
% M = [0;2;NaN;4;6;NaN;NaN;8;9;10;NaN;NaN];
% M = [0;2;NaN;4;6;NaN;NaN;8];
% M = [0;2;4;6;8];
%  id_nan = isnan(M);
%  diff_id_nan = diff(id_nan);
%  B = [1;diff_id_nan;1];
%  id_y = find(B);
%  id_z = diff(id_y);
%  C = mat2cell(M,id_z(:),size(M,2));

end

