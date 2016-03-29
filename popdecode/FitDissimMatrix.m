function [dissimMatrixFit,tau,params] = FitDissimMatrix(dissimMatrix,modelMatrices)
% [dissimMatrixFit,tau,params] = FitDissimMatrix(dissimMatrix,modelMatrices)
%
% Find weighted sum of model matrices that maximizes Kendall's tau between
% a dissimilarity matrix and its prediction.
%
% 3/28/16  dhb, dar  Wrote it.

% Put dissimilarity matrix in the right form
dissimTriang = squareform(dissimMatrix)';
nRows = size(dissimTriang,1);

% Put model matrices into stanard regressin form.
nMatrices = length(modelMatrices);
modelTriang = ones(nRows,nMatrices+1);
for ii = 1:nMatrices
    modelTriang(:,ii) = squareform(modelMatrices{ii})';
end

% Initialize parameters using linear regression
params0 = modelTriang\dissimTriang;
vlb = -100*ones(size(params0));
vub = 100*ones(size(params0));
[f0,tau0] = FitDissimMatrixErrorFun(params0,dissimTriang,modelTriang);

options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
params = fmincon(@(params)FitDissimMatrixErrorFun(params,dissimTriang,modelTriang),params0,[],[],[],[],vlb,vub,[],options);
[f,tau,predTriang] = FitDissimMatrixErrorFun(params,dissimTriang,modelTriang);
dissimMatrixFit = squareform(predTriang);

end

function [f,tau,predTriang] = FitDissimMatrixErrorFun(params,dissimTriang,modelTriang)

predTriang = modelTriang*params;
tau = corr(dissimTriang,predTriang,'type','Kendall');
f = -tau;
    
end


