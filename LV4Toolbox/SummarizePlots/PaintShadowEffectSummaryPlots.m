function PaintShadowEffectSummaryPlots(paintShadowEffect,figParams)
% PaintShadowEffectSummaryPlots(paintShadowEffect,figParams)
%
% Summary plots of the basic paint/shadow effect.
%
% 4/19/16  dhb  Wrote it.

%% PLOT: Paint/shadow effect from decoding on both paint and shadow
[paintShadowEffectDecodeBoth] = SubstructArrayFromStructArray(paintShadowEffect,'decodeBoth');

% Open figure
figPaintShadowEffectDecodeBothFig = figure; clf; hold on
set(gcf,'Position',figParams.sqPosition);
set(gca,'FontName',figParams.fontName,'FontSize',figParams.axisFontSize,'LineWidth',figParams.axisLineWidth);

% V4 data for JD
whichSubject = 'JD';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.titleInfoStr = 'V4';
filter.plotSymbol = 'o';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',figParams.markerSize);

% V4 data for SY
whichSubject = 'SY';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.plotSymbol = 's';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',figParams.markerSize);

% V1 data for BR
whichSubject = 'BR';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.plotSymbol = 's';
filter.plotColor = 'k';
filter.outlineColor = 'k';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',figParams.markerSize);

% V1 data for ST
whichSubject = 'ST';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.plotSymbol = '^';
filter.plotColor = 'k';
filter.outlineColor = 'k';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',figParams.markerSize);

% Labels etc
xlabel('Decoding RMSE','FontSize',figParams.labelFontSize);
ylabel('RMSE versus NUnits Fit Scale','FontSize',figParams.labelFontSize);
drawnow;

% Write the figure
figName = fullfile(summaryDir,'RmseVsNUnitsFitScaleAnalysis');
FigureSave(figName,figRMSEVsNUnitsFitScaleFig,figParams.figType);
