% a few notes about getting the RF center fitting to work.

fname = 'ST140429map0009';

%for indexing:
V1Chans = [ 1:96];

%this function is in the fitRFcenters folder
rfData = analyzeRFsDoug(fname);  

%grab the x and y values of where the fit is centered
FitCenters = rfData.FitCenter(V1Chans,:);

% there are a few options for discarding bad fits:
% my suggestion is to use a combination of whether the fit center falls in
% the tested range and that the channel was also siginificantly active when
% a stimulus came on (this was built into previous channel selection)

% rfData.xs and rfData.ys  list the x and y stimulus positions that were
% used

% for example, we could do something really simple minded and discard centers 
% that are outside of this range:
FitCenters(FitCenters(:,1)<min(rfData.xs)-5,:) = NaN;
FitCenters(FitCenters(:,1)>max(rfData.xs)+5,:) = NaN;
FitCenters(FitCenters(:,2)<min(rfData.ys)-5,:) = NaN;
FitCenters(FitCenters(:,2)>max(rfData.ys)+5,:) = NaN;

