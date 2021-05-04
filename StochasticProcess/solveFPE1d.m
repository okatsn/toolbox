function [sol] = solveFPE1d(xspace,tspace,ic, F_C, F_ext, D, varargin)
% ic: initial condition, a function handle that takes xspace as input.
% e.g. 
%     ic = @(x) normpdf(x,0,1); % normal distribution with mean 0 std 1
%     or 
%     a_rectangle = @(x, left, right) double(x > left | x < right);   
%     ic = @(x) a_rectangle(x,-0.5,0.5);
% bc: boundary condition
% D: diffusion coefficient
% drift: drift function
% e.g.
%     Fext = 1; F_C = 2;
%     drift = @(x) -x/abs(x) + Fext;
% minimal executable example:
% F_C = 1; F_ext = 2; D = 1;
% xspace = -5:0.1:5;
% tspace = 0:0.001:7;
% [sol] = solveFPE1d(xspace,tspace,ic, F_C, F_ext, D);
% surf(xspace, tspace, sol); 
% shading interp; % make mesh grids invisible


    function [c, f, s] = pde_FPE(x, t, u, dudx)
        % u is probability
        A = F_C*x/abs(x);
        s = -F_ext*dudx; % source term
        f = A*u + D*dudx; % flux term
        c = 1;
    end

p = inputParser;
addParameter(p, 'SymmetryConstant' ,0); % see doc pdepe
parse(p, varargin{:});
m = p.Results.SymmetryConstant;

sol = pdepe(m,@pde_FPE,ic,@bc,xspace,tspace);
end

function [pl,ql,pr,qr] = bc(xl,ul,xr,ur,t)% bcfun
pl = ul; % 
ql = 0;% 
pr = ur;
qr = 0;
end


