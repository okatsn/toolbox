% FI test script
ts = importdata('sample_data.csv');
% infoAnalysis(ts(:,2),'FIM','DisplayPDF',1,'WindowLength',8)
FIM = infoAnalysis(ts(:,3),@FisherInformation,'WindowLength',8);
figure; 
plot(FIM);

FI = infoAnalysis(ts(:,3),@FItest,'WindowLength',8);
figure; 
plot(FI);