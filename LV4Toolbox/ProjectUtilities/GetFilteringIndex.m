function index = GetFilteringIndex(theStructArray,filterFieldNames,filterFieldVals,booleanThanStrings)
% index = GetFilteringIndex(theStructArray,filterFieldNames,filterFieldVals,booleanStrings)
%
% Get the index of the subarray of the struct that we want, depending on
% the passed filtering values.
%
% If only the struct array is passed, the index is the whole array.
%
% You can just pass an index for filterFieldNames, in which case there
% should not be a filterFieldVals and the same index is returned.
%
% Otherwise the fields listed in filterFieldNames are compared to the
% values in filterFieldVals and index returns those entries of the struct
% that match all of the criteria.
%
% The optional booleanStrings array allows control of the boolean operation used
% in the comparisonsf, when the filterFieldVals value is numeric.
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
    
else
    % Fancier filtering
    if (length(filterFieldNames) ~= length(filterFieldVals))
        error('Mismatch in names and values for filtering');
    end
    
    % Set up selection boolean for each entry of the struct array
    boolean0 = ones(size(1:nParams));
    
    % Check each entry of boolean against each criterion
    for ii = 1:length(filterFieldNames)
        filterFieldName = filterFieldNames{ii};
        if (~isstr(filterFieldName))
            error('Filter names must be strings');
        end
        
        % Get the boolean.  This only has an effect if the value is
        % numeric.
        if (~isempty(booleanStrings))
            booleanOperator = booleanStrings{ii};
        else
            booleanOperator = '==';
        end
        
        % Get the filtering value and make a string that evaluates as to
        % whether it holds.
        
        filterFieldVal = filterFieldVals{ii};
        if (isstr(filterFieldVal))
            theFilterEvalStr = ['boolean1 = strcmp({theStructArray(:).' filterFieldName '},''' filterFieldVal ''');'];
        elseif (isnumeric(filterFieldVal))
            theFilterEvalStr = ['boolean1 = ([theStructArray(:).' filterFieldName '] ' booleanOperator ' num2str(filterFieldVal));'];
        else
            error('Can only filter on strings or numbers');
        end
        
        % Check this condition
        eval(theFilterEvalStr);
        booleanTmp = boolean0 & boolean1;
        boolean0 = boolean1;
        boolean1 = booleanTmp;
    end
    
    % Find the index
    index = find(boolean1);
end

end