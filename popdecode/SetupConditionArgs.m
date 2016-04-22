function argList = SetupConditionArgs(conditionName)
%
%
% Condtion strings
%   'basic' - The basic defaults we use for decoding
%
% 4/21/16  dhb  Wrote it so we can keep it consistent across callers

switch (conditionName)
    case 'basic'
        argList = { ...
            'dataType','spksrt', ...
            'type','aff', ...
            'classifyType','mvma', ...
            'rfAnalysisType','no', ...
            'pcaType','no', ...
            'trialShuffleType','notshf', ...
            'paintShadowShuffleType','nopsshf', ...
            'decodeIntensityFitType','betacdf', ...
            'paintCondition', 1, ...
            'shadowCondition', 2, ...
            'paintShadowFitType', 'intcpt',  ...
            'excludeSYelectrodes','sykp', ...
            'minTrials',5, ...
            'filterMaxRMSE',0.2, ...
            'doIndElectrodeRFPlots',true, ...
            'reallyDoIRFPlots',false, ...
            'reallyDoRFPlots',false, ...
            'COMPUTE', true, ...
            'plotV4Only', false, ...
            'DATASTYLE', 'new' ...
            };
        
    otherwise
        error('Unknown condition name provided');
end