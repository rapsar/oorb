function out = fastwaitbar(fraction, text)
% FASTWAITBAR Displays a text-based progress bar in the console.
%
% Syntax:
%   out = fastwaitbar(fraction)
%   out = fastwaitbar(fraction, text)
%
% Inputs:
%   fraction - Scalar (0 to 1) indicating progress percentage.
%   text     - (Optional) Custom text to display with the progress bar.
%
% Output:
%   out      - Number of bytes printed. Useful for erasing the line.

persistent nb prevFraction; % Tracks the last printed line's length and progress
if isempty(nb)
    nb = 0;
end
if isempty(prevFraction)
    prevFraction = -1; % Initialize to a value that ensures detection of new progress sequence
end

% Reset automatically if progress is starting from 0
if fraction < prevFraction
    nb = 0; % Reset character count
end

if nargin < 2
    text = '';
else
    text = [strtrim(text), ' ']; % Ensure clean formatting
end

% Clear the previous line
fprintf(repmat('\b', 1, nb));

% Construct the new progress bar
progressStr = sprintf('%s%.2f%%', text, 100 * fraction);

% Print the new progress bar
nb = fprintf('%s', progressStr);

% Update persistent variables
prevFraction = fraction;

% Handle completion case
if fraction >= 1
    fprintf('\n'); % Newline on completion
    nb = 0;        % Reset for next progress bar
    prevFraction = -1; % Reset progress tracking
end

% Output the number of bytes printed
out = nb;
end
