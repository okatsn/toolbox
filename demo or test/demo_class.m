clear all
import demo_package.*
dp0 = demo_package.democlass;
%%
for i = 1:10
    pause(5)
    c = demo_package.democlass.const_a;
    disp(c)
    disp(demo_package.democlass.const_a);
    % if you change the value in script democlass.m manually and save,
    % the value of c do not change until this section is finished.
    % i.e. it's ok to edit the file when a certain script is running.
end

% if democlass.m is modified, it's unnecessary to import demo_package.* again.
disp(demo_package.democlass.const_a)

% error occurs when someone try to assign a value to a variable of property Constant
dp0.const_a = 5;
%% Set variable
% ! this set the variable Material be 'invalid_material' without triggering the set.Material function
% therefore, no error occurred
demo_package.democlass.Material = 'invalid_material';
disp(demo_package.democlass.Material)

% the later-defined class loses the method 'set.Material' too.
dp1 = demo_package.democlass;
disp(dp1.Material)
dp1.Material = 'invalid_material_again';
disp(dp1.Material)

% but previously assigned instance(?) works fine. (Error occurred as it should be)
dp0.Material = 'invalid_material';

%% Dependent Variable
% Dependent Variable will be automatically generated. 
% Manually assign value to dependent variable will not raise an error, but also has no effect.

dp0.Modulus % now it is NaN
dp0.ModulusX2 % hence it is also NaN
dp0.Stress = 4;
dp0.Strain = 5;
dp0.ModulusX2 % it is now dp0.Modulus*2 = 1.6
disp(dp0.Modulus); % it is 0.8 calculated through get.Modulus
% The order of Modulus & ModulusX2 in property (Dependent) does not matter;
% the order of get.Modulus & get.ModulusX2 in property (Dependent) does not
% matter either, even Modulus have to be calculated first inorder to
% calculate ModulusX2.