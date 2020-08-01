function [varargout] = mapto(function_handle,varargin)
% map a function handle to variables
% Example 1, apply sum to var1, var2,... individually
%     [sum_1,sum_2,...] = mapto(@sum, var1,var2,...);
% Example 2, apply sqrt firts, then apply sum, for var1, var2,...
%     [sqrt_sum_1,sqrt_sum_2,...] = mapto({@sqrt,@sum}, var1,var2,...);


if ~iscell(function_handle)
    function_handle = {function_handle};
end
len_function = length(function_handle);

varargout = varargin;
for i = 1:len_function
    varargout = cellfun(function_handle{i}, varargout, 'UniformOutput', false);
end
end

