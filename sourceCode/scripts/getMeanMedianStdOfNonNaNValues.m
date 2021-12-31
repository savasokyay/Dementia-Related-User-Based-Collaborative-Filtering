function [r_length, r_mean, r_median, r_std]=getMeanMedianStdOfNonNaNValues(vector)
%	@author @savasokyay
%	@date 	2020.12.21
%	@brief 	Statistical parameters are pre-computed once to be used
%           directly in some functions

nonNaNValues = vector(find(~isnan(vector))); 
r_length = length(nonNaNValues);
r_mean   = mean(nonNaNValues); 
r_median = median(nonNaNValues); 
r_std    = std(nonNaNValues,1);

end %end of function