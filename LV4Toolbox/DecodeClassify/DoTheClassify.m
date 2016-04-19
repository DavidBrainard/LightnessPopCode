function decodeInfo = DoTheClassify(decodeInfo,labels,responses)
% decodeInfo = DoTheClassify(decodeInfo,labels,responses)
%
% Build the paint/shadow classifier and return appropriate info about it.
%
% The classifier 'object' is returned in decodeInfo.classifyInfo.  It could
% be we should just return that, but I'm not going to change it right now.
%
% 4/21/14  dhb  Wrote it.
% 12/2/15  dhb  Update calling form for Matlab

% Get/check dimensions
[nIntensities,nResponses] = size(responses);
if (length(labels) ~= nIntensities)
    error('nIntensities mismatch');
end

% Build the decoder according to passed type
switch decodeInfo.classifyType
    % Matlab's SVM
    case {'mvma' 'mvmb' 'mvmh' }
        %decodeInfo.classifyInfo = svmtrain(responses,labels,'kernel_function','linear', 'method','QP');
        decodeInfo.classifyInfo = fitcsvm(responses,labels,'KernelFunction','linear','Solver',decodeInfo.MVM_ALG);
        
        % It's not clear which Matlab algorithm works best and is fasted.
        % In a quick look, they all get the same answer and which is faster
        % varies with the problem.  The code below let's you check.
        if (decodeInfo.MVM_COMPARECLASS)
            tstart = tic;
            decodeInfo.classifyInfo1 = fitcsvm(responses,labels,'KernelFunction','linear','Solver','SMO');
            decodeInfo.classifyTelapse1 = toc(tstart);
            tstart = tic;
            decodeInfo.classifyInfo2 = fitcsvm(responses,labels,'KernelFunction','linear','Solver','L1QP');
            decodeInfo.classifyTelapse2 = toc(tstart);
            tstart = tic;
            decodeInfo.classifyInfo3 = fitcsvm(responses,labels,'KernelFunction','linear','Solver','ISDA');
            decodeInfo.classifyTelapse3 = toc(tstart);
            
            decodeInfo.classifyPrediction1 = predict(decodeInfo.classifyInfo1,responses);
            decodeInfo.classifyPerf1 = length(find(decodeInfo.classifyPrediction1 == labels))/length(labels);
            decodeInfo.classifyPrediction2 = predict(decodeInfo.classifyInfo2,responses);
            decodeInfo.classifyPerf2 = length(find(decodeInfo.classifyPrediction1 == labels))/length(labels);
            decodeInfo.classifyPrediction3 = predict(decodeInfo.classifyInfo3,responses);
            decodeInfo.classifyPerf3 = length(find(decodeInfo.classifyPrediction1 == labels))/length(labels);
            fprintf('\t\tSMO (default), %0.1f, %0.2f; L1QP, %0.1f, %0.2f; ISDA,%0.1f, %0.2f\n', ...
                decodeInfo.classifyTelapse1,decodeInfo.classifyPerf1,decodeInfo.classifyTelapse2,decodeInfo.classifyPerf2,decodeInfo.classifyTelapse3,decodeInfo.classifyPerf3);
        end
    
    % Nearest neighbor
    case {'nna' 'nnb' 'nnh'}
        decodeInfo.classifyInfo.responses = responses;
        decodeInfo.classifyInfo.labels = labels;
        
    otherwise
        error('Unknown type specified');
end

end









