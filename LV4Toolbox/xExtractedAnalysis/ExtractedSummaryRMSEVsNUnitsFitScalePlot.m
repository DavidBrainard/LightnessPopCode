function ExtractedSummaryRMSEVsNUnitsFitScalePlot(summaryDir,decodeInfoIn,decodeInfoOut)
% ExtractedSummaryRMSEVsNUnitsFitScalePlot(summaryDir,decodeInfoIn,decodeInfoOut)
%
% Make a plot by subject/area of the scale factor describing improvement
% with number of units in the decoder versus the RMSE of full decoder.
%
% 4/4/16  dhb  Wrote it.

% Open figure
figRMSEVsNUnitsFitScaleFig = figure; clf; hold on
set(gcf,'Position',decodeInfoIn.sqPosition);
set(gca,'FontName',decodeInfoIn.fontName,'FontSize',decodeInfoIn.axisFontSize,'LineWidth',decodeInfoIn.axisLineWidth);

% V4 data for JD
whichSubject = 'JD';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.titleInfoStr = 'V4';
filter.plotSymbol = 'o';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',decodeInfoIn.markerSize);

% V4 data for SY
whichSubject = 'SY';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.plotSymbol = 's';
filter.plotColor = 'r';
filter.outlineColor = 'r';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',decodeInfoIn.markerSize);

% V1 data for BR
whichSubject = 'BR';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.plotSymbol = 's';
filter.plotColor = 'k';
filter.outlineColor = 'k';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',decodeInfoIn.markerSize);

% V1 data for ST
whichSubject = 'ST';
rmse = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmse',{'subjectStr'},{whichSubject});
rmseVersusNUnitsFitScale = FilterAndGetFieldFromStructArray([decodeInfoOut{:}],'rmseVersusNUnitsFitScale',{'subjectStr'},{whichSubject});
filter.plotSymbol = '^';
filter.plotColor = 'k';
filter.outlineColor = 'k';
filter.bumpSizeForMean = 6;
plot(rmse,rmseVersusNUnitsFitScale,[filter.plotSymbol filter.outlineColor],'MarkerFaceColor',filter.plotColor','MarkerSize',decodeInfoIn.markerSize);

% Labels etc
xlabel('Decoding RMSE','FontSize',decodeInfoIn.labelFontSize);
ylabel('RMSE versus NUnits Fit Scale','FontSize',decodeInfoIn.labelFontSize);
drawnow;

% Write the figure
figName = fullfile(summaryDir,'RmseVsNUnitsFitScaleAnalysis');
FigureSave(figName,figRMSEVsNUnitsFitScaleFig,decodeInfoIn.figType);
