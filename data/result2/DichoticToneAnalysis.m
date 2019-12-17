% This script contains the following functions:
% 1. General look at the subject performance and print the performance
% 2. Graph the raw data
% 3. Graph a t test of some subtraction
% 4. Analysis of errors. 
%%
clc
hum = [1 1 0 0 0 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0];
tone = [0 0 1 0 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 0 0 0 1];
condition = [{'hum'},{'tone'}];
pool = [1:23];% change accordingly
Takes = ones(1,23);
Takes([4,5,19,20]) = 0;
pool = nonzeros(pool .* Takes);
%pool = nonzeros(pool .* tone);
for ii = 1:length(pool)
for soundtype = condition
    load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
    [MatchRate,Dichotic] = DichoticErrorTone(Output);
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
    % print out the result on the command window
    fprintf('\r\nsubject %d doing %s condition',pool(ii), char(soundtype))
    fprintf(formatSpec1, [Dichotic(1).LEA,Dichotic(1).REA]*100, ...
        180-sum(nonzeros((Dichotic(1).correct))),180,NFLI(ii,1))
    fprintf(formatSpec2, [Dichotic(2).LEA,Dichotic(2).REA]*100, ...
        180-sum(nonzeros((Dichotic(2).correct))),180,NFLI(ii,2)-NFLI(ii,1))
    fprintf(formatSpec3, [Dichotic(3).LEA,Dichotic(3).REA]*100, ...
        180-sum(nonzeros((Dichotic(3).correct))),180 ,NFLI(ii,3)-NFLI(ii,1))
    BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
    RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
    LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
    Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
    Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
    Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
end
end
%% plot the result if we have more than 2 subjects

for soundtype = condition
    figure;
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate,Dichotic] = DichoticErrorTone(Output);
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
    end
    x=[1,2];
        set(gcf,'name',char(soundtype));
        ss=subplot(1,3,1);
        bar([1 2], mean(BothEar));hold on;eb = std(BothEar,1)./sqrt(length(BothEar)-1);
        errorbar(x,mean(BothEar,1),eb,'*')
        title(ss,'Both')

        ss=subplot(1,3,2);
        bar([1,2],mean(LeftEar));hold on;el = std(LeftEar,1) ./ sqrt(length(LeftEar)-1);
        errorbar(x,mean(LeftEar,1),el,'go')
        title(ss,'Left')
        
        ss=subplot(1,3,3);
        bar([1,2],mean(RightEar));hold on;er = std(RightEar,1) ./sqrt(length(RightEar)-1);
        errorbar(x,mean(RightEar,1),er,'r*')
        title(ss,'Right')

end
%%

for soundtype = condition
    
    disp(soundtype)
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate,Dichotic] = DichoticErrorTone(Output);
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
        [MatchRate,Dichotic] = DichoticErrorTone(Output);
        % a quantitative way to look if a subject is having a strong REA or LEA
        % if NFLI <0, then it is lEA
        % if NFLI >0, then it is REA
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        % This could be used to check if the subject is paying attention to
        % what they were told to pay attention
        FLgain(ii) = NFLI(ii,2)-NFLI(ii,1);
        FRgain(ii) = NFLI(ii,3)-NFLI(ii,1);
    end
    formatSpec1 = '\r\nBlock both\nLeft ear match %2.2f\nRight ear match %2.2f\nconfidence interval [%2.2f:%2.2f] \nNFLI is %2.2f';
    formatSpec2 = '\r\nBlock left\nLeft ear match %2.2f\nRight ear match %2.2f\nconfidence interval [%2.2f:%2.2f] \nFLgain is %2.2f';
    formatSpec3 = '\r\nBlock right\nLeft ear match %2.2f\nRight ear match %2.2f\nconfidence interval [%2.2f:%2.2f] \nFRgain is %2.2f\n';
    [h, p, ci, stat] = ttest2(BothEar(:,1), BothEar(:, 2));
    fprintf(formatSpec1, mean(BothEar)*100, ci,mean(NFLI(:,1)))
    [h, p, ci, stat] = ttest2(LeftEar(:,1), LeftEar(:, 2));
    fprintf(formatSpec2, mean(LeftEar)*100, ci,mean(NFLI(:,2))-mean(NFLI(:,1)))
    [h, p, ci, stat] = ttest2(RightEar(:,1), RightEar(:, 2));
    fprintf(formatSpec3, mean(RightEar)*100,ci,mean(NFLI(:,3))-mean(NFLI(:,1)))
    figure
    set(gcf,'name',char(soundtype));
    subplot(3,1,1);hist(NFLI(:,1));
    title('(REA-LEA)/(REA+LEA)')
    
    subplot(3,1,2);hist(FLgain);
    title('FL-NF')
    
    subplot(3,1,3);hist(FRgain);
    title('FR-NF')
