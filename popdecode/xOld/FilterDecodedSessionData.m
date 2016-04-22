function [decodeInfoFilter,summaryStructs] = FilterDecodedSessionData(sessionInfoStructs,filter)
% [decodeInfoFilter,summaryStructs] = FilterDecodedSessionData(sessionInfoStructs,filter)
%
% Take an array of sessionInfoStructs and filter criteria, and resturn a struct array filtered by
% the criteria.  A second struct array returns the key summary information we care about for all
% of the input.
%
% sessionInfoStructs = cell array of cell arrays of info structs, one for each session (first index) /condition (second index)
% filter - struct with filter critera
%
% decodeInfoFiltered = cell array of info structs, one for each condition that survives filtering.
% summaryStructs - struct array of summary information one for each condition whether it was filtered out or not
%
% 3/21/14  dhb  Factorized this on out.

nFiles = length(sessionInfoStructs);
filteredOut = 1;
outputTextSummaryStructIndex = 1;
decodeInfoFilter = [];
for f = 1:nFiles
    for j = 1:length(sessionInfoStructs{f})
        % Start structure of interesting stuff for text summary file
        clear outputSummaryStructTemp
        outputSummaryStructTemp.filename = sessionInfoStructs{f}{j}.filename;
        outputSummaryStructTemp.conditionInFileNumber = j;
        
        % Decide whether to include in summary analysis
        if (strcmp(filter.titleInfoStr,sessionInfoStructs{f}{j}.titleInfoStr) & strcmp(filter.subjectStr,sessionInfoStructs{f}{j}.subjectStr))
            if (sessionInfoStructs{f}{j}.decodePaintRange > filter.rangeLower && ...
                    sessionInfoStructs{f}{j}.decodeShadowRange > filter.rangeLower)
                
                % Stash the output
                decodeInfoFilter{filteredOut} = sessionInfoStructs{f}{j};
                
                % Deal with fact that we don't always have RF info
                if (~isfield(sessionInfoStructs{f}{j},'minRFDistToStimCenter'))
                    decodeInfoFilter{filteredOut}.minRFDistToStimCenter = NaN;
                    decodeInfoFilter{filteredOut}.nSigRFLocations = NaN;
                end
                
                % Report
                fprintf('Using %s %s, size %d, center X %d, center Y %d flip %s (decoded ranges: %0.2f paint, %0.2f shadow, n paint trials %d; n shadow trials %d)\n',filter.titleInfoStr,...
                    sessionInfoStructs{f}{j}.filename,sessionInfoStructs{f}{j}.theCheckerboardSizePixels,sessionInfoStructs{f}{j}.theCenterXPixels,sessionInfoStructs{f}{j}.theCenterYPixels, sessionInfoStructs{f}{j}.flip, ...
                    sessionInfoStructs{f}{j}.decodePaintRange,sessionInfoStructs{f}{j}.decodeShadowRange,...
                    sessionInfoStructs{f}{j}.nPaintTrials,sessionInfoStructs{f}{j}.nShadowTrials);
                filteredOut = filteredOut + 1;
                outputSummaryStructTemp.includedInSummaryAnalysis = 'yes';
                
            else
                fprintf('Rejecting %s %s, size %d, center X %d, center Y %d flip %s (decoded ranges or ntrials too small: %0.2f paint, %0.2f shadow, n paint trials %d, n shadow trials %d)\n',filter.titleInfoStr,...
                    sessionInfoStructs{f}{j}.filename,sessionInfoStructs{f}{j}.theCheckerboardSizePixels,sessionInfoStructs{f}{j}.theCenterXPixels,sessionInfoStructs{f}{j}.theCenterYPixels, sessionInfoStructs{f}{j}.flip, ...
                    sessionInfoStructs{f}{j}.decodePaintRange,sessionInfoStructs{f}{j}.decodeShadowRange,...
                    sessionInfoStructs{f}{j}.nPaintTrials,sessionInfoStructs{f}{j}.nShadowTrials);
                outputSummaryStructTemp.includedInSummaryAnalysis = 'no';
            end
            
            % Carry on with stats for text summary text file
            outputSummaryStructTemp.dataType = sessionInfoStructs{f}{j}.dataType;
            outputSummaryStructTemp.type = sessionInfoStructs{f}{j}.type;
            outputSummaryStructTemp.decodedIntensityFitType = sessionInfoStructs{f}{j}.decodedIntensityFitType;
            outputSummaryStructTemp.paintShadowFitType = sessionInfoStructs{f}{j}.paintShadowFitType;
            outputSummaryStructTemp.decodeLOOType = sessionInfoStructs{f}{j}.decodeLOOType;
            outputSummaryStructTemp.errType = sessionInfoStructs{f}{j}.errType;
            outputSummaryStructTemp.arrayPosition = sessionInfoStructs{f}{j}.titleInfoStr;
            outputSummaryStructTemp.theCheckerboardSizeDegs = sessionInfoStructs{f}{j}.theCheckerboardSizeDegs;
            outputSummaryStructTemp.theCenterXDegs = sessionInfoStructs{f}{j}.theCenterXDegs;
            outputSummaryStructTemp.theCenterYDegs = sessionInfoStructs{f}{j}.theCenterYDegs;
            outputSummaryStructTemp.paintCondition = sessionInfoStructs{f}{j}.paintCondition;
            outputSummaryStructTemp.shadowCondition = sessionInfoStructs{f}{j}.shadowCondition;
            outputSummaryStructTemp.nPaintTrials = sessionInfoStructs{f}{j}.nPaintTrials;
            outputSummaryStructTemp.nShadowTrials = sessionInfoStructs{f}{j}.nShadowTrials;
            outputSummaryStructTemp.decodePaintRange = sessionInfoStructs{f}{j}.decodePaintRange;
            outputSummaryStructTemp.decodeShadowRange = sessionInfoStructs{f}{j}.decodeShadowRange;
            outputSummaryStructTemp.paintLOORMSE = sessionInfoStructs{f}{j}.paintLOORMSE;
            outputSummaryStructTemp.shadowLOORMSE = sessionInfoStructs{f}{j}.shadowLOORMSE;
            outputSummaryStructTemp.decodePaintMean = sessionInfoStructs{f}{j}.decodePaintMean;
            outputSummaryStructTemp.decodeShadowMean = sessionInfoStructs{f}{j}.decodeShadowMean;
            outputSummaryStructTemp.decodeSlope = sessionInfoStructs{f}{j}.decodeSlope;
            outputSummaryStructTemp.decodeIntercept = sessionInfoStructs{f}{j}.decodeIntercept;
            outputSummaryStructTemp.paintShadowDecodeMeanDifferenceDiscrete = sessionInfoStructs{f}{j}.paintShadowDecodeMeanDifferenceDiscrete;
            outputSummaryStructTemp.decodeMatchDifferenceDiscrete = sessionInfoStructs{f}{j}.meanPaintMatchesDiscrete - sessionInfoStructs{f}{j}.meanShadowMatchesDiscrete;
            %outputSummaryStructTemp.weightedIRFSpikeDifference = sessionInfoStructs{f}{j}.weightedIRFSpikeDifference;
            outputSummaryStructTemp.decodeInterceptSmooth = sessionInfoStructs{f}{j}.decodeInterceptSmooth;
            
            % There isn't always RF data, so we handle the case where that
            % field didn't get filled in by the analysis -- set to NaN.
            % Note that this is different from where there is RF data but
            % no significant response locations, in which case the field
            % comes back to us as Inf.
            if (isfield(sessionInfoStructs{f}{j},'minRFDistToStimCenter'))
                outputSummaryStructTemp.minRFDistToStimCenter = sessionInfoStructs{f}{j}.minRFDistToStimCenter;
                outputSummaryStructTemp.nSigRFLocations = sessionInfoStructs{f}{j}.nSigRFLocatons;
            else
                outputSummaryStructTemp.minRFDistToStimCenter = NaN;
                outputSummaryStructTemp.nSigRFLocations = NaN;
            end

            % Carry on.  The angle fields don't get set for some ways that
            % we run the high level stuff (i.e., when decodeJoint is not
            % 'both', so we plop in NaN's to prevent code crash.
            if (isfield(sessionInfoStructs{f}{j},'paintShadowDecodeAngle')),
                outputSummaryStructTemp.paintShadowDecodeAngle = sessionInfoStructs{f}{j}.paintShadowDecodeAngle;
            else
                outputSummaryStructTemp.paintShadowDecodeAngle = NaN;
            end
            if (isfield(sessionInfoStructs{f}{j},'paintShadowPCAAngle'))
                outputSummaryStructTemp.paintShadowPCAAngle = sessionInfoStructs{f}{j}.paintShadowPCAAngle;
            else
                outputSummaryStructTemp.paintShadowPCAAngle = NaN;
            end

            % Store
            summaryStructsTemp(outputTextSummaryStructIndex) = outputSummaryStructTemp;
            outputTextSummaryStructIndex = outputTextSummaryStructIndex + 1;
        end
    end
end

% Get some mean values and stick them in every copy of the output struct
sumDecodeIntercepts = 0;
nOKDecodeIntercepts = 0;
sumDecodeInterceptsSmooth = 0;
nOKDecodeInterceptsSmooth = 0;
sumPaintShadowDecodeMeanDifferenceDiscrete = 0;
nOKPaintShadowDecodeMeanDifferenceDiscrete = 0;
for i = 1:length(summaryStructsTemp)
    if (~isnan(summaryStructsTemp(i).decodeIntercept) && strcmp(summaryStructsTemp(i).includedInSummaryAnalysis,'yes'))
        sumDecodeIntercepts = sumDecodeIntercepts + summaryStructsTemp(i).decodeIntercept;
        nOKDecodeIntercepts = nOKDecodeIntercepts + 1;
    end
    
    if (~isnan(summaryStructsTemp(i).decodeInterceptSmooth) && strcmp(summaryStructsTemp(i).includedInSummaryAnalysis,'yes'))
        sumDecodeInterceptsSmooth = sumDecodeInterceptsSmooth + summaryStructsTemp(i).decodeInterceptSmooth;
        nOKDecodeInterceptsSmooth = nOKDecodeInterceptsSmooth + 1;
    end
    
    if (~isnan(summaryStructsTemp(i).paintShadowDecodeMeanDifferenceDiscrete) && strcmp(summaryStructsTemp(i).includedInSummaryAnalysis,'yes'))
        sumPaintShadowDecodeMeanDifferenceDiscrete = sumPaintShadowDecodeMeanDifferenceDiscrete + summaryStructsTemp(i).paintShadowDecodeMeanDifferenceDiscrete;
        nOKPaintShadowDecodeMeanDifferenceDiscrete = nOKPaintShadowDecodeMeanDifferenceDiscrete + 1;
    end
end
meanDecodeIntercept = sumDecodeIntercepts/nOKDecodeIntercepts;
meanDecodeInterceptSmooth = sumDecodeInterceptsSmooth/nOKDecodeInterceptsSmooth;
meanPaintShadowDecodeMeanDifferenceDiscrete = sumPaintShadowDecodeMeanDifferenceDiscrete/nOKPaintShadowDecodeMeanDifferenceDiscrete;

for i = 1:length(summaryStructsTemp)
    tempStruct = summaryStructsTemp(i);
    tempStruct.meanDecodeIntercept = meanDecodeIntercept;
    tempStruct.meanDecodeInterceptSmooth = meanDecodeInterceptSmooth;
    tempStruct.meanPaintShadowDecodeMeanDifferenceDiscrete = meanPaintShadowDecodeMeanDifferenceDiscrete;
    summaryStructs(i) = tempStruct;
end
