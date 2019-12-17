clear all;clc
pool = 1:24;
gender=[0 1 0 nan nan 1 0 1 0 0 0 0 1 0 0 0 0 0 0 0 nan 0 1 0];
Takes = ones(1,24);
Takes([4,5,19,20]) = 0;
%kk= gender==1;
pool = nonzeros(pool(:) .* Takes(:));
pool = [0;pool];
condition = [{'hum'},{'tone'}];
%% group them into 4 conditions
% LEA hum
% REA hum
% LEA tone
% REA tone
for soundtype = condition
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        block = 1;
        LeftActual = Output(block).Left;
        responses = str2num(Output(block).respond');
        RightActual = Output(block).Right;
        tone = 3;
        I = cellfun(@(x) find(x==tone), Output(block).Permutations, 'UniformOutput', false);
        kk = cellfun('isempty',I);
        LeftActual(kk == 0) = [];
        responses(kk==0) = [];
        RightActual(kk==0) = [];
        correct = responses' == RightActual | responses' == LeftActual;
        LEA = sum(responses' ==LeftActual)/length(responses);
        REA = sum(responses' == RightActual)/length(responses);
        NFLI(ii) = (REA - LEA) ./ (LEA + REA);
        %figure('name',char(soundtype))
        %bar([LEA,REA])
        formatSpac = '\r\nsubject %d Block %d\t%s\t\nNFLI %2.2f\t\n';
        %fprintf(formatSpac,pool(ii),block,char(soundtype),NFLI(ii));
    end
    
    counting.(sprintf('%sLEA',char(soundtype))) = pool(find(NFLI<0));
    counting.(sprintf('%sREA',char(soundtype))) = pool(find(NFLI>0));
    
end
% individual cases and group according 4 conditions
clc
LEAhumNREAtone = counting.humLEA(ismember(counting.humLEA,counting.toneREA));
REAhumNLEAtone = counting.toneLEA(ismember(counting.toneLEA,counting.humREA));
LEAhumNLEAtone = counting.toneLEA(ismember(counting.toneLEA,counting.humLEA));
REAhumNREAtone = counting.humREA(ismember(counting.humREA,counting.toneREA));
InTotal = sort([LEAhumNREAtone;REAhumNLEAtone;LEAhumNLEAtone;REAhumNREAtone]);
Noingroup = pool(~ismember(pool,InTotal));
formatspaa = '\r\nLEA hum: %s\r\nREA hum: %s\r\nLEA tone: %s\r\nREA tone:%s\r\n';
fprintf(formatspaa,sprintf('%d ',counting.humLEA),sprintf('%d ',counting.humREA),sprintf('%d ',counting.toneLEA),sprintf('%d ',counting.toneREA))
formatspac = '\r\nLEA in hum and REA in tone: %s\r\nREA in hum and LEA in tone: %s\r\nLEA in hum and tone: %s\r\nREA in hum and tone: %s\r\nnot in any of these groups: %s\r\n';
fprintf(formatspac,sprintf('%d ',LEAhumNREAtone),sprintf('%d ',REAhumNLEAtone),sprintf('%d ',LEAhumNLEAtone),sprintf('%d ',REAhumNREAtone),sprintf('%d ',Noingroup))
pool = REAhumNREAtone;% change according to groups
clear NFLI
%% across all the subjects - exclude 3rd tone
clc;close all
condition = {'hum','tone'};
for soundtype = condition
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate, Dichotic] = DichoticErrorToneNo3(Output);% take out 3rd tone
        block = 1;
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    C.(char(soundtype)) = NFLI;
    figure
    set(gcf,'name',char(soundtype));
    subplot(3,1,1);hist(NFLI(:,1));%ylim([0,3])
    title('Both')
    %figure;
    subplot(3,1,2);hist(NFLI(:,2));%ylim([0,3])
    title('Right')
    %figure;
    subplot(3,1,3);hist(NFLI(:,3));%ylim([0,3])
    title('Left')
    % within group bar graph
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    figure('name',char(soundtype))
    bar(mean_NFLI);
    set(gca,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [H,P,CI,STATS]=ttest(NFLI);
    text(1,40,sprintf('p = %1.4f\n',P))
    Sentence = '\ncondition %s,\nblock %d,\np value is %1.4f, confident interval is [%1.3f,%1.3f]\n';
    fprintf(Sentence, char(soundtype), 1,P(1),CI(1,1),CI(2,1))
    fprintf(Sentence, char(soundtype), 2,P(2),CI(1,2),CI(2,2))
    fprintf(Sentence, char(soundtype), 3,P(3),CI(1,3),CI(2,3))
    % between group bar graph
    figure('name',char(soundtype))
    x=[1,2];
    set(gcf,'name',char(soundtype));
    [~,P, CI] = ttest2(BothEar(:,1),BothEar(:,2));
    Sentence = '\nEar effect: condition %s,\nblock %d, \np value is %1.4f, confident interval is [%1.4f,%1.4f]\n';
    fprintf(Sentence,char(soundtype),1,P,CI(1),CI(2))
    ss=subplot(1,3,1);
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'})
    text(0.5,0.65,sprintf('p value = %1.4f\n',P))
    title(ss,'Both')
    [~,P,CI]=ttest2(LeftEar(:,1),LeftEar(:,2));
    fprintf(Sentence,char(soundtype),2,P,CI(1),CI(2))
    ss=subplot(1,3,2);
    bar([1,2],mean(LeftEar));hold on;el = 1.96.*(std(LeftEar,1) ./ sqrt(length(LeftEar)-1));
    errorbar(x,mean(LeftEar,1),el,'go')
    set(ss,'XTickLabel',{'left','right'})
    title(ss,'Left')
    [~,P,CI]=ttest2(RightEar(:,1),RightEar(:,2));
    fprintf(Sentence,char(soundtype),3,P,CI(1),CI(2))
    ss=subplot(1,3,3);
    bar([1,2],mean(RightEar));hold on;er = std(RightEar,1) ./sqrt(length(RightEar)-1);
    errorbar(x,mean(RightEar,1),er,'r*')
    set(ss,'XTickLabel',{'left','right'})
    title(ss,'Right')
end
%% exclude subjects who perform badly, such as lots of erros, not good at attention blocks
clc;close all
condition={'hum','tone'};
for soundtype = condition
    pool = 1:24;
    Takes = ones(size(pool));
    Takes([4,5,19,20]) = 0;
    pool = nonzeros(pool .* Takes);
    Takes = ones(size(pool));
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        
        [MatchRate, Dichotic] = DichoticErrorTone(Output);
        %block = 1;
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        if NFLI(ii,2) < 0 || NFLI(ii,3) >0
            Takes(ii) = 0;
        end
        for block = 1:3
            % if no 3tone, 10, if have 3 tone, 40
            if length(Dichotic(1).LeftActual)...
                    -sum(nonzeros((Dichotic(block).correct)))>40
                Takes(ii) = 0;
            end
        end
    end
    pool = nonzeros(pool .* Takes);
    fprintf('\r\n%s\r\n',sprintf('%d ',pool))
    % this is the part actually starting analyzing data
    clear NFLI
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate, Dichotic] = DichoticErrorToneNo3(Output);
        %block = 1;
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    figure
    set(gcf,'name',char(soundtype));
    subplot(3,1,1);hist(NFLI(:,1));%ylim([0,3])
    title('both')
    %figure;
    subplot(3,1,2);hist(NFLI(:,2));%ylim([0,3])
    title('right')
    %figure;
    subplot(3,1,3);hist(NFLI(:,3));%ylim([0,3])
    title('left')
    % within group bar graph
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    figure('name',char(soundtype))
    bar(mean_NFLI);
    set(gca,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [H,P,CI,STATS]=ttest(NFLI);
    text(1,40,sprintf('p = %1.4f\n',P))
    Sentence = '\ncondition %s,\nblock %d,\np value is %1.7f, confident interval is [%1.3f,%1.3f]\n';
    fprintf(Sentence, char(soundtype), 1,P(1),CI(1,1),CI(2,1))
    fprintf(Sentence, char(soundtype), 2,P(2),CI(1,2),CI(2,2))
    fprintf(Sentence, char(soundtype), 3,P(3),CI(1,3),CI(2,3))
    % between group bar graph
    figure('name',char(soundtype))
    x=[1,2];
    set(gcf,'name',char(soundtype));
    [~,P, CI] = ttest2(BothEar(:,1),BothEar(:,2));
    Sentence = '\nEar effect: condition %s,\nblock %d, \np value is %1.4f, confident interval is [%1.4f,%1.4f]\n';
    fprintf(Sentence,char(soundtype),1,P,CI(1),CI(2))
    ss=subplot(1,3,1);
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    errorbar(x,mean(BothEar,1),eb,'*');text(0.5,0.65,sprintf('p value = %1.4f\n',P))
    title(ss,'Both')
    [~,P,CI]=ttest2(LeftEar(:,1),LeftEar(:,2));
    fprintf(Sentence,char(soundtype),2,P,CI(1),CI(2))
    ss=subplot(1,3,2);
    bar([1,2],mean(LeftEar));hold on;el = 1.96.*(std(LeftEar,1) ./ sqrt(length(LeftEar)-1));
    errorbar(x,mean(LeftEar,1),el,'go')
    title(ss,'Left')
    [~,P,CI]=ttest2(RightEar(:,1),RightEar(:,2));
    fprintf(Sentence,char(soundtype),3,P,CI(1),CI(2))
    ss=subplot(1,3,3);
    bar([1,2],mean(RightEar));hold on;er = std(RightEar,1) ./sqrt(length(RightEar)-1);
    errorbar(x,mean(RightEar,1),er,'r*')
    title(ss,'Right')
end


%% individual reports
clc;close all
for soundtype = condition
for ii = 1:length(pool)

    load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
    [MatchRate,Dichotic] = DichoticErrorToneNo3(Output);
    % a quantitative way to look if a subject is having a strong REA or LEA
    % if NFLI <0, then it is lEA
    % if NFLI >0, then it is REA
    [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
    % This could be used to check if the subject is paying attention to
    % what they were told to pay attention
    FLgain(ii) = NFLI(ii,2)-NFLI(ii,1);
    FRgain(ii) = NFLI(ii,3)-NFLI(ii,1);
    formatSpec1 = '\r\nBoth\tLEA  %2.2f\tREA  %2.2f\terror %d/%d\tNFLI is %2.2f';
    formatSpec2 = '\rRight\tLEA  %2.2f\tREA  %2.2f\terror %d/%d\tFLgain is %2.2f';
    formatSpec3 = '\rLeft\tLEA  %2.2f\tREA  %2.2f\terror %d/%d\tFRgain is %2.2f\r';
    c(ii) = NFLI(ii,1);
%     if NFLI(ii,2) < 0 || NFLI(ii,3) > 0
%         disp(pool(ii))
%     end
    % print out the result on the command window
    fprintf('\r\nsubject %d doing %s condition',pool(ii), char(soundtype))
    fprintf(formatSpec1, [Dichotic(1).LEA,Dichotic(1).REA]*100, ...
        length(Dichotic(1).LeftActual)-sum(nonzeros((Dichotic(1).correct))),180,NFLI(ii,1))
    fprintf(formatSpec2, [Dichotic(2).LEA,Dichotic(2).REA]*100, ...
        length(Dichotic(1).LeftActual)-sum(nonzeros((Dichotic(2).correct))),180,NFLI(ii,2)-NFLI(ii,1))
    fprintf(formatSpec3, [Dichotic(3).LEA,Dichotic(3).REA]*100, ...
        length(Dichotic(1).LeftActual)-sum(nonzeros((Dichotic(3).correct))),180 ,NFLI(ii,3)-NFLI(ii,1))
    BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
    RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
    LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
    Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
    Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
    Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
end
end
%% cross subjects measurement
% take a look at the error rate first
% take out those who make lots of mistakes
% cross subjects analysis

for soundtype = condition
    for ii = 1:length(pool)

        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate, Dichotic] = DichoticErrorTone(Output);
        CorrectTrial = zeros(3,180);
        for kk = 1:3
            CorrectTrial(kk,:)=Dichotic(kk).correct;
            CorrectRatio(kk,:)=180-sum(nonzeros(CorrectTrial(kk,:)));
        end
        CorCNT(:,ii) = CorrectRatio;
    end
    k = find(CorCNT(1,:)<30);
    MAT=[];
    newpool = pool(k);
    for ii = 1:length(newpool)
        newpool(ii)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),newpool(ii)))
        [MatchRate, Dichotic] = DichoticErrorTone(Output);
        block=1;
        MAT = [MAT;Dichotic(block).LeftActual, Dichotic(block).response,Dichotic(block).RightActual];
    end
    YY = find(MAT(:,1) == 3 | MAT(:,3) ==3);
    MAT(YY,:) = [];
    LEA = sum(MAT(:,2)==MAT(:,1)) / length(MAT);
    REA = sum(MAT(:,2)==MAT(:,3)) / length(MAT);
    figure('name',char(soundtype))
    bar([LEA,REA])
    formatSpac = '\r\nBlock %d\t%s\t\nLEA %2.2f\fREA %2.2f\t\n';
    fprintf(formatSpac,block,char(soundtype),LEA,REA);
