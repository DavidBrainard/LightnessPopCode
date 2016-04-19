function [theSubstructArray,index] = SubstructArrayFromStructArray(theStructArray,theSubstruct,filterFieldNames,filterFieldVals,booleanStrings)
% [theSubstructArray,index] = SubstructArrayFromStructArray(theStructArray,theSubstruct,filterFieldNames,filterFieldVals,booleanStrings)
%
% Take a struct array as input, and get the index that returns the
% entries after filtering out any values as specified in the filter info.
%
% You can just pass an index for filterFieldNames, in which case there
% should not be a filterFieldVals.
%
% The booleanStrings array allows control of the boolean operation used
% in the filter
%   'equal' - return all entries where equality hold
%   'greatereq' - return all entries greater than or equal to the specified value.
%   'lesseq' - return all entries less than or equal to the specified value.
%   'greater' - return all entries greater than the specified value.
%   'less' - return all entries less than the specified value.
%
% Then return the indicated substruct as a struct array.  Also return the
% filtering index.
%
% 4/19/16  dhb  Wrote it.

% Deal with optional arguments.
if (nargin < 3)
    filterFieldVals = [];
    booleanStrings = {};
end
if (nargin < 4)
    booleanStrings = {};
end



for ii = 1:length(index)
    theArrayEvalStr = ['theSubstructArray(ii) = [theStructArray(index).' theField '];'];

end
% Pull out the field we want
eval(theArrayEvalStr);
    
end

