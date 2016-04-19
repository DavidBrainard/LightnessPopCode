function index = GetFilteringIndex(theStructArray,filterFieldNames,filterFieldVals,booleanThanStrings)
% index = GetFilteringIndex(theStructArray,filterFieldNames,filterFieldVals,booleanStrings)
%
% Get the index of the subarray of the struct that we want, depending on
% the passed filtering values.
%
% You can just pass an index for filterFieldNames, in which case there
% should not be a filterFieldVals.
%
% The optional booleanStrings array allows control of the boolean operation used
% in the filter, the filterFieldVals value is numeric.
% You can use any Matlab boolean, passed as a string (e.g. '==', '>=',
% '~=', etc.).  This is ignored when flterFieldVals is a string.
%
% 4/19/16  dhb  Wrote it.

%% Deal with optional arguments.
if (nargin < 3)
    filterFieldVals = [];
    booleanThanStrings = {};
end
if (nargin < 4)
    booleanThanStrings = {};
end

%% Get some basic info
nParams = length(theStructArray);

%% Get filtering index
%
if (nargin < 2 | isempty(filterFieldNames) | isempty(filterFieldVals))
    % No filtering
    index = 1:nParams;

elseif isnumeric(filterFieldNames)     
% If "filterFieldNames" is numeric, then treat it as the actual filtering
% index.  In this case, there had better not be a filterFieldVals passed.
    if (nargin > 2)
        error('Cannot pass index and filterFieldVals');
    end
    index = filterFieldNames;

    %
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
        if (~isempty(booleanStrings))
            booleanOperator = booleanStrings{ii};
        else
            booleanOperator = '==';
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
    
end