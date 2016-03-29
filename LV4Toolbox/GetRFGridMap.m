function rfGridMapStruct = GetRFGridMap(channelIndex,rfData)
% rfMapStruct = GetRFGridMap(channelIndex,rfData)
%
% Get the spatial receptive field from a unit, given the
% rf data structure as Doug/Marlene provide the .mat file,
% together with the unit number to analyze. 
%
% 4/20/14  dhb  Wrote this from example code provided by Doug.

% Get the RF map plots for each unit
% i'm calling them 'grids'
xPositions=unique(rfData.StimX);
nX=length(xPositions);
yPositions=unique(rfData.StimY);
nY=length(yPositions);
channelIndex = channelIndex;

thesecounts = rfData.stimcounts(channelIndex,:);
thisgrid=nans(nY,nX);
locationcounts = {};
for ix=1:nX;
    thisx=xPositions(ix);
    for iy=1:nY
        thisy=yPositions(iy);
        
        % Get trial-by-trial spike counts for each location
        index = find(rfData.StimX==thisx & rfData.StimY==thisy);
        if (length(index) == 0)
            error('No data for what should be a good location');
        end
        locationcounts{iy,ix} = thesecounts(index);
        
        % Count to average firing rate in spikes/sec.  
        %
        % [I think that stimlength is in frames, and frame rate in
        % frames/sec, so that the math makes sense.]
        thisgrid(iy,ix)=nanmean(locationcounts{iy,ix})*rfData.framerate/rfData.stimlength; 
    end
end

% Tuck away both raw and normalized version, along with
% other interesting information.
rfGridMapStruct.xPositions = xPositions;
rfGridMapStruct.yPositions = yPositions;
rfGridMapStruct.stimX = rfData.StimX;
rfGridMapStruct.stimY = rfData.StimY;
rfGridMapStruct.locationcounts = locationcounts;
rfGridMapStruct.nX = nX;
rfGridMapStruct.nY = nY;
rfGridMapStruct.thisgrid=thisgrid;
rfGridMapStruct.normgrid=thisgrid/(max(thisgrid(:)));
