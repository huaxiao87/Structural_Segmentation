%PRPROGRESS Report progress of some PRTools iterative routines
%
%  PRPROGRESS ON
%
% All progress of all routines will be written to the command window.
%
%  PRPROGRESS(FID)
%
% Progress reports will be written to the file with file descriptor FID.
%
%  PRPROGRESS OFF
%  PRPROGRESS(0)
%
% Progress reporting is turned off.
%
%  PRPROGRESS
%
% Toggles between PRPROGRESS ON and PRPROGRESS OFF
%
%  PRPROGRESS(FID,FORMAT,...)
%
% Writes progress message to FID. If FID == [], the predefined destination
% (command window or file) is used.
%
% Some routines (e.g. CLEVAL)  have a switch in the function call by which
% progress reporting for that routine only can be initiated.

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

function prprogress(par,varargin)

	global PRPROGRESS

	if isempty(PRPROGRESS)
		PRPROGRESS = 0;
	end

	if nargin == 0

		if PRPROGRESS ~= 0, 
			PRPROGRESS = 0;
		else
			PRPROGRESS = 1; 
		end

	elseif nargin == 1
		
		if isstr(par)
			switch par
			case {'on','ON'}
				PRPROGRESS = 1;
			case {'off','OFF'}
				PRPROGRESS = 0;
			otherwise
				error('Illegal input for PRPROGRESS')
			end
		else
			PRPROGRESS = par;
		end
		
	elseif ~isempty(par)
		
		fprintf(par, varargin{:});
		
	elseif PRPROGRESS > 0
		
		fprintf(PRPROGRESS, varargin{:});
		
	end
	
return
	

