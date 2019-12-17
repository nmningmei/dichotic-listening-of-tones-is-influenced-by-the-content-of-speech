function [efs,F,cdfs,p,eps,dfs,b,y2,sig]=repanova(d,D,fn,gg,alpha);	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% R.Henson, 17/3/03; rik.henson@mrc-cbu.cam.ac.uk
%
% General N-way (OxPxQxR...) repeated measures ANOVAs (no nonrepeated factors)
%
% Input:
%
% d = data	A matrix with rows = replications (eg subjects) and
%		              columns = conditions 
%
% D = factors	A vector with as many entries as factors, each entry being
%		the number of levels for that factor
%
%		Data matrix d must have as many columns (conditions) as
%		the product of the elements of the factor matrix D
%
%		First factor rotates slowest; last factor fastest
% 
% 	Eg, in a D=[2 3] design: factor A with 2 levels; factor B with 3:
%	    data matrix d must be organised:
%
%		A1B1	A1B2	A1B3	A2B1	A2B2	A2B3
% 	rep1
%	rep2
%	...
%	
% Output:
%
% efs 	= effect, eg [1 2] = interaction between factor 1 and factor 2
% F   	= F value
% cdfs 	= corrected df's (using Greenhouse-Geisser)
% p     = p-value
% eps   = epsilon
% dfs   = original dfs
% b     = betas
% y2    = cell array of means for each level in a specific ANOVA effect
% sig   = cell array of significant effects (uncorrected and Bonferroni corrected)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<5
	alpha=0.05;
end

if nargin<4
	gg=1;		% G-G correction
end

if nargin<3		% No naming of factors provided
   for f=1:length(D)
	fn{f}=sprintf('%d',f);
   end
end

Nf = length(D);		% Number of factors
Nd = prod(D);		% Number of conditions
Ne = 2^Nf - 1;		% Number of effects
Nr = size(d,1);		% Number of replications (eg subjects)

sig=cell(2,1);

if size(d,2) ~= Nd
	error(sprintf('data has %d conditions; design only %d',size(d,2),Nd))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sc = cell(Nf,2);	% create main effect/interaction component contrasts
for f = 1 : Nf
	sc{f,1} = ones(D(f),1);
	sc{f,2} = detrend(eye(D(f)),0);
end 