end
%%
subplot(3,1,1);hist(NFLI(:,1));axis([0 1.2 0 15])
title('(REA-LEA)/(REA+LEA)')
%figure;hist(NFLI(:,2))
subplot(3,1,2);hist(FLgain);axis([0 1.2 0 15])
title('FL-NF')
%figure;hist(NFLI(:,3))
subplot(3,1,3);hist(FRgain);axis([0 1.2 0 15])
title('FR-NF')
%%

for soundtype = condition
    for ii = 1:length(pool)
        load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(ii)))
        [MatchRate,Dichotic] = DichoticErrorTone(Output);
        BothEar(ii,:) = [Dichotic(1).LEA,Dichotic(1).REA];
        RightEar(ii,:) = [Dichotic(2).LEA,Dichotic(2).REA];
        LeftEar(ii,:) = [Dichotic(3).LEA,Dichotic(3).REA];
        Overall.both(ii) = Dichotic(1).LEA + Dichotic(1).REA;
        Overall.Right(ii) = Dichotic(2).LEA + Dichotic(2).REA;
        Overall.Left(ii) = Dichotic(3).LEA + Dichotic(3).REA;
        [MatchRate,Dichotic] = DichoticErrorTone(Output);
        % a quantitative way to look if a subject is having a strong REA or LEA
        % if NFLI <0, then it is lEA
        % if NFLI >0, then it is REA
        [NFLI(ii,1),NFLI(ii,2),NFLI(ii,3)] = Dichotic.NFLI;
        % This could be used to check if the subject is paying attention to
        % what they were told to pay attention
        FLgain(ii) = NFLI(ii,2)-NFLI(ii,1);
        FRgain(ii) = NFLI(ii,3)-NFLI(ii,1);
    end
    figure
    set(gcf,'name','Both');
    hist(NFLI(:,1),15);hold on
    title(soundtype)
end
%% analysis of errors -- Basically it is originally from Adeen's ideas
soundtype = [{'hum'}];
store.hum = [];
sub_store = [];
% load the data and sort them
for  subjectNumber = 1:length(pool)
%subjectNumber = 2;
load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(subjectNumber)))
[~,Dichotic] = DichoticErrorTone(Output);

j = 1;%block both
sub(pool(subjectNumber)).index = pool(subjectNumber);
sub(pool(subjectNumber)).response = Dichotic(j).a;
store.hum = [store.hum; Dichotic(j).a];
sub_index = pool(subjectNumber)*ones(1,length(Dichotic(j).a));
sub_store = [sub_store,sub_index];
end
% map sort them
[idx.hum, map.hum] = grp2idx(num2str(store.hum(:,1:2)));
% print the data
soundtype = [{'hum'}];
disp(soundtype)

U = num2str(store.hum(:,1:2));

R = num2str(store.hum(:,3));
for ii = 1:length(map.hum)
    %t(i) = length(unique(sub_store(find(idx ==i))));
    [s, index] = sort(R(idx.hum ==ii));
    fprintf('%s\t\t%s\n\t\t%d\n',map.hum{ii},s,length(unique(sub_store(idx.hum ==ii))))
end
%% tone
soundtype = [{'tone'}];
store.tone = [];
sub_store = [];
% load and sort the data
for  subjectNumber = 1:pool
%subjectNumber = 2;
load(sprintf('Dichotic%sClassic_%d.mat',char(soundtype),pool(subjectNumber)))
[~,Dichotic] = DichoticErrorTone(Output);

j = 1;%block both
sub(subjectNumber).index = subjectNumber;
sub(subjectNumber).response = Dichotic(j).a;
store.tone = [store.tone; Dichotic(j).a];
sub_index = subjectNumber*ones(1,length(Dichotic(j).a));
sub_store = [sub_store,sub_index];
end
% map sort the data
[idx.tone, map.tone] = grp2idx(num2str(store.tone(:,1:2)));

% print the data
soundtype = [{'tone'}];
disp(soundtype)

U = num2str(store.tone(:,1:2));

R = num2str(store.tone(:,3));
for ii = 1:length(map.tone)
    %t(i) = length(unique(sub_store(find(idx ==i))));
    [s, index] = sort(R(idx.tone ==ii));
    fprintf('%s\t\t%s\n\t\t%d\n',map.tone{ii},s,length(unique(sub_store(idx.tone ==ii))))
end

%% show individual pattern
clc
U = num2str(store(:,1:2));

R = num2str(store(:,3));
for ii = 1:length(map)
    %t(i) = length(unique(sub_store(find(idx ==i))));
    [s, index] = sort(R(idx ==ii));
    fprintf('\n%s\t\t%s\n\t\t\n',map{ii},s);fprintf('%d\t',sort(index));
    fprintf('\n');
end