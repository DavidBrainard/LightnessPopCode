% MakeAllTexFigures
%
% Run LaTex over the figure directories and compile all the figures.
%
% 4/6/14  dhb  Wrote it.
% 6/11/14 dhb  Added psychophysics figures

%% Clear
clear; close all;

%% What to do
SHUFFLE = false;
PSYCHO = true;
DECODING = true;

%% Set up tex command
if (~isempty(GetTexPath))
    theCommand = [GetTexPath 'pdflatex'];
else
    error('LaTex is not installed in a place we can find it.');
end

%% Shuffle figures
if (SHUFFLE)
    cd xShuffleFigures
    theTexFiles = dir('*.tex');
    if (~isempty(dir))
        for i = 1:length(theTexFiles)
            theTexFile = theTexFiles(i).name;
            [s, m] = unix([theCommand ' ' theTexFile]);
            if (s ~= 0)
                fprintf('%s',m);
                error('LaTex failed');
            else
                fprintf('LaTex''d %s\n',theTexFile);
            end
        end

        unix('rm -rf *.log *.aux');
    end
    cd ..
end

%% Psychophysics figures
if (PSYCHO)
    cd xPsychoFigures
    theTexFiles = dir('*.tex');
    if (~isempty(dir))
        for i = 1:length(theTexFiles)
            theTexFile = theTexFiles(i).name;
            [s, m] = unix([theCommand ' ' theTexFile]);
            if (s ~= 0)
                fprintf('%s',m);
                error('LaTex failed');
            else
                fprintf('LaTex''d %s\n',theTexFile);
            end
        end
        
        unix('rm -rf *.log *.aux');
    end
    cd ..
end

%% Decoding figures
if (DECODING)
    cd xDecodingFigures
    theTexFiles = dir('*.tex');
    if (~isempty(dir))
        for i = 1:length(theTexFiles)
            theTexFile = theTexFiles(i).name;
            [s, m] = unix([theCommand ' ' theTexFile]);
            if (s ~= 0)
                fprintf('%s',m);
                error('LaTex failed');
            else
                fprintf('LaTex''d %s\n',theTexFile);
            end
        end
        
        unix('rm -rf *.log *.aux');
    end
    cd ..
end