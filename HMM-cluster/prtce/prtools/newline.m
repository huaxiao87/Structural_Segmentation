%NEWLINE The platform dependent newline character
%
% c = newline

% $Id: newline.m,v 1.4 2003/10/16 16:37:28 bob Exp $

function c = newline
	
	if strcmp(computer,'MAC2')
		c = setstr(13);
	elseif strcmp(computer,'PCWIN')
		c = setstr(10);
	else
		c = setstr(10);
	end
	
return
