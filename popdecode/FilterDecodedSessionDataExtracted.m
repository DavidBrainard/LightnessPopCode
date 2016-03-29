function [decodeInfoFilter,summaryStructs] = FilterDecodedSessionDataExtracted(sessionInfoStructs,filter)
% [decodeInfoFilter,summaryStructs] = FilterDecodedSessionDataExtracted(sessionInfoStructs,filter)
%
% This version works with the "Extracted" analysis flow.
%
% Take an array of sessionInfoStructs and filter criteria, and resturn a struct array filtered by
% the criteria.  A second struct array returns the key summary information we care about for all
% of the input.
%
% sessionInfoStructs = cell array of cell arrays of info structs, one for each session/condition
% filter - struct with filter critera
%
% decodeInfoFiltered = cell array of info structs, one for each condition that survives filtering.
% summaryStructs - struct array of summary information one for each condition whether it was filtered out or not
%
% 3/10/16  dhb  Extracted version.

nFiles = length(sessionInfoStructs);
filteredOut = 1;
for f = 1:nFiles
    % Start structure of interesting stuff for text summary file
    clear outputSummaryStructTemp
    
    % Decide whether to include in summary analysis
    if (strcmp(filter.subjectStr,sessionInfoStructs{f}.subjectStr))
        if (isfield(sessionInfoStructs{f},'rmse') & sessionInfoStructs{f}.rmse < filter.rmseLower)
            
            % Stash the output
            decodeInfoFilter{filteredOut} = sessionInfoStructs{f};
            
            % Carry on with stats for text summary text file
            outputSummaryStructTemp.filename = sessionInfoStructs{f}.filename;
            outputSummaryStructTemp.rmse = sessionInfoStructs{f}.rmse;
            outputSummaryStructTemp.rmseVersusNUnitsFitScale = sessionInfoStructs{f}.rmseVersusNUnitsFitScale;
            outputSummaryStructTemp.rmseVersusNUnitsFitAsymp = sessionInfoStructs{f}.rmseVersusNUnitsFitAsymp;
             
            outputSummaryStructTemp.rmse = sessionInfoStructs{f}.performance;
            outputSummaryStructTemp.rmseVersusNUnitsFitScale = sessionInfoStructs{f}.performanceVersusNUnitsFitScale;
            outputSummaryStructTemp.rmseVersusNUnitsFitAsymp = sessionInfoStructs{f}.performanceVersusNUnitsFitAsymp;
            
            % Store
            summaryStructs(filteredOut) = outputSummaryStructTemp;
            
            % Bump counter
            filteredOut = filteredOut + 1;
        end
    end
end

% Handle case where nothing met criterion
if (filteredOut == 1)
    decodeInfoFilter = [];
    summaryStructs = [];
end

end
