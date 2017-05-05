function extractedOut = SummarizeGetExtractedStructs(readDataDir,whichStruct)
% extractedOut = SummarizeGetExtractedStructs(theDir,whichStruct)
%
% Read in the data written by one of the extracted analysis functions.
%
% 4/18/16  dhb  Wrote it.

% Read in and return extracted data output
curDir = pwd; cd(readDataDir);
theData = load(whichStruct);
cd(curDir);

% The structure of interest is always stored in variable decodeSave
% by the extracted analysis
extractedOut = theData.decodeSave;
extractedOut.theDataDir = readDataDir;

end



