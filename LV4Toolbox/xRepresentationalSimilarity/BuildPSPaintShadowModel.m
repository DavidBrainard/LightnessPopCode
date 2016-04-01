function model = BuildPSPaintShadowModel(uniqueIntensities)
% model = BuildPSPaintShadowModel(uniqueIntensities)
% 
% Build a model of a dissimilarity matrix expected if all that matters is
% paint versus shadow.  Coding convention is paint then shadow along the
% rows/columns.
%
% 3/28/16   dhb, dar   Wrote it.

% Allocate and build
nIntensities = length(uniqueIntensities);
model = zeros(2*nIntensities,2*nIntensities);
model((end/2)+1:end,1:end/2) = 1;
model(1:end/2,(end/2)+1:end) = 1;
