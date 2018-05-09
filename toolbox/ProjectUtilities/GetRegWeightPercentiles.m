function regPercents = GetRegWeightPercentiles(regWeights,percentCrits)
% Find regression weight percentiles
%
% Syntax:
%    regPercents = GetRegWeightPercentiles(regWeights,percentCrits)
%
% Description:
%    Find the percentage of regression weights such that the sum of their
%    absolute values is less than each of the passed percentage criterion
%    of the total sum of absolute weight values.
%
%    Might be used an an index of how broadly distributed a set of
%    regression weights is.
%
% Inputs:
%     regWeights      - Vector of regression weights
%     percentCrits    - Vector of percentage criteria.
%
% Outputs:
%     regPercents     - Vector containing the computed percentages of regression weights
%     
% Optional key/value pairs:
%    None.
%
% See also:
%

% History:
%   05/09/18  dhb  Wrote it.

% Examples:
%{
    regWeights = rand(1000,1);
    percentCrits = [25 50 75 100];
    regPercents = GetRegWeightPercentiles(regWeights,percentCrits)
%}

regSorted = sort(abs(regWeights),'descend');
regSum = sum(regSorted);
regPercents = NaN*zeros(length(percentCrits),1);
runningSum = 0;
whichCrit = 1;
nWeights = length(regWeights);
for ii = 1:nWeights
    runningSum = runningSum + regSorted(ii);
    if (runningSum >= regSum*percentCrits(whichCrit)/100)
        regPercents(whichCrit) = round(100*ii/nWeights);
        whichCrit = whichCrit+1;
    end
    if (whichCrit > length(regPercents))
        break;
    end
end