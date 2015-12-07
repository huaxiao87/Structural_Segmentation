%FEATSELB Backward feature selection for classification
% 
%  [W,R] = FEATSELB(A,CRIT,K,T,FID)
%
% INPUT	
%   A     Dataset
%   CRIT  String name of the criterion or untrained mapping 
%         (optional; default: 'NN', i.e. 1-Nearest Neighbor error)
%   K     Number of features to select 
%         (optional; default: return optimally ordered set of all features)
%   T     Tuning set (optional)
%   FID   File ID to write progress to (default [], see PRPROGRESS)
%
% OUTPUT
%   W     Output feature selection mapping
%   R     Matrix with step-by-step results of the selection
%
% DESCRIPTION
% Backward selection of K features using the dataset A. CRIT sets the 
% criterion used by the feature evaluation routine FEATEVAL. If the dataset
% T is given, it is used as a tuning set for FEATEVAL. For K=0, the optimal
% feature set (maximum value of FEATEVAL) is returned. The result W can be
% used for selecting features by B*W. In this case, features are ranked
% optimally. In R, the search is step by step reported:
% 
% 	R(:,1) : number of features
% 	R(:,2) : criterion value
% 	R(:,3) : added / deleted feature
%
% SEE ALSO
% MAPPINGS, DATASETS, FEATEVAL, FEATSELLR,
% FEATSELO, FEATSELF, FEATSELI, FEATSELP, FEATSELM, PRPROGRESS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Physics, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: featselb.m,v 1.8 2003/11/23 22:31:36 bob Exp $

function [w,r] = featselb(a,crit,ksel,t,fid)

	prtrace(mfilename);
	
	if (nargin < 2) | isempty(crit)
		prwarning(2,'No criterion specified, assuming 1-NN.');
		crit = 'NN';
	end
	if (nargin < 3) | isempty(ksel)
		ksel = 0; 		% Consider all the features and sort them.
	end
	if (nargin < 4)
		prwarning(3,'No tuning set supplied.');
		t = [];
	end
	if (nargin < 5)
		fid = [];
	end
	
	if nargin == 0 | isempty(a)
		% Create an empty mapping:
		w = mapping(mfilename,{crit,ksel,t});
	else
		prprogress(fid,'\nfeatselb : Backward Feature Selection')
		[w,r] = featsellr(a,crit,ksel,0,1,t,fid);
		prprogress(fid,'featselb  finished\n')
	end
	w = setname(w,'Backward FeatSel');

return