sy = cell(Nf,2);	% create main effect/interaction components for means
for f = 1 : Nf
	sy{f,1} = ones(D(f),1)/D(f);
	sy{f,2} = eye(D(f));
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for e = 1 : Ne		% Go through each effect

	cw = num2binvec(e,Nf)+1;

	c  = sc{1,cw(Nf)};	% create full contrasts
	for f = 2 : Nf
		c = kron(c,sc{f,cw(Nf-f+1)});
	end

	y = d * c;		% project data to contrast sub-space

	cy  = sy{1,cw(Nf)};	%  calculate component means
	for f = 2 : Nf
		cy = kron(cy,sy{f,cw(Nf-f+1)});
	end
	y2{e} = mean(d * cy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	nc = size(y,2);
	df1 = rank(c);
	df2 = df1*(Nr-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% long GLM way (no GG):
%
%	y = y(:);
%	X = kron(eye(nc),ones(Nr,1));
%	b{e} = pinv(X)*y;
%	Y = X*b{e};
%	R = eye(nc*Nr)- X*pinv(X);
%	r = y - Y;
%%	V = r*r';
%	V = y*y';
%	eps(e) = trace(R*V)^2 / (df1 * trace((R*V)*(R*V)));
%
%%	ss = Y'*y;
%%	mse = (y'*y - ss)/df2;
%%	mss = ss/df1;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% computationally simpler way

	b{e} = mean(y);			
	ss   =  sum(y*b{e}');
	mse  = (sum(diag(y'*y)) - ss)/df2;
	mss  =  ss/df1;

	if gg
		V      = cov(y);			% sample covariance
		eps(e) = trace(V)^2 / (df1*trace(V'*V));% Greenhouse-Geisser 
	else
		eps(e) = 1;
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	efs{e} = Nf+1-find(cw==2);			% codes which effect 

	F(e)   = mss/mse;

	dfs(e,:)  = [df1 df2];
	cdfs(e,:) = eps(e)*dfs(e,:);

	p(e) = 1-spm_Fcdf(F(e),cdfs(e,:));

	if p(e) < alpha; sig{1}=[sig{1} e]; end
	if p(e) < alpha/Ne; sig{2}=[sig{2} e]; end

	en=fn{efs{e}(1)};	% Naming of factors
	for f = 2:length(efs{e})
		en = [fn{efs{e}(f)} en];
	end

	disp(sprintf('Effect %02d: %-18s F(%3.2f,%3.2f)=%4.3f,\tp=%4.3f',...
		e,en,cdfs(e,1),cdfs(e,2),F(e),p(e)))
end

disp(sprintf('\n'))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub-function to code all main effects/interactions

function b = num2binvec(d,p)

if nargin<2
	p = 0;		% p is left-padding with zeros option
end

d=abs(round(d));

if(d==0)
	b = 0;
else
	b=[];
 	while d>0
		b=[rem(d,2) b];
		d=floor(d/2);
 	end
end

b=[zeros(1,p-length(b)) b];

function F = spm_Fcdf(x,v,w)
% Cumulative Distribution Function (CDF) of F (Fisher-Snedecor) distribution
% FORMAT F = spm_Fpdf(x,df)
% FORMAT F = spm_Fpdf(x,v,w)
%
% x  - F-variate   (F has range [0,Inf) )
% df - Degrees of freedom, concatenated along last dimension
%      Eg. Scalar (or column vector) v & w. Then df=[v,w];
% v  - Shape parameter 1 /   numerator degrees of freedom (v>0)
% w  - Shape parameter 2 / denominator degrees of freedom (w>0)
% F  - CDF of F-distribution with [v,w] degrees of freedom at points x
%__________________________________________________________________________
%
% spm_Fcdf implements the Cumulative Distribution Function of the F-distribution.
%
% Definition:
%--------------------------------------------------------------------------
% The CDF F(x) of the F distribution with degrees of freedom v & w,
% defined for positive integer degrees of freedom v & w, is the
% probability that a realisation of an F random variable X has value
% less than x F(x)=Pr{X<x} for X~F(v,w). The F-distribution is defined
% for v>0 & w>0, and for x in [0,Inf) (See Evans et al., Ch16).
%
% Variate relationships: (Evans et al., Ch16 & 37)
%--------------------------------------------------------------------------
% The square of a Student's t variate with w degrees of freedom is
% distributed as an F-distribution with [1,w] degrees of freedom.
%
% For X an F-variate with v,w degrees of freedom, w/(w+v*X^2) has
% distributed related to a Beta random variable with shape parameters
% w/2 & v/2.
%
% Algorithm:
%--------------------------------------------------------------------------
% Using the relationship with the Beta distribution: The CDF of the
% F-distribution with v,w degrees of freedom is related to the
% incomplete beta function by:
%       Pr(X<x) = 1 - betainc(w/(w+v*x^2),w/2,v/2)
% See Abramowitz & Stegun, 26.6.2; Press et al., Sec6.4 for
% definitions of the incomplete beta function. The relationship is
% easily verified by substituting for w/(w+v*x^2) in the integral of the
% incomplete beta function.
%
% MATLAB's implementation of the incomplete beta function is used.
%
%
% References:
%--------------------------------------------------------------------------
% Evans M, Hastings N, Peacock B (1993)
%       "Statistical Distributions"
%        2nd Ed. Wiley, New York
%
% Abramowitz M, Stegun IA, (1964)
%       "Handbook of Mathematical Functions"
%        US Government Printing Office
%
% Press WH, Teukolsky SA, Vetterling AT, Flannery BP (1992)
%       "Numerical Recipes in C"
%        Cambridge
%
%__________________________________________________________________________
% Copyright (C) 1992-2011 Wellcome Trust Centre for Neuroimaging

% Andrew Holmes
% $Id$


%-Format arguments, note & check sizes
%--------------------------------------------------------------------------
if nargin<2, error('Insufficient arguments'), end

%-Unpack degrees of freedom v & w from single df parameter (v)
if nargin<3
    vs = size(v);
    if prod(vs)==2
        %-DF is a 2-vector
        w = v(2); v = v(1);
    elseif vs(end)==2
        %-DF has last dimension 2 - unpack v & w
        nv = prod(vs);
        w  = reshape(v(nv/2+1:nv),vs(1:end-1));
        v  = reshape(v(1:nv/2)   ,vs(1:end-1));
    else
        error('Can''t unpack both df components from single argument')
    end
end

%-Check argument sizes
ad = [ndims(x);ndims(v);ndims(w)];
rd = max(ad);
as = [[size(x),ones(1,rd-ad(1))];...
      [size(v),ones(1,rd-ad(2))];...
      [size(w),ones(1,rd-ad(3))]];
rs = max(as);
xa = prod(as,2)>1;
if sum(xa)>1 && any(any(diff(as(xa,:)),1))
    error('non-scalar args must match in size'), end

%-Computation
%--------------------------------------------------------------------------
%-Initialise result to zeros
F = zeros(rs);

%-Only defined for strictly positive v & w. Return NaN if undefined.
md = ( ones(size(x))  &  v>0  &  w>0 );
if any(~md(:))
    F(~md) = NaN;
    warning('Returning NaN for out of range arguments');
end

%-Non-zero where defined and x>0
Q  = find( md  &  x>0 );
if isempty(Q), return, end
if xa(1), Qx=Q; else Qx=1; end
if xa(2), Qv=Q; else Qv=1; end
if xa(3), Qw=Q; else Qw=1; end

%-Compute
F(Q) = 1 - betainc(w(Qw)./(w(Qw) + v(Qv).*x(Qx)),w(Qw)/2,v(Qv)/2);