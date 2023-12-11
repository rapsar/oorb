function out = fastwaitbar(fraction, text)
%   Modified by RS, based on progress.m from Matlab FEX
%   Goal is to be much faster than Matlab's waitbar.
%   Use in a loop just like waitbar:
%       insert: rswaitbar reset at beginning of function
%       insert: w = rswaitbar(f) in the loop (don't drop "w = ")
%       do not "close(w)" at the end
%
% Writes a text progress bar to the console
%
% Syntax: nb = progress(fraction, text)
%
% Input:
%  - fraction: number between 0 and 1 (where 1 means the process has ended)
%  - text (optional): label to display beside the progress bar
%
% Output:
%  - out: number of bytes printed, can be used to delete the progress bar
%         with fprintf(repmat('\b', 1, out));
% 
% Usage:
%  - in a for loop, write progress(j/maxiter, 'text') to display a progress
%  bar:
%  >> j = 2; maxiter = 10; progress(j/maxiter);
%  [====                ] 20.0%
%
%  - subsequent calls to the progress bar will delete the last `out' bytes,
%    if something else has been printed to stdout this will delete that and
%    not the progress bar
%  - avoid this by typing `progress reset'

global nb
if ischar(fraction) || isstring(fraction)
	if strcmp(fraction, 'reset')
		nb = 0;
		return;
	else
		error('Input 1 must either be a scalar or the string "reset"');
	end
end
if isempty(nb)
	nb = 0;
end
if ~exist('text', 'var')
	text = '';
elseif ~isempty(text)
	text = [strtrim(char(text)), ' '];
end

fprintf(repmat('\b', 1, nb));
nb = fprintf('%s %.2f%%', text, 100*fraction);
out = nb;
if fraction == 1
	fprintf('\n');
	nb = 0;	
end
end

