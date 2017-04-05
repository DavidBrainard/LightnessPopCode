function [condStr,sizeLocStr] = MakePopDecodeConditionStr(decodeInfo)
% [condStr,sizeLocStr] = MakePopDecodeConditionStr(decodeInfo)
%
% Make a string which describes the specified decoding condition.
% Can also make a size/location string.
%
% 5/12/14  dhb  Put this in one place, to try to enforce consistency

% Condition string
switch (decodeInfo.pcaType)
    case {'no', 'ml', 'sdn'}
        pcaKeepStr = [];
    otherwise
        error('Unknown pca type specified');
end

switch (decodeInfo.classifyType)
    case {'mvma' 'mvmb' 'mvmh' }
        classifyStr = [decodeInfo.classifyType decodeInfo.MVM_ALG];
    otherwise
        classifyStr = decodeInfo.classifyType;
end

condStr = [decodeInfo.type '_' 'cls-' classifyStr '_' 'pca-' decodeInfo.pcaType pcaKeepStr '_' ...
    decodeInfo.trialShuffleType '_' decodeInfo.paintShadowShuffleType '_' decodeInfo.excludeSYelectrodes '_' 'ft-' decodeInfo.paintShadowFitType ...
    '_' num2str(decodeInfo.shadowCondition) '_' num2str(decodeInfo.paintCondition)];

% Size location string if possible
if (isfield(decodeInfo,'theCheckerboardSizePixels'))
    sizeLocStr = [num2str(decodeInfo.theCheckerboardSizePixels) 'px_' num2str(decodeInfo.theCenterXPixels) 'cx_' num2str(decodeInfo.theCenterYPixels) 'cy_' decodeInfo.flip];
else
    sizeLocStr = '';
end
