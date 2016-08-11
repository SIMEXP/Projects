function c = surf_hot_cold(n,per)
% Hot-col color map
%
% SYNTAX:
% C = NIAK_HOT_COLD(N,PER)
%
% INPUTS:
%   N (integer, default 256) number of colors in the map
%   PER (scalar, default 0.5) the proportion of hot colors
%
% OUTPUTS:
%   C (matrix Nx3) each row is the red/green/blue intensity in the color (from 0 to 1) 

if nargin < 1
    n = 256;
end
if nargin < 2
    per = 0.5;
end

c1 = custom_color([0.8 0.8 0.8], [1 0 0], [1 1 0], (1.28*n*per));
if ~isempty(c1)
    c1 = c1(1:ceil(n*per),:);
end
c2 = custom_color([0.8 0.8 0.8], [1 0 0], [1 1 0], (1.28*n*(1-per)));
if ~isempty(c2)
    c2 = c2(1:(n-length(c1)),:);
    c2 = c2(:,[3 2 1]);
    c2(size(c2,1):-1:1,:);
end
c = [c2(size(c2,1):-1:1,:) ; c1];
end

function cMap = custom_color(varargin)
%% MAKECOLORMAP makes smoothly varying colormaps
% a = makeColorMap(beginColor, middleColor, endColor, numSteps);
% a = makeColorMap(beginColor, endColor, numSteps);
% a = makeColorMap(beginColor, middleColor, endColor);
% a = makeColorMap(beginColor, endColor);
%
% all colors are specified as RGB triples
% numSteps is a scalar saying howmany points are in the colormap
%
% Examples:
%
% peaks;
% a = makeColorMap([1 0 0],[1 1 1],[0 0 1],40);
% colormap(a)
% colorbar
%
% peaks;
% a = makeColorMap([1 0 0],[0 0 1],40);
% colormap(a)
% colorbar
%
% peaks;
% a = makeColorMap([1 0 0],[1 1 1],[0 0 1]);
% colormap(a)
% colorbar
%
% peaks;
% a = makeColorMap([1 0 0],[0 0 1]);
% colormap(a)
% colorbar

% Reference:
% A. Light & P.J. Bartlein, "The End of the Rainbow? Color Schemes for
% Improved Data Graphics," Eos,Vol. 85, No. 40, 5 October 2004.
% http://geography.uoregon.edu/datagraphics/EOS/Light&Bartlein_EOS2004.pdf

defaultNum = 100;
errorMessage = 'See help MAKECOLORMAP for correct input arguments';

if nargin == 2 %endPoints of colormap only
    color.start  = varargin{1};
    color.middle = [];
    color.end    = varargin{2};
    color.num    = defaultNum;
elseif nargin == 4 %endPoints, midPoint, and N defined
    color.start  = varargin{1};
    color.middle = varargin{2};
    color.end    = varargin{3};
    color.num    = varargin{4};
elseif nargin == 3 %endPoints and num OR endpoints and Mid
    if numel(varargin{3}) == 3 %color
        color.start  = varargin{1};
        color.middle = varargin{2};
        color.end    = varargin{3};
        color.num    = defaultNum;
    elseif numel(varargin{3}) == 1 %numPoints
        color.start  = varargin{1};
        color.middle = [];
        color.end    = varargin{2};
        color.num    = varargin{3};
    else
        error(errorMessage)
    end
else
    error(errorMessage)
end
   
if color.num <= 1
    error(errorMessage)
end

if isempty(color.middle) %no midPoint
    cMap = interpMap(color.start, color.end, color.num);
else %midpointDefined
    [topN, botN] = sizePartialMaps(color.num);
    cMapTop = interpMap(color.start, color.middle, topN);
    cMapBot = interpMap(color.middle, color.end, botN);
    cMap = [cMapTop(1:end-1,:); cMapBot];
end
    

function cMap = interpMap(colorStart, colorEnd, n)

for i = 1:3
    cMap(1:n,i) = linspace(colorStart(i), colorEnd(i), n);
end
end

function [topN, botN] = sizePartialMaps(n)
n = n + 1;

topN =  ceil(n/2);
botN = floor(n/2);
% Copyright 2008 - 2009 The MathWorks, Inc.
end
end