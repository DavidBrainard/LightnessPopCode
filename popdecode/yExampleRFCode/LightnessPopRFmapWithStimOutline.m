% notes to make a cumulative sum of thresholded RF maps
% this could be thought of as an RF envelope.
% at the end is an example of how to draw the checkerboard stimulus relative to the RF
% map

% run this code after you have made the UsedGrids structure from the
% LightnessWeightedRFmapNotes.m

[m,n]=size(UsedGrids{1}.thisgrid);
AmountToDivide = 4;  % denominator under the difference between max and min response
DiffRangeThresh = 20; %minimum difference between max and min to count the RF
                        % set this to zero to include all cells that were
                        % included in the decoding
                        % N.B. - often times we got visual responses from a
                        % channel during the checkerboard stimuli but still
                        % got noisy/messy RF maps from that channel

        % optionally, we could require that the pixels that survive are
        % contiguous or apply some other corrected statistical criterion. 
        % To do that right (with a statistical criterion) I will need to
        % revisit Gaussian Random Fields Theory, FDR or some of the other
        % cluster based thresholding methods.
        
        % alternatively, we could do some image processing on the
        % thresholded masks.
        % edge detection or smoothing could work.
        

for i = 1:length(UsedGrids)
    Mask = zeros(m,n);
    GreaterThanThresh=[];
    
    DiffRange = (max(UsedGrids{i}.thisgrid(:))-min(UsedGrids{i}.thisgrid(:)));
    if DiffRange > DiffRangeThresh
        halfwayVal = max(UsedGrids{i}.thisgrid(:)) - DiffRange/AmountToDivide;
        GreaterThanThresh = find(UsedGrids{i}.thisgrid>=halfwayVal);
        Mask(GreaterThanThresh) = 1;
        
        AllGrids{i}.ThresholdMask=Mask;
    else
        AllGrids{i}.ThresholdMask=Mask;
    end
end

%add all of the thresholded RF maps together to see how many cells
%responded at each location
ThreshGridSum=zeros(m,n);
for i = 1:length(UsedGrids)
    ThreshGridSum = ThreshGridSum + AllGrids{i}.ThresholdMask;
end

%plot it
figure;
    imagesc(xs,ys,ThreshGridSum)   % imagesc(xs,fliplr(ys),thisgrid)
    set(gca,'Ydir','normal')  % to fix the weird y-axis direction in Matlab
    colormap jet
    colorbar
    title(['Sum of thresholded RF maps'])

%%
% next, we might want to draw our stimulus, or its center location on the
% map
% let's say the stim was centered at (35,-50) and was 150 pixels.
% because of potential confusion when loading up task files and mapping
% files that have variables with the same name, i'm just going to manually
% do this here:
centX = 35;
centY = -50;
stimSize = 150;
text(centX,centY,'X')

stimBottomLeftCornerX = centX-(stimSize/2);
stimBottomLeftCornerY = centY-(stimSize/2);

rectangle('Position',[stimBottomLeftCornerX,stimBottomLeftCornerY,stimSize,stimSize])
xlim([-300 300]); ylim([-300 300]);


