function LightnessPopCodeLocalHook
% LightnessPopCodeLocalHook
%
% Configure things for working on the LightnessPopCode project.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUseProject('LightnessPopCode') to set up for
% this project.  You then edit your local copy to match your configuration.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running LightnessPopCode local hook\n');

%% Specify project name and location
projectName = 'LightnessPopCode';
projectBaseDir = tbLocateProject('LightnessPopCode');
if (ispref(projectName))
    rmpref(projectName);
end

%% Set preferences for project output
%
% This will need to be locally configured.
outputBaseDir = '/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennOutput';
physiologyInputBaseDir = '/Users1/Users1Shared/Matlab/Experiments/LightnessV4/Pitt/Data';
psychoInputBaseDir = '/Users1/Users1Shared/Matlab/Experiments/LightnessV4/PennPsychoData';
stimulusInputBaseDir = '/Users1/Users1Shared/Matlab/Experiments/LightnessV4/stimuli';
stimulusDefInputBaseDir = fullfile(projectBaseDir,'stimuli');

% Set the preferences
setpref('LightnessPopCode','outputBaseDir',outputBaseDir);
setpref('LightnessPopCode','physiologyInputBaseDir',physiologyInputBaseDir);
setpref('LightnessPopCode','psychoInputBaseDir',psychoInputBaseDir);
setpref('LightnessPopCode','stimulusInputBaseDir',stimulusInputBaseDir);
setpref('LightnessPopCode','stimulusDefInputBaseDir',stimulusDefInputBaseDir);

%% Set preferences for where paper figures should end up.
%
% This is used by script figureforpaper/CopyOverFigures to collect up and
% organize the figures parts that end up in the paper.
%
% This is formatted so it can be passed to the linux shell.
setpref('LightnessPopCode','figureDir','/Volumes/Users1/DropboxPersonal/xPapers/xUnderReview/LightnessV4Paper1/DBFigures');
setpref('LightnessPopCode','figureDirCVLasso','/Volumes/Users1/DropboxPersonal/xPapers/xUnderReview/LightnessV4Paper1/DBFiguresCVLasso');
setpref('LightnessPopCode','figureDirCVRidge','/Volumes/Users1/DropboxPersonal/xPapers/xUnderReview/LightnessV4Paper1/DBFiguresCVRidge');

