%% regular_expression
regexp('0.1se','(\d+\.?\d*e?[+-]?\d*)(?!(pt|sec))','match')
regexp('0.1e-23sec','(\d+\.?\d*e?[+-]?\d*)(?=(pt|sec))','match')
% [�r�Ŷ�]: ��: [ab+-] a��b��+��-
% (look ahead)
% % '(?=(pt|sec))': ���򤰻�᭱�n����(pt��sec)�~�|�ǰt�� 
% % '(?!(pt|sec))': ���򤰻�᭱������(pt��sec)�~�|�ǰt��
% e.g 
regexp('0.01sec','.*(?=sec)','match');

% (look behind)
regexp('renew','(?<=re)new','match')
regexp('renew','(?<!re)new','match')
% % '(?<=(pt|sec))': ���򤰻�e���n�Ore�~�|�ǰt�� 
% % '(?<!(pt|sec))': ���򤰻�e�����Ore�~�|�ǰt��
StNm = regexp(tsAIN_path.name{i},'(?<=\[)[A-Z]+','match','once');
% StNm: ���򤰻�e���O���A���~�|�ǰt��A�ǰt��Ĥ@�ӴN����('once')

%% Question:
regexp('100pt','\d+\.?\d+','match')
% ������o�ˤ]�ǰt�o��??

%% ���SDE_a ��i
smth_to = {'192345pt', '0.32sec','2sec','5e-5sec','0.1e-3sec','1.00e6pt','e64'};
for i = 1:numel(smth_to)
     regexp(smth_to{i},'(\d*\.?\d*e?[+-]?\d+\.?\d*)|(pt|sec)','match')
end

smth_to = {'192345pt', '0.32sec','2sec','5e-5sec','0.1e-3sec','1.00e6pt'};
sp_t = cell(2,numel(smth_to));
for i = 1:numel(smth_to)
     S = regexp(smth_to{i},'(?<sp_>\d*\.?\d*e?[+-]?\d+\.?\d*)(?<st_>pt|sec)','names');
     sp_t{1,i} = S.sp_;
     sp_t{2,i} = S.st_;

end
     smooth_parameter = S.sp_;
     smth_to = S.st_;

tic;
     for i = 1:100000
     Sm = regexp('192345pt','(?<sp_>\d*\.?\d*e?[+-]?\d+\.?\d*)(?<st_>pt|sec)','names');
     sp = Sm.sp_;
     st = Sm.st_;
     end
toc
     
tic;
     for i = 1:100000
     Sm = regexp('192345pt','(\d*\.?\d*e?[+-]?\d+\.?\d*)|(pt|sec)','match');
     sp2 = Sm{1};
     st2 = Sm{2};
     end
toc


%% names, Greedy & non-greedy
% output example:
%     S.folder: 'smooth_to_100000pt'
%     S.Ftype: 'Coulomb'
text = 'C:\\TimeSeries20181220\smooth_to_100000pt\[Coulomb]TimeSeries(100000pt)_001.txt';
S2 = regexp(text,'(?<folder>smo.*?(pt|inal)).*(?<Ftype>(Coulomb|viscous))','names');
% % quantifier (*,+,?,{m,n}) �᭱
% 1. �����F��: �g���Ҧ��A�|�ɥi��ǰt�Ce.g. : 'smo.*(pt|inal)'  %('.'�N��ǰt���N�r��)
%     output example:'smooth_to_100000pt\[Coulomb]TimeSeries(100000pt'
% 2. ���ݸ�: �i�k�Ҧ��A�̧C���פǰt�Ce.g. :'smo.*?(pt|inal)'
%     output example: 'smooth_to_100000pt'

%% example
entry_i = 'Article{lemons_paul_1997,  author={Lemons, Don S. and Gythiel, Anthony}, volume  = {65},year    = {1997}}';
greedmode_author = regexpi(entry_i,'(?<=author\s*=\s*)\{.+\}','match','once');
lazymode_author = regexpi(entry_i,'(?<=author\s*=\s*)\{.+?\}','match','once');

       