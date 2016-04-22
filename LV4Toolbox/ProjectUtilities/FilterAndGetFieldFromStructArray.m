function [theArray,index] = FilterAndGetFieldFromStructArray(theStructArray,theField,filterFieldNames,filterFieldVals,booleanStrings)
% [theArray,index] = FilterAndGetFieldFromStructArray(theStructArray,theField,filterFieldNames,filterFieldVals,booleanStrings)
%
% Take a struct array as input, and find all elements that match the
% criteria in the filterField inputs. Then return the indicated field as a regular old array.
%
% See GetFilteringIndex for information on how the filtering is done.
%
% See also SubstructArrayFromStructArray
%
% Examples:
% 1) Get paintRMSE values for all cases where both paint and shadow RMSE were
% less than or equal to 0.2:
%   paintRMSE = GetFilteringIndex(paintShadowEffectDecodeBoth,'paintRMSE',{'paintRMSE' 'shadowRMSE'},{0.2 0.2}, {'<=' '<='});
%
% 2) Get paintRMSE for all sessions with subject JD
%  indexJD = GetFilteringIndex(basicInfo,{'subjectStr'},{whichSubject});
%  paintRMSE = FilterAndGetFieldFromStructArray(paintShadowEffectDecodeBoth,'paintRMSE',indexJD);
%
%
% 4/1/16  dhb  Wrote it.

% Deal with optional args
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

% Pull out the field we want
theArrayEvalStr = ['theArray = [theStructArray(index).' theField '];'];
eval(theArrayEvalStr);
    
end

