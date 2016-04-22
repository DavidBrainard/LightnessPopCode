function [theSubstructArray,index] = SubstructArrayFromStructArray(theStructArray,theSubstruct,filterFieldNames,filterFieldVals,booleanStrings)
% [theSubstructArray,index] = SubstructArrayFromStructArray(theStructArray,theSubstruct,filterFieldNames,filterFieldVals,booleanStrings)
%
% Take a struct array as input, and get the index that returns the
% entries after filtering out any values as specified in the filter info.
% Then return the indicated substruct as a struct array.  Also return the
% filtering index.
%
% See GetFilteringIndex for information on how the filtering is done.
%
% See also FilterAndGetFieldFromStrucArray
%
% Examples:
% 1) Get the decodeBoth structure field as a struct array, taking all of them with no filtering
%   paintShadowEffectDecodeBoth = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');
%
% 4/19/16  dhb  Wrote it.

% Deal with optional arguments.
if (nargin < 3)
    filterFieldNames = {};
end
if (nargin < 4)
    filterFieldVals = {};
end
if (nargin < 5)
    booleanStrings = {};
end

% Get the index
index = GetFilteringIndex(theStructArray,filterFieldNames,filterFieldVals,booleanStrings);

% Pull out the entries we want.
for ii = 1:length(index)
    theArrayEvalStr = ['theSubstructArray(ii) = theStructArray(index(ii)).' theSubstruct ';'];
    eval(theArrayEvalStr);
end
    
end

