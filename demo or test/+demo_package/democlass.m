classdef democlass   
% This example is from:
% https://www.mathworks.com/help/matlab/matlab_oop/example-representing-structured-data.html#f2-84646

% This section shows you how to access various package members from outside a package. Suppose that you have a package mypack with the following contents:
% 
% +mypack
% +mypack/myfcn.m                      % class
% +mypack/@MyFirstClass           
% +mypack/@MyFirstClass/myFcn.m         % method
% +mypack/@MyFirstClass/otherFcn.m
% +mypack/@MyFirstClass/MyFirstClass.m   % class
% +mypack/@MySecondClass
% +mypack/@MySecondClass/MySecondClass.m % class
% +mypack/+mysubpack
% +mypack/+mysubpack/myFcn.m

   properties
        Material
        SampleNumber
        Stress
        Strain
   end
   
    properties (Constant)
       % these are all read-only variables
       % attempting to set the value (e.g. democlass.const_a = 6) will result in error
        const_a = 9

   end
   
   properties (Dependent) 
       % in this section, value of the variables will be automatically
       % generated. Manually assign value to dependent variable will not
       % raise an error, but also has no effect.
        ModulusX2 
        Modulus % value obtained by modulus = get.Modulus(obj)
        
   end
   
   methods
        function obj = set.Material(obj,material)
        % This function checks the input name of the material is valid
        % function set.XXX is called when we are going
        % to set the value of XXX.
        % Example:
        %     dc = demo_class;
        %     material = 'brass';
        %     dc.Material = material;
         if (strcmpi(material,'aluminum') ||...
               strcmpi(material,'stainless steel') ||...
               strcmpi(material,'carbon steel'))
            obj.Material = material;
         else
            error('Invalid Material')
         end
        end
        
        function modx2 = get.ModulusX2(obj)
           modx2 = obj.Modulus*2; 
        end
        function modulus = get.Modulus(obj)
        % This function makes the value 'Modulus' automatically generated.
        % function get.XXX calculate the value of XXX according to other values
        % Example:
        %     dc = demo_class;
        %     dc.Stress = 4;
        %     dc.Strain = 5;
        %     dc.Modulus % it should be 0.8
        %     dc.Modulus = 7; 
        %     % it is useless to set the value of "Modulus", and no error won't occur.

          ind = find(obj.Strain > 0);
          modulus = mean(obj.Stress(ind)./obj.Strain(ind));
        end
        

   end
% See here for a more advanced example
% https://www.mathworks.com/help/matlab/matlab_prog/createmovingaveragesystemobject.html  
% https://www.mathworks.com/help/matlab/examples.html?category=object-oriented-programming&s_tid=CRUX_object-oriented-programming

end

