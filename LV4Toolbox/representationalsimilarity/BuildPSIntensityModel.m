function model = BuildPSIntensityModel(uniqueIntensities,theShadowIntensityShift,exponent)
% model = BuildPSIntensityModel(uniqueIntensities,theShadowIntensityShift,exponent)
% 
% Build a model of a dissimilarity matrix expected if all that matters is
% intensity.  Coding convention is paint then shadow along the
% rows/columns.
%
% 3/28/16   dhb, dar   Wrote it.

% Allocate
nIntensities = length(uniqueIntensities);
model = zeros(2*nIntensities,2*nIntensities);

% Apply exponent to intensiteis
uniqueIntensities = uniqueIntensities.^exponent;

% Build paint/paint quandrant
for ii = 1:nIntensities
    thePaintIntensity1 = uniqueIntensities(ii);
    for jj = 1:nIntensities
        thePaintIntensity2 = uniqueIntensities(jj);
        model(ii,jj) = abs(thePaintIntensity1-thePaintIntensity2);
    end    
end

% Built upper right paint/shadow quandrant
for ii = 1:nIntensities
    thePaintIntensity1 = uniqueIntensities(ii);
    for jj = 1:nIntensities
        theShadowIntensity2 = uniqueIntensities(jj)+theShadowIntensityShift;
        model(ii,jj+nIntensities) = abs(thePaintIntensity1-theShadowIntensity2);
    end    
end

% Built lower left paint/shadow quandrant
for ii = 1:nIntensities
    theShadowIntensity1 = uniqueIntensities(ii)+theShadowIntensityShift;
    for jj = 1:nIntensities
        thePaintIntensity2 = uniqueIntensities(jj);
        model(ii+nIntensities,jj) = abs(theShadowIntensity1-thePaintIntensity2);
    end    
end

% Built shadow/shadow quandrant
for ii = 1:nIntensities
    theShadowIntensity1 = uniqueIntensities(ii)+theShadowIntensityShift;
    for jj = 1:nIntensities
        theShadowIntensity2 = uniqueIntensities(jj)+theShadowIntensityShift;
        model(ii+nIntensities,jj+nIntensities) = abs(theShadowIntensity1-theShadowIntensity2);
    end    
end