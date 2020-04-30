function bla()
fnew = figure; 
blablabla = linspace(0,1,100);

plot(blablabla);

 
Paf.dim1=[0.085 0.88 0.95 0.1 ];% �l�ϼи�(a)(b)������m
Paf.dim2=[0.07 0.1 0.92 0.088]; % [x_begin y_begin width height]
Paf.figi = 3; %
Paf.evTAG = 'asdfasfd';
A_Fig_text_GRLF1(fnew,Paf );

set(gcf,'position',[0 0 760 540]); % adjust window dimension
print('png_file','-dpng','-r150'); % save to png

end

function  [Aaf]=A_Fig_text_GRLF1(fnew,Paf )
%���Ϫ�[�W�����B�и�

dim1=Paf.dim1;
dim2=Paf.dim2;
Aaf.a=annotation(fnew,'textbox',dim1,'String','');%�إ�annotation�ɥ��w�n���]�wcontanier(�i�H�O��ΡB���B�b�Y)���j�p�M�L��������r
Aaf.b=annotation(fnew,'textbox',dim2,'String','');
%contanier �o�̬O textbox
evTAG = Paf.evTAG;

%txtb0=sprintf('Figure A%i.',Paf.figi);
%txtb1=' Numerically simulated stochastic rupture process. (a) Original microscopic process. ' ;
%txtb2='(b) Smoothed macroscopic picture. ';
%txtb3='(c) The real rupture model from SRCMOD database. For more information please refer to the description in Figure 8 and section 4-2-3.';
%Aaf.figCap=[txtb0 txtb1 txtb2 txtb3];

cap_0=sprintf('Figure %i.',Paf.figi);
cap_pre1=sprintf(' A particular solution of the stochastic earthquake rupturing and the reference event %s from SRCMOD. ',evTAG) ;
cap_pre2='In this figure, the red solid lines (TEX) and green dashed lines (EXP) are the best fitting functions to slip distributions (blue circles). ';
cap_p1='(a) The original sample path of process X(t). ' ;
cap_p2 = '(b) The sample path smoothed from X(t) in (a). ';
cap_p3='(c) The rupture model of the reference event. ';
cap_p4='(d) The slip distribution of the simulated stochastic rupture process X(t). ';
cap_p5='(e) The slip distribution of the smoothed X(t). ';
cap_p6='(f) The slip distribution of the reference rupture model. ' ;
cap_end1='In this figure, the slip distributions are all displayed in the form of CCDF. ';
cap_end2='The color version of this figure is available only in the electronic edition.';


Aaf.figCap=[cap_pre1 cap_pre2 cap_p1 cap_p2 cap_p3 cap_p4 cap_p5 cap_p6 cap_end1 cap_end2];

Aaf.b.String={[cap_0 Aaf.figCap]};
%Aaf.b.String={[txtb0,txtb1];[txtb2 txtb3_1]; [txtb3_2 txtb3_3]};

int_space='                                                                     ';

%Aaf.a.String={['(a-1)',int_space,'(b-1)',int_space,'     (c)'];'';'';'';'';'';'';'';'';'';'';'';'';'';'';...
%                        ['(a-2)',int_space,'(b-2)',int_space]};%;'';�O���F�����
% Aaf.a.String={['(a)',int_space,'          (c)',int_space,'     (e)'];'';'';'';'';'';'';'';'';'';'';'';'';'';...
%                         ['(b)',int_space,'          (d)',int_space,'     (f)']};%;'';�O���F�����                  
Aaf.a.String={['(a)',int_space,'          (b)',int_space,'     (c)'];'';'';'';'';'';'';'';'';'';'';'';'';'';'';...
                        ['(d)',int_space,'          (e)',int_space,'     (f)']};%;'';�O���F�����         
                    

Aaf.a.HorizontalAlignment='left';%�a�����
Aaf.a.LineStyle='none';%�]�w�S���~��


Aaf.b.HorizontalAlignment='left';%�a�����
Aaf.b.LineStyle='none';%�]�w�S���~��



Aaf.b.FontSize=8;
Aaf.a.FontSize=12;
Aaf.a.FontName='Cambria Math';
Aaf.b.FontName='Cambria Math';


end


