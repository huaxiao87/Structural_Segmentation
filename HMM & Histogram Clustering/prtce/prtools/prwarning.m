%PRWARNING Show PRTools warning
%
%  PRWARNING(LEVEL,FORMAT,...) 
%
% Shows the message (given as FORMAT and a variable number of arguments),
% if the current PRWARNING level is >= LEVEL. Output is written to standard
% error ouput (FID = 2).
%
%  PRWARNING(LEVEL) - Set the current PRWARNING level
%
% Set the PRWARNING level to LEVEL. The default level is 1.
% The levels currently in use are:
%    0  no warnings
%    1  severe warnings (default)
%    2  warnings
%    3  light warnings
%   10  general messages
%   20  program flow messages
%   30  debugging messages
%
% PRWARNING - Reset the PRWARNING level to the default, 1.
% 
% Copyright: D. de Ridder, dick@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: prwarning.m,v 1.7 2003/11/23 22:33:15 bob Exp $

function prwarning (level, varargin)

	global PRWARNING;

	if (isempty (PRWARNING))
		PRWARNING = 0;
	end

	if (nargin == 0)            % Set warning level to default
		PRWARNING = 1;
	elseif (nargin == 1)        % Set warning level
		PRWARNING = level;
	else	
		if (level <= PRWARNING)
			[st,i] = dbstack;   % Find and display calling function (if any)
			if (length(st) > 1)
				caller = st(2).name;
				[paths,name] = fileparts(caller);
				fprintf (2, 'PR_Warning: %s: ', name);
			end;
			fprintf (2, varargin{:});
			fprintf (2, '\n');
		end
	end

	return
