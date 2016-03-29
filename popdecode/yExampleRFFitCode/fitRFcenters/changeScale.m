function [result unit] = changeScale(x,iLo,iHi,fLo,fHi)
% CHANGESCALE rescales x from iLo-iHi scale to fLo-fHi scale.
%   iLo - low end of initial scale
%   iHi - high end of initial scale
%   fLo - low end of final scale
%   fHi - high end of final scale
%   result - the result of the scaling
%   unit - amplitude of how 1 unit on initial scale maps onto the final
%       scale
%
%   Examples: 
%       [result unit] = changeScale(3,1,5,1,10) Changes a 3-star rating on
%           the 1-5 star scale to a 1-10 scale. result = 5.5, unit = 2.25
%       [result unit] = changeScale(200,0,100,0,-10)
%           result = -20, unit = .1
%    
%   See also PLOTRFS, ANALYZERFS.

%% AUTHOR    : Jeffrey Chiou 
%% $DATE     : 26-Feb-2013 14:43:32 $ 
%% $Revision : 1.00 $ 
%% DEVELOPED : 7.14.0.739 (R2012a) 
%% FILENAME  : changeScale.m 

% Solve the linear eqns to normalize
a = [iLo,1; iHi,1];
b = [fLo; fHi];
scale = a\b;

result = x*scale(1)+scale(2);

% Unit scaling - Different from x y scaling because numbers always start at
% 0 - need to find how much 1 unit increments by. Must be positive, so use
% absolute value
unit = abs( (2*scale(1)+scale(2))-(1*scale(1)+scale(2)) );

end 
