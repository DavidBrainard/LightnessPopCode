function [dissimMatrixFit,tau,shadowIntensityShift,intensityExponent,additiveParams] = FitPSDissimMatrix(uniqueIntensities,dissimMatrix,DOSHIFT,DOEXPONENT)
% [dissimMatrixFit,tau,shadowIntensityShift,intensityExponent,additiveParams] = FitPSDissimMatrix(uniqueIntensities,dissimMatrix,DOSHIFT,DOEXPONENT)
%
% Find weighted sum of model matrices that maximizes Kendall's tau between
% a dissimilarity matrix and its prediction.
%
% This search is pretty subject to local minima, so we try a lot of
% starting points and track the best result.
%
% 3/28/16  dhb, dar  Wrote it.
% 4/5/16   dhb       Options to not fit shift or exponent.

% Optional arguments
if (nargin < 3 | isempty(DOSHIFT))
    DOSHIFT = true;
end

if (nargin < 4 | isempty(DOEXPONENT))
    DOEXPONENT = true;
end

% Parameter ranges
shiftRange = 0.2;
exponentLow = 0.1;
exponentHigh = 2;

% Number of starting points
nIntensityShiftStarts = 10;
nIntensityExponentStarts = 10;

% Search function options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');

% Put measured dissimilarity matrix in the right form
dissimTriang = squareform(dissimMatrix)';

% Set up p/s model matrix.  This never changes.
psPaintShadowDissimModel = BuildPSPaintShadowModel(uniqueIntensities);

% Initialize shadow shift and exponent to null hypothesis values, build model, and get it into standard regression form.
shadowIntensityShift0 = 0;
intensityExponent0 = 1;
modelTriang0 = ConstructModelMatrix(psPaintShadowDissimModel,uniqueIntensities,shadowIntensityShift0,intensityExponent0);

% Initialize additive parameters using linear regression, and use these to
% get good bounds on parameters for search
additiveParams0 = modelTriang0\dissimTriang;
parameterRange = max(abs(additiveParams0));
vlb = [-shiftRange ; exponentLow ; -100*parameterRange*ones(size(additiveParams0,1),1)];
vub = [shiftRange ; exponentHigh ; 100*parameterRange*ones(size(additiveParams0,1),1)];

% We'll search using a variety of starting points, and take the best result
startingIntensityShifts = linspace(-shiftRange,shiftRange,nIntensityShiftStarts);
intenstiyExponentStarts = linspace(exponentLow,exponentHigh,nIntensityExponentStarts);
bestF = Inf;
for ss = 1:nIntensityShiftStarts
    shadowIntensityShift0 = startingIntensityShifts(ss);
    for ee = 1:nIntensityExponentStarts
        % Build up initial parameter vector, as above when we found bounds
        intensityExponent0 = intenstiyExponentStarts(ee);
        modelTriang0 = ConstructModelMatrix(psPaintShadowDissimModel,uniqueIntensities,shadowIntensityShift0,intensityExponent0);
        additiveParams0 = modelTriang0\dissimTriang;
        params0 = [shadowIntensityShift0 ; intensityExponent0 ; additiveParams0];
        
        % Set fmincon loose, just on the additive parameters
        vlbUse = [params0(1) ; params0(2); vlb(3:end)];
        vubUse =  [params0(1) ; params0(2); vub(3:end)];
        paramsTemp0 = fmincon(@(params)FitDissimMatrixErrorFun(params,dissimTriang,psPaintShadowDissimModel,uniqueIntensities),...
            params0,[],[],[],[],vlbUse,vubUse,[],options);
        
        % Set fmincon loose, now just on the shift
        vlbUse = [vlb(1) ; paramsTemp0(2); paramsTemp0(3:end)];
        vubUse =  [vub(1) ; paramsTemp0(2); paramsTemp0(3:end)];
        paramsTemp1 = fmincon(@(params)FitDissimMatrixErrorFun(params,dissimTriang,psPaintShadowDissimModel,uniqueIntensities),...
            paramsTemp0,[],[],[],[],vlbUse,vubUse,[],options);
        
        % Set fmincon loose, now just on the exponent
        vlbUse = [paramsTemp1(1) ; vlb(2); paramsTemp1(3:end)];
        vubUse =  [paramsTemp1(1) ; vub(2); paramsTemp1(3:end)];
        paramsTemp2 = fmincon(@(params)FitDissimMatrixErrorFun(params,dissimTriang,psPaintShadowDissimModel,uniqueIntensities),...
            paramsTemp1,[],[],[],[],vlbUse,vubUse,[],options);
        
        % Set fmincon loose, with everything free
        vlbUse = vlb;
        vubUse = vub;
        paramsTemp3 = fmincon(@(params)FitDissimMatrixErrorFun(params,dissimTriang,psPaintShadowDissimModel,uniqueIntensities),...
            paramsTemp2,[],[],[],[],vlbUse,vubUse,[],options);
        
        % If we are constraining, then use these as a starting point for
        % one more constrained search.  Because the code is cleaner, we
        % do one more search even if we aren't constraining further, as it
        % should go very quickly in that case and not hurt anything.
        vlbUse = vlb;
        vubUse = vub;
        if (~DOSHIFT)
            paramsTemp3(1) = 0;
            vlbUse(1) = 0;
            vubUse(1) = 0;
        end
        if (~DOEXPONENT)
            paramsTemp3(2) = 1;
            vlbUse(2) = 1;
            vubUse(2) = 1;
        end
        paramsTemp = fmincon(@(params)FitDissimMatrixErrorFun(params,dissimTriang,psPaintShadowDissimModel,uniqueIntensities),...
            paramsTemp3,[],[],[],[],vlbUse,vubUse,[],options);
        
        % Track best fit and keep
        [fTemp,tauTmp,predTriangTmp,modelTriangTmp] = FitDissimMatrixErrorFun(paramsTemp,dissimTriang,psPaintShadowDissimModel,uniqueIntensities);
        if (fTemp < bestF)
            bestF = fTemp;
            params = paramsTemp;
            tau = tauTmp;
            predTriang = predTriangTmp;
            modelTriang = modelTriangTmp;
        end
    end
end

% Put things in form we want to return
dissimMatrixFit = squareform(predTriang);
shadowIntensityShift = params(1);
intensityExponent = params(2);
additiveParams = params(3:end);

end

% Function to evaluate the current fit
function [f,tau,predTriang,modelTriang] = FitDissimMatrixErrorFun(params,dissimTriang,psPaintShadowDissimModel,uniqueIntensities)

% Check for crazy parameters
if (any(isnan(params)))
    f = 0;
    tau = NaN;
    predTriang = NaN;
    modelTriang = NaN;
    return;
end
    
% Extract parameters
shadowIntensityShift = params(1);
intensityExponent = params(2);
additiveParams = params(3:end);

% Build model in triangular form
modelTriang = ConstructModelMatrix(psPaintShadowDissimModel,uniqueIntensities,shadowIntensityShift,intensityExponent);

% Compute model
predTriang = modelTriang*additiveParams;
predTriang(predTriang < 0) = eps;

% Evaulate
tau = corr(dissimTriang,predTriang,'type','Kendall');
f = -10*tau;

end

% Model matrix in the form we need it in
function modelTriang = ConstructModelMatrix(psPaintShadowDissimModel,uniqueIntensities,shadowIntensityShift,intensityExponent)

% Build the intensity model matrix, including shadow intensity shift
% and exponential compression
psIntensityDissimModel = BuildPSIntensityModel(uniqueIntensities,shadowIntensityShift,intensityExponent);

% Convert to form used in regression
modelMatrices{1} = psPaintShadowDissimModel;
modelMatrices{2} = psIntensityDissimModel;
modelMatrices{3} = ones(size(modelMatrices{1})) - eye(size(modelMatrices{1}));
for ii = 1:length(modelMatrices)
    modelTriang(:,ii) = squareform(modelMatrices{ii})';
end
end


