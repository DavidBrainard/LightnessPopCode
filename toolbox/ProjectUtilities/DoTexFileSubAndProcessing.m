function DoTexFileSubAndProcessing(curDir,figInString,figOutString,figOutName,subjectIdentifier,templateFile,inputDirString,outputDirString,outputDir,figureNumberInString,figureNumberOutStrings)
% DoTexFileSubAndProcessing(curDir,figInString,figOutString,figOutName,subjectIdentifier,templateFile,inputDirString,outputDirString,outputDir,figureNumberInString,figureNumberOutStrings)
%
% Drive LaTex to produce various figures like one defined by a LaTex template.
%
% 7/21/13  dhb  Wrote it, with some reservations about whether this is a good idea.

% Set up tex command
if (~isempty(GetTexPath))
    theCommand = [GetTexPath 'pdflatex'];
else
    error('LaTex is not installed in a place we can find it.');
end

% Get template string to be used
fid = fopen(templateFile,'rt');
if (fid == -1)
    error('Error opening template file');
end
templateString = char(fread(fid))';
fclose(fid);

% String substitute on template and write it out
for f1 = 1:length(figOutString)
    for s1 = 1:length(subjectIdentifier)
        outputString = strrep(templateString,figInString{1},[figOutString{f1} subjectIdentifier{s1}]);
        outputString = strrep(outputString,inputDirString,outputDirString);
        outputString = strrep(outputString,figureNumberInString,figureNumberOutStrings{s1});
        
        outputFile = 'temp.tex';
        fid = fopen(outputFile,'wt');
        if (fid == -1)
            error('Error writing temp .tex file');
        end
        fwrite(fid,outputString);
        fclose(fid);
        
        [s, m] = unix([theCommand ' temp.tex']);
        if (s ~= 0)
            fprintf('%s',m);
            error('LaTex failed');
        end
        
        destFile = fullfile(curDir,outputDir,[figOutName{f1} subjectIdentifier{s1} '.pdf']);
        [s, m] = unix(['mv temp.pdf ' destFile]);
        if (s ~= 0)
            fprintf('%s',m);
            error('File move error');
        end
        [s, m] = unix('rm temp.tex');
        if (s ~= 0)
            fprintf('%s',m);
            error('Temp file removal error');
        end
    end
end