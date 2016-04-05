function [theArray,index] = FilterAndGetFieldFromStructArray(theStructArray,theField,filterFieldNames,filterFieldVals)
% [theArray,index] = FilterAndGetFieldFromStructArray(theStructArray,theField,filterFieldNames,filterFieldVals)
%
% Take a struct array as input, and find all elements that match the
% criteria in the filterField inputs.
%
% Then return the indicated field as a regular old array.
%
% 4/1/16  dhb  Wrote it.

%% Get some basic info
nParams = length(theStructArray);

%% Filtering (or not)
%
% No filtering
if (nargin < 3 | isempty(filterFieldNames) | isempty(filterFieldVals))
    index = 1:nParams;
else
    if (length(filterFieldNames) ~= length(filterFieldVals))
        error('Mismatch in names and values for filtering');
    end
    
    boolean0 = ones(size(1:nParams));
    for ii = 1:length(filterFieldNames)
        filterFieldName = filterFieldNames{ii};
        if (~isstr(filterFieldName))
            error('Filter names must be strings');
        end
        
        filterFieldVal = filterFieldVals{ii};
        if (isstr(filterFieldVal))
            theFilterEvalStr = ['boolean1 = strcmp({theStructArray(:).' filterFieldName '},''' filterFieldVal ''');'];
        elseif (isnumeric(filterFieldVal))
            theFilterEvalStr = ['boolean1 = ([theStructArray(:).' filterFieldName '] == ' num2str(filterFieldVal) ');'];
        else
            error('Can only filter on strings or numbers');
        end
        eval(theFilterEvalStr);
        booleanTmp = boolean0 & boolean1;
        boolean0 = boolean1;
        boolean1 = booleanTmp;
    end
    index = find(boolean1);
end

% Pull out the field we want
theArrayEvalStr = ['theArray = [theStructArray(index).' theField '];'];
eval(theArrayEvalStr);
    
end

