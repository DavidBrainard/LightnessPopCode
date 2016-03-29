% This code package should be able to analyze RF data reduced with
% getreduceddata_All_mapping.

% Note: analyzeRFsDoug ignores the "CorrectCount" parameter. If you want to
% use CorrectCount, uncomment the commented end of line 60 to be like this:
% counts=thesecounts(StimX==thisx&StimY==thisy&CorrectCount==1);
% If you run into errors try adding this or ask me.

% Difference b/w gridNormalizedMean and gridNormalizedMean2
% gridNormalizedMean uses the (x-mean)/SD equation to normalize
% gridNormalizedMean2 uses division of each condition's mean across trials
% by overall mean for all conditions per channel

% -----------------------ADD TO PIPELINE------------------------
% Test this with an example file: 
%   filename = 'pu130319map0001';

% After getreduceddata_All_mapping(filename); add this:
% make and save RF maps for each unit
[data] = analyzeRFsDoug(filename); 

% You may want to use this instead of plotRFs(filename) to fit with your
% current folder hierarchy:
% If you are analyzing on same date you are recording:
path = [datestr(date,'yyyymmdd') '/RF Figures/']; 
% otherwise use path = ['Manual Date Here' '/RF Figures/']; 
plotRFs(data,'savePath',path)

% OPTIONAL
% gridNormalizedMean(filename)
% gridNormalizedMean2(filename)
