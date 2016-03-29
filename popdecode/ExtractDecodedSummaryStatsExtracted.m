function [rmse, rmseVersusNUnitsFitScale, performanceVersusNUnitsFitScale] = ...
    ExtractDecodedSummaryStatsExtracted(decodeInfo)
% [rmse, rmseVersusNUnitsFitScale] = ...
%   ExtractDecodedSummaryStatsExtracted(decodeInfo)
%
% Extract vectors of useful summary statistics from a cell array of info structs.
%
% 3/10/16  dhb  "Extracted" version.

nFiltered = length(decodeInfo);
if (nFiltered == 0)
    rmse = [];
    rmseVersusNUnitsFitScale = [];
else
    for f = 1:length(decodeInfo)
        rmse(f) = decodeInfo{f}.rmse;
        rmseVersusNUnitsFitScale(f) = decodeInfo{f}.rmseVersusNUnitsFitScale;
        performanceVersusNUnitsFitScale(f) = decodeInfo{f}.performanceVersusNUnitsFitScale;
    end
end
