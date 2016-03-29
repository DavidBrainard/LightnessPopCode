function [xs,ys,AllGrids] =  SiftRFData(filename);

thisname=[filename '_reduceddata.mat'];
eval(['load ' thisname])


xs=unique(StimX);
numx=length(xs);
ys=unique(StimY);
numy=length(ys);

for ic=1:numchannels
    c=channels(ic,1);
    u=channels(ic,2);
    thesecounts=stimcounts(ic,:);
    thisgrid=nans(numy,numx);
    for ix=1:numx;
        thisx=xs(ix);
        for iy=1:numy
            thisy=ys(iy);
            counts=thesecounts(StimX==thisx&StimY==thisy);   
            thisgrid(iy,ix)=nanmean(counts)*framerate/stimlength; % to get firing rate rather than spike count
            AllGrids{ic}.thisgrid=thisgrid;
            AllGrids{ic}.normgrid=thisgrid/(max(thisgrid(:)));
        end
    end

end
end