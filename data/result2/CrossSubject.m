clear all; close all;clc
% cross subjects report:
pool = [11:26,28,29];%17,19,21,22,23:24];
for sub = pool
file(1,sub) = dir(sprintf('Dichoticdi*%d*',sub));
file(2,sub) = dir(sprintf('Dichoticgi*%d*',sub));
file(3,sub) = dir(sprintf('Dichotichum*%d*',sub));
file(4,sub) = dir(sprintf('Dichotictone*%d*',sub));
end
%
result = [];
for i = 1:4
for sub = pool
    load(file(i,sub).name)
    [temp1,Dichotic(sub)] = DichoticErrorTone_toneExcluded(Output,0,9,[]);
    result = [result,temp1(1,:)];
    NFLI(i,sub) = Dichotic(sub).NFLI;
    UU(i,sub) = (temp1(1,2) - temp1(1,1)) ./ (temp1(1,2) + temp1(1,1))*100;
end
end
seconddim = size(result,1) * size(result,2) / 4;
result = reshape(result,seconddim,4);
result = result';
% NFLI is calculated individually and take the mean over the individual
% index
mean_NFLI = mean(NFLI(:,pool),2);
el_NFLI = std(NFLI(:,pool)')./sqrt(length(pool));
%
leftcol = result(:,1:2:end);% odd columns are left ear
rightcol = result(:,2:2:end);% even columns are right ear
eleft = std(leftcol')./sqrt(length(pool));% standard error
eright= std(rightcol')./sqrt(length(pool));% standard error
leftcol = mean(leftcol,2);
rightcol = mean(rightcol,2);
mean_result = [leftcol,rightcol];
%
sentence = '\tleft\tright\tNFLI\n';
fprintf(sentence)
sentence = '\t%1.3f\t%1.3f\t%1.3f\t%s\n';
soundtype={'di-word','gi-nonword','hum','tone'};
for  i = 1:4
    fprintf(sentence,mean_result(i,:),mean_NFLI(i), soundtype{i})
end
%
figure(9)
colors = {'k-','r--^','b-o','g--*'};
for i = 1:4
    plot([1,2],mean_result(i,:),colors{i});hold on
    %errorbar([1,2],mean_result(i,:),[eleft(i),eright(i)],colors{i})
end
legend(soundtype,'location','best')
set(gca,'xlim',[0.5,2.5])
set(gca,'xtick',[1,2])
set(gca,'xticklabel',{'left ear','right ear'})
ylabel('correction')
% bar graphs with error bars
figure(8)
colors = {'ko','r^','bo','g*'};
for i = 1:4
    subplot(1,4,i)
    bar([1,2],mean_result(i,:));hold on
    title(soundtype{i})
    errorbar([1,2],mean_result(i,:),[eleft(i),eright(i)],colors{i})
    set(gca,'xtick',[1,2])
    set(gca,'xticklabel',{'left ear','right ear'})
    ylabel('correction')
end

% bar graph for NFLI (index)
fig12=figure(12);
bars=bar([1:4],mean_NFLI);hold on
err=errorbar([1:4],mean_NFLI,el_NFLI,'r.');
set(bars,'linestyle','none')
set(gca,'xticklabel',{'di-word','gi-nonword','hum','lexical tone'})
title('NFLI index')
ylabel('LEA <---------> REA')
%% tone regonition
clear all; close all; clc
st = dir('ToneRe*.mat');
names={'di','gi','hum','tone'};
responses= zeros(4,20,length(st));
for ii = 1:length(st)
    load(st(ii).name)
    for i = 1:4
        if strcmp(Output(i).soundtype,names{1})
            responses(1,:,ii) = str2num(Output(i).response');
            RightActual(1,:,ii) = Output(i).Right;
        elseif strcmp(Output(i).soundtype,names{2})
            responses(2,:,ii) = str2num(Output(i).response');
            RightActual(2,:,ii) = Output(i).Right;
        elseif strcmp(Output(i).soundtype,names{3})
            responses(3,:,ii) = str2num(Output(i).response');
            RightActual(3,:,ii) = Output(i).Right;
        elseif strcmp(Output(i).soundtype,names{4})
            responses(4,:,ii) = str2num(Output(i).response');
            RightActual(4,:,ii) = Output(i).Right;
        end
    end
    
end

for i = 1:4
   
    Response.(names{i}) = [];
    temp1 = squeeze(responses(i,:,:));
    temp2 = squeeze(RightActual(i,:,:));
    temp1 = temp1(:);
    temp2 = temp2(:);
    Response.(names{i}) = temp1;
    Actual.(names{i}) = temp2;
    subplot(2,2,i)
    [N,X]=hist(temp1);
    bar1=bar(X,N);
    set(bar1,'Facecolor','r');hold on
    [N,X]=hist(temp2);
    bar2=bar(X,N);
    set(bar2,'facecolor','b','barwidth',0.5);hold off
    legend('response','actual tone')
    title(names{i})
    set(gca,'xtick',[1:4])
    ylim([0,120])
end
    
















