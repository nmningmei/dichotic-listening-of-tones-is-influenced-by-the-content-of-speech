function result = individualreport(sub)
% individual report:
%sub = input('');
file(1) = dir(sprintf('Dichoticdi*%d*',sub));
file(2) = dir(sprintf('Dichoticgi*%d*',sub));
file(3) = dir(sprintf('Dichotichum*%d*',sub));
file(4) = dir(sprintf('Dichotictone*%d*',sub));
audiometer = dir(sprintf('Audiometer*%d*',sub));
% Audiometer
for i = 1:length(audiometer)
    load(audiometer(i).name)
    abs(Output.thresholds(1,:)-Output.thresholds(2,:))
end
% Dichotic Index
result = [];
for i = 1:4
    load(file(i).name)
    [temp,Dichotic(i)] = DichoticErrorTone_toneExcluded(Output,0,3,[]);
    result = [result;temp(1,:)];
    NFLI(i) = Dichotic(i).NFLI;
end
sentence = '\tleft ear\tright ear \tNFLI\n';
fprintf(sentence)
sentence = '\t%1.3f   \t%1.3f     \t%1.3f\t%s\n';
soundtype={'di-word','gi-nonword','hum','tone'};
% print the results
for  i = 1:4
    fprintf(sentence,result(i,:),NFLI(i), soundtype{i})
end
fig9=figure(9);
colors = {'k-','r--^','b-o','g--*'};
% plot the line graph
for i = 1:4
    plot(result(i,:),colors{i});hold on
end
legend(soundtype,'location','best')
set(gca,'xlim',[0.5,2.5])
set(gca,'xtick',[1,2])
set(gca,'xticklabel',{'left ear','right ear'})
xlabel('ear')
ylabel('correction proportion')
title('line graph of left right ear correction')
% other variables: responses, RT
for i =1:4
    load(file(i).name)
    r(i,:) = str2num(Output.response');
    fig1=figure(1);
    subplot(2,2,i)
    [N,X] = hist(r(i,:));
    barg = bar(X([1,4,7,10]),N([1,4,7,10]));
    title(soundtype{i})
    fig2=figure(2);
    subplot(4,1,i)
    plot(Output.RT);hold on
    line([1:length(Output.RT)],mean(Output.RT).*ones(length(Output.RT),1))
    title([soundtype{i},num2str(var(Output.RT))])
    fig3=figure(3);
    subplot(2,2,i)
    hist(Output.RT)
    title(soundtype{i})
end
set(fig1,'name', 'histogram of responses')
set(fig2,'name', 'reaction time showed by trial')
set(fig3,'name', 'histogram of reaction time')
try
% tone recognition tasks if applicable
st = dir(sprintf('*ToneRecognition*%d*',sub));
names={'di','gi','hum','tone'};
load(st.name);fig7=figure(7);cnt = 1;set(fig7,'name','Tone Recognition')
for i = 1:4
    if strcmp(Output(i).soundtype,names{1})
    subplot(2,2,1)
    responses(cnt,:) = str2num(Output(i).response');
    [N,X] = hist(responses(cnt,:));
    bar1=bar(X,N);
    set(bar1,'FaceColor','r');hold on
    RightActual(cnt,:) = Output(i).Right;
    [N,X] = hist(RightActual(cnt,:));
    bar2=bar(X,N);
    set(bar2,'FaceColor','b','barwidth',0.5);hold off;
    ylim([0 10])
    legend('response','actual tone')
    title(Output(i).soundtype);
    matchRate(cnt)=sum(responses(cnt,:) == RightActual(cnt,:),2)/20;
    elseif strcmp(Output(i).soundtype,names{2})
    subplot(2,2,2)
    responses(cnt,:) = str2num(Output(i).response');
    [N,X] = hist(responses(cnt,:));
    bar1=bar(X,N);
    set(bar1,'FaceColor','r');hold on
    RightActual(cnt,:) = Output(i).Right;
    [N,X] = hist(RightActual(cnt,:));
    bar2=bar(X,N);
    set(bar2,'FaceColor','b','barwidth',0.5);hold off;
    ylim([0 10])
    legend('response','actual tone')
    title(Output(i).soundtype);
    matchRate(i)=sum(responses(cnt,:) == RightActual(cnt,:),2)/20;
    elseif strcmp(Output(i).soundtype,names{3})
    subplot(2,2,3)
    responses(cnt,:) = str2num(Output(i).response');
    [N,X] = hist(responses(cnt,:));
    bar1=bar(X,N);
    set(bar1,'FaceColor','r');hold on
    RightActual(cnt,:) = Output(i).Right;
    [N,X] = hist(RightActual(cnt,:));
    bar2=bar(X,N);
    set(bar2,'FaceColor','b','barwidth',0.5);hold off;
    ylim([0 10])
    legend('response','actual tone')
    title(Output(i).soundtype);
    matchRate(cnt)=sum(responses(cnt,:) == RightActual(cnt,:),2)/20;
    elseif strcmp(Output(i).soundtype,names{4})
    subplot(2,2,4)
    responses(cnt,:) = str2num(Output(i).response');
    [N,X] = hist(responses(cnt,:));
    bar1=bar(X,N);
    set(bar1,'FaceColor','r');hold on
    RightActual(cnt,:) = Output(i).Right;
    [N,X] = hist(RightActual(cnt,:));
    bar2=bar(X,N);
    set(bar2,'FaceColor','b','barwidth',0.5);hold off;
    ylim([0 10])
    legend('response','actual tone')
    title(Output(i).soundtype);
    matchRate(cnt)=sum(responses(cnt,:) == RightActual(cnt,:),2)/20;
    end
    cnt = cnt + 1;
end
fprintf('\ndi %1.2f\ngi %1.2f\nhum %1.2f\ntone %1.2f\n',matchRate)
end
