function [condStr,sizeLocStr] = MakePopDecodeConditionStr(decodeInfo)
% [condStr,sizeLocStr] = MakePopDecodeConditionStr(decodeInfo)
%
% Make a string which describes the specified decoding condition.
% Can also make a size/location string.
%
% 5/12/14  dhb  Put this in one place, to try to enforce consistency

% Condition string
switch (decodeInfo.pcaType)
    case 'no'
        pcaKeepStr = [];
    case {'sdn'}
        pcaKeepStr = num2str(decodeInfo.pcaKeep);
    otherwise
        error('Unknown pca type specified');
end

switch (decodeInfo.classifyType)
    case {'mvma' 'mvmb' 'mvmh' }
        classifyStr = [decodeInfo.classifyType decodeInfo.MVM_ALG];
    otherwise
        classifyStr = decodeInfo.classifyType;
end

condStr = ['dc-' decodeInfo.type '_' 'cls-' classifyStr '_' 'rf-' decodeInfo.rfAnalysisType '_' 'pca-' decodeInfo.pcaType pcaKeepStr '_' ...
    'use-' decodeInfo.decodeJoint '_' 'off-' num2str(100*decodeInfo.decodeOffset) '_' ...
    decodeInfo.trialShuffleType '_' decodeInfo.paintShadowShuffleType '_' 'lo-' decodeInfo.looType '_' 'clo-' decodeInfo.classifyLOOType '_' decodeInfo.excludeSYelectrodes '_' 'ft-' decodeInfo.paintShadowFitType ...
    '_' num2str(decodeInfo.shadowCondition) '_' num2str(decodeInfo.paintCondition)];

% Size location string if possible
if (isfield(decodeInfo,'theCheckerboardSizePixels'))
    sizeLocStr = [num2str(decodeInfo.theCheckerboardSizePixels) 'px_' num2str(decodeInfo.theCenterXPixels) 'cx_' num2str(decodeInfo.theCenterYPixels) 'cy_' decodeInfo.flip];
else
    sizeLocStr = '';
end
