function [ShannonEntropyPower] = ShannonEntropyPower(ShannonEntropy)

ShannonEntropyPower = exp(2*ShannonEntropy)/(2*pi*exp(1));
% Please refer to Eq.5 in *Analysis of dynamics in magnetotelluric data by
% using the Fisher¡VShannon method* by Luciano Telesca, Michele Lovallo,
% Han-Lun Hsu, Chien-Chih Chen (2011)
end