end


%% analysis for individual tones. 

clear all;clc;
pool = 1:24;
Takes = ones(1,24);
Takes([4,5,19,20]) = 0;
%Takes([19,20])=0;
pool = nonzeros(pool .* Takes);
condition = [{'hum'}];

figure
block = 1;
for soundtype = condition
for ii = 1:length(pool)
    
load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
LeftActual = Output(block).Left;
responses = str2num(Output(block).respond');
RightActual = Output(block).Right;
for tone = 1:4
    cnt = 1;
    KK = [];
    for PR = 1:length(responses)
        if ismember(tone, Output(block).Permutations{PR})
            KK = [KK,cnt];
        end
        cnt = cnt +1;
    end
    LEA(tone,:) = sum(responses(KK)' == LeftActual(KK))/ length(KK);
    REA(tone,:) = sum(responses(KK)' == RightActual(KK))/length(KK);
    fortspam = '\n\tsubject %d\n\t%s condition, block %d, tone %d, \nLEA\t%1.4f\tREA\t%1.4f\n';
    fprintf(fortspam, pool(ii),char(soundtype),block,tone,LEA(tone),REA(tone))
    
end
NLFI(ii,:) = (REA - LEA)./(REA+LEA);

end
% for tone = 1:4
%     subplot(4,1,tone)
%     hist(NLFI(tone,:))
%     
% end
hist(NLFI)
legend toggle
anova1(NLFI)
end
%%
block = 1;condition={'hum','tone'};
for soundtype = condition
    RT = [];
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        RT = [RT,Output(block).RT];
    end
    percntiles = prctile(RT,[5,95]);
    outlierIndex = RT < percntiles(1)| RT>percntiles(2);
    excluRT = RT(~outlierIndex);
    figure;subplot(211);hist(RT,200);subplot(212);hist(excluRT,200)
end
%% use reaction time a excluding criteria
clc;close all
for soundtype = condition
    RT = [];
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        RT = [RT,Output(block).RT];
    end
    percntiles = prctile(RT,[5,95]);
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [Perc, Dichotic] = DichoticErrorTone_RT(Output,percntiles(1),percntiles(2));
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    figure
    set(gcf,'name',char(soundtype));
    subplot(3,1,1);hist(NFLI(:,1));%ylim([0,3])
    title('Both')
    %figure;
    subplot(3,1,2);hist(NFLI(:,2));%ylim([0,3])
    title('Right')
    %figure;
    subplot(3,1,3);hist(NFLI(:,3));%ylim([0,3])
    title('Left')
    % within group bar graph
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    figure('name',char(soundtype))
    bar(mean_NFLI);
    set(gca,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [H,P,CI,STATS]=ttest(NFLI);
    text(1,40,sprintf('p = %1.4f\n',P))
    Sentence = '\ncondition %s,\nblock %d,\np value is %1.4f, confident interval is [%1.3f,%1.3f]\n';
    fprintf(Sentence, char(soundtype), 1,P(1),CI(1,1),CI(2,1))
    fprintf(Sentence, char(soundtype), 2,P(2),CI(1,2),CI(2,2))
    fprintf(Sentence, char(soundtype), 3,P(3),CI(1,3),CI(2,3))
    % between group bar graph
    figure('name',char(soundtype))
    x=[1,2];
    set(gcf,'name',char(soundtype));
    [~,P, CI] = ttest2(BothEar(:,1),BothEar(:,2));
    Sentence = '\nEar effect: condition %s,\nblock %d, \np value is %1.4f, confident interval is [%1.4f,%1.4f]\n';
    fprintf(Sentence,char(soundtype),1,P,CI(1),CI(2))
    ss=subplot(1,3,1);
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'})
    text(0.5,0.65,sprintf('p value = %1.4f\n',P))
    title(ss,'Both')
    [~,P,CI]=ttest2(LeftEar(:,1),LeftEar(:,2));
    fprintf(Sentence,char(soundtype),2,P,CI(1),CI(2))
    ss=subplot(1,3,2);
    bar([1,2],mean(LeftEar));hold on;el = 1.96.*(std(LeftEar,1) ./ sqrt(length(LeftEar)-1));
    errorbar(x,mean(LeftEar,1),el,'go')
    set(ss,'XTickLabel',{'left','right'})
    title(ss,'Left')
    [~,P,CI]=ttest2(RightEar(:,1),RightEar(:,2));
    fprintf(Sentence,char(soundtype),3,P,CI(1),CI(2))
    ss=subplot(1,3,3);
    bar([1,2],mean(RightEar));hold on;er = std(RightEar,1) ./sqrt(length(RightEar)-1);
    errorbar(x,mean(RightEar,1),er,'r*')
    set(ss,'XTickLabel',{'left','right'})
    title(ss,'Right')
end
%%
% 1.When using only RT as criteria: excluding all trials that are outliers
% 2.When use both RT and 3rd tone as criteria: excluding all trials of 3rd 
%   tone and trials whose RT is an outlier
% 3.When use only 3rd tone as criteria: excluding all 3rd tone trials
% 4.When use both performance and 3rd tone as criteria: excluding subjects 
%   who performed poorly and then excluding all 3rd tone trials.
% 5.When use all three criteria: excluding subjects who performed poorly, 
%   and then excluding all 3rd tone trials and trials that the RTs are outliers.
clear all;clc;close all
condition = [{'hum'},{'tone'}];block = 1;

for soundtype = condition
    pool = 1:24;Takes = ones(1,24);Takes([4,5,19,20]) = 0;
    pool = nonzeros(pool .* Takes);pool=[0;pool];
    RT = [];
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        RT = [RT,Output(block).RT];
    end
    percntiles = prctile(RT,[5,95]);
% 1.When using only RT
fprintf('Using RT and pool is %s\r\n',sprintf('%d ',pool))
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [Perc, Dichotic] = DichoticErrorTone_RT(Output,percntiles(1),percntiles(2),0);
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    figure('name',sprintf('%s block 1',char(soundtype)));
    ss=subplot(251);
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    bar(mean_NFLI);ylim([-100 100])
    set(ss,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [~,P,~,~]=ttest(NFLI);temp(1,1)=P(1);
    text(1,60,sprintf('%1.3f\n',P(1)));title('only RT')
    ss=subplot(256);
    x=[1,2];
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    ylim([0,0.7])
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'});[~,P, ~] = ttest2(BothEar(:,1),BothEar(:,2));temp(2,1)=P(1);
    text(0.5,0.65,sprintf('%1.3f\n',P));title(ss,'ear effect')
    
    % 2.When use both RT and 3rd tone
    pool = 1:24;Takes = ones(1,24);Takes([4,5,19,20]) = 0;
    pool = nonzeros(pool .* Takes);pool=[0;pool];
    fprintf('Using Rt and 3rd tone and pool is %s\n\r',sprintf('%d ',pool))
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [Perc, Dichotic] = DichoticErrorTone_RT(Output,percntiles(1),percntiles(2),1);
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    ss=subplot(252);
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    bar(mean_NFLI);ylim([-100 100])
    set(ss,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [~,P,~,~]=ttest(NFLI);temp(1,1)=P(1);
    text(1,60,sprintf('%1.3f\n',P(1)));title('RT and 3rd tone')
    ss=subplot(257);
    x=[1,2];
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    ylim([0,0.7])
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'});[~,P, ~] = ttest2(BothEar(:,1),BothEar(:,2));temp(2,1)=P(1);
    text(0.5,0.65,sprintf('%1.3f\n',P))
    
    % 3.When use only 3rd tone as criteria
    pool = 1:24;Takes = ones(1,24);Takes([4,5,19,20]) = 0;
    pool = nonzeros(pool .* Takes);pool=[0;pool];
    fprintf('using 3rd tone and pool is %s\n\r',sprintf('%d ',pool))
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate, Dichotic] = DichoticErrorToneNo3(Output);% take out 3rd tone
        block = 1;
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    ss=subplot(253);
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    bar(mean_NFLI);ylim([-100 100])
    set(ss,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [~,P,~,~]=ttest(NFLI);temp(1,1)=P(1);
    text(1,60,sprintf('%1.3f\n',P(1)));title('only 3rd tone')
    ss=subplot(258);
    x=[1,2];
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    ylim([0,0.7])
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'});[~,P, ~] = ttest2(BothEar(:,1),BothEar(:,2));temp(2,1)=P(1);
    text(0.5,0.65,sprintf('%1.3f\n',P))
    
    % 4.When use both performance and 3rd tone
    % restate the pool and make sure I have everyone at the initiation
    pool = 1:24;
    Takes = ones(size(pool));
    Takes([4,5,19,20]) = 0;
    pool = nonzeros(pool .* Takes);pool=[0;pool];
    Takes = ones(size(pool));
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        
        [MatchRate, Dichotic] = DichoticErrorTone(Output);
        %block = 1;
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        if NFLI(ii,2) < 0 || NFLI(ii,3) >0
            Takes(ii) = 0;
        end
        for block = 1:3
            % if no 3tone, 10, if have 3 tone, 40
            if length(Dichotic(1).LeftActual)...
                    -sum(nonzeros((Dichotic(block).correct)))>40
                Takes(ii) = 0;
            end
        end
    end
    pool = nonzeros(pool .* Takes);
    fprintf('using error and 3rd tone and pool is %s\r\n',sprintf('%d ',pool))
    clear NFLI
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate, Dichotic] = DichoticErrorToneNo3(Output);
        %block = 1;
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    ss=subplot(254);
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    bar(mean_NFLI);ylim([-100 100])
    set(ss,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [~,P,~,~]=ttest(NFLI);temp(1,1)=P(1);
    text(1,60,sprintf('%1.3f\n',P(1)));title('performance and 3rd tone')
    ss=subplot(259);
    x=[1,2];
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    ylim([0,0.7])
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'});[~,P, ~] = ttest2(BothEar(:,1),BothEar(:,2));temp(2,1)=P(1);
    text(0.5,0.65,sprintf('%1.3f\n',P))
    
    % 5.When use all three criteria
    pool = 1:24;Takes = ones(1,24);Takes([4,5,19,20]) = 0;
    pool = nonzeros(pool .* Takes);pool=[0;pool];
    fprintf('using error, 3rd tone and RT, and pool is %s\n\r',sprintf('%d ',pool))
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [Perc, Dichotic] = DichoticErrorTone_RT(Output,percntiles(1),percntiles(2),1);
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    ss=subplot(255);
    mean_NFLI = mean(NFLI);
    e_NFLI = 1.96.*(std(NFLI) ./ sqrt(length(pool)-1));
    x = linspace(1,length(mean_NFLI),length(mean_NFLI));
    bar(mean_NFLI);ylim([-100 100])
    set(ss,'XTickLabel',{'both', 'right','left'},...
        'box','off','TickDir','out');hold on
    errorbar(x,mean_NFLI,e_NFLI,'go')
    [~,P,~,~]=ttest(NFLI);temp(1,1)=P(1);
    text(1,60,sprintf('%1.3f\n',P(1)));title('all three criteria')
    ss=subplot(2,5,10);
    x=[1,2];
    bar([1 2], mean(BothEar));hold on;eb = 1.96.*(std(BothEar,1)./sqrt(length(BothEar)-1));
    ylim([0,0.7])
    errorbar(x,mean(BothEar,1),eb,'*');
    set(ss,'XTickLabel',{'left','right'});[~,P, ~] = ttest2(BothEar(:,1),BothEar(:,2));temp(2,1)=P(1);
    text(0.5,0.65,sprintf('%1.3f\n',P))
    
end
%%
close all
for soundtype = condition
    temptemp = comP.(char(soundtype));
    figure;
plot(temptemp(1,:),temptemp(2,:),'*');hold on
xlabel('NFLI');ylabel('ear effect')
for ii = 1:length(temptemp)
    text(temptemp(1,ii),temptemp(2,ii),sprintf('%d',ii))
end
end
%% POE
clc;close all
clear POE
pool = 1:24;Takes = ones(1,24);Takes([4,5,19,20]) = 0;
pool = nonzeros(pool .* Takes);pool=[0;pool];
condition = {'hum','tone'};
for soundtype = condition
    sumPOE.(char(soundtype))=[0;0];
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [~,Dichotic]=DichoticErrorToneNo3(Output);
        POE.(char(soundtype)).(sprintf('sub%d',ii))=[Dichotic.LeftPOE;Dichotic.RightPOE];
        sumPOE.(char(soundtype))=sumPOE.(char(soundtype))+[Dichotic(1).LeftPOE;Dichotic(1).RightPOE];
        
    end
    meanPOE.(char(soundtype))=sumPOE.(char(soundtype))/length(pool);
end
%
for soundtype = condition
    figure;
    for ii = 1:length(pool)
        plot(POE.(char(soundtype)).(sprintf('sub%d',ii))(1,1),...
            POE.(char(soundtype)).(sprintf('sub%d',ii))(2,1),'*');hold on
        x=[0.5,0.5];y=[0,1];
        line(x,y);
        line(y,x);
        xlabel('left POE')
        ylabel('right POE')
        title(char(soundtype))
        text(0.2,0.8,'LEA')
        text(0.8,0.2,'REA')
        
    end
end






