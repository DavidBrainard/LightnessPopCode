function [theSubstructArray,index] = SubstructArrayFromStructArray(theStructArray,theSubstruct,filterFieldNames,filterFieldVals,booleanStrings)
% [theSubstructArray,index] = SubstructArrayFromStructArray(theStructArray,theSubstruct,filterFieldNames,filterFieldVals,booleanStrings)
%
% Take a struct array as input, and get the index that returns the
% entries after filtering out any values as specified in the filter info.
% Then return the indicated substruct as an array, concatenated together.  Also return the
% filtering index.
%
% See GetFilteringIndex for information on how the filtering is done.
%
% See also FilterAndGetFieldFromStrucArray
%
% This handles cases where each entry of the field is a scalar or a vector,
% and tries to be smart about what to do with row and column vectors.  In
% the latter two cases, these come back as the rows or as the columns of
% the returned matrix, while in the scalar case you get vector back.
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

% Get size of the field so we can figure out how to pack it for return
eval(['[m,n] = size(theStructArray(1).' theSubstruct ');'])

% Pull out the entries we want.
for ii = 1:length(index) 
    if (m == 1 & n == 1)
        theArrayEvalStr = ['theSubstructArray(ii) = theStructArray(index(ii)).' theSubstruct ';'];
    elseif (n == 1)
        theArrayEvalStr = ['theSubstructArray(:,ii) = theStructArray(index(ii)).' theSubstruct ';'];
    elseif (m == 1)
        theArrayEvalStr = ['theSubstructArray(ii,:) = theStructArray(index(ii)).' theSubstruct ';'];
    end
    eval(theArrayEvalStr);
end

end

