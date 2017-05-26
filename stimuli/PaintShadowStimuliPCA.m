% PaintShadowStimuliPCA
%
% Run PCA on the actual stimuli, for illustrative purposes
%
% 5/26/16  dhb  Wrote it.

% Clear and close
clear; close all;

% Where
dataDir = '/Volumes/Users1/Users1Shared/Matlab/Experiments/LightnessV4/stimuli/parametricConditions2/Eimgs_rot0_shad4_blk40_cen40';
curDir = pwd;
cd(dataDir);
theFiles = dir('*.mat');

% Load in the paint stimuli
theShadowData = [];
thePaintData = [];
shadowCounter = 1;
paintCounter = 1;
for i = 1:length(theFiles)
    if (strcmp(theFiles(i).name(1:6),'Shadow'))
        if (strcmp(theFiles(i).name(8:10),'Pro'))
            cd(dataDir);
            theData = load(theFiles(i).name);
            cd(curDir);
            theShadowData = [theShadowData theData.theImage(:)];
            if (theFiles(i).name(15) == '_')
                theShadowLums(shadowCounter) = str2num(theFiles(i).name(13:14));
            elseif (theFiles(i).name(14) == '_');
                theShadowLums(shadowCounter) = str2num(theFiles(i).name(13));
            else
                theShadowLums(shadowCounter) = str2num(theFiles(i).name(13:15));
            end
            shadowCounter = shadowCounter + 1;
        end
    elseif (strcmp(theFiles(i).name(1:5),'Paint'))
        if (strcmp(theFiles(i).name(7:9),'Pro'))
            cd(dataDir);
            theData = load(theFiles(i).name);
            cd(curDir);
            thePaintData = [thePaintData theData.theImage(:)];
            if (theFiles(i).name(14) == '_')
                thePaintLums(paintCounter) = str2num(theFiles(i).name(12:13));
            elseif (theFiles(i).name(13) == '_');
                thePaintLums(paintCounter) = str2num(theFiles(i).name(12));
            else
                thePaintLums(paintCounter) = str2num(theFiles(i).name(12:14));
            end
            paintCounter = paintCounter + 1;
        end
    end
end

% Find just the lums we want
indexS = find(theShadowLums >= 20 & theShadowLums <= 100);
indexP = find(thePaintLums >= 20 & thePaintLums <= 100);

% Run the pca
decodeInfo.pcaType = 'ml';
[paintResponsesPCA,shadowResponsesPCA,pcaBasis,meanResponse] = PaintShadowPCA(decodeInfo,thePaintData(:,indexP)',theShadowData(:,indexS)');

% Plot
figure; clf; hold on;
plot(paintResponsesPCA(:,1),paintResponsesPCA(:,2),'bo','MarkerFaceColor','b','MarkerSize',12);
plot(shadowResponsesPCA(:,1),shadowResponsesPCA(:,2),'ro','MarkerFaceColor','r','MarkerSize',12);





