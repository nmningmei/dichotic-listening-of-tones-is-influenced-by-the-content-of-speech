function [ correctP, Dichotic ] = DichoticErrorTone_toneExcluded(Output,lower,upper,tokens)
correctP = zeros(3,2);
for block = 1:length(Output)
RT = Output(block).RT;
Leftactual = Output(block).Left';
responses = str2num(Output(block).response');
Rightactual = Output(block).Right';
tempcell = Output(block).Permutations;
for i=1:length(tokens)
tone = tokens(i);
I = cellfun(@(x) find(x==tone), tempcell, 'UniformOutput', false);
kk = cellfun('isempty',I);
Leftactual(kk == 0) = [];
responses(kk==0) = [];
Rightactual(kk==0) = [];
tempcell(kk==0) =[];
RT(kk==0) = [];
end
outlierIndex = RT <lower | RT > upper;
Leftactual = Leftactual(~outlierIndex);
responses = responses(~outlierIndex);
Rightactual = Rightactual(~outlierIndex);
LrRMat = [Leftactual,responses,Rightactual];

Correct(block,:) = responses == Rightactual | responses ==Leftactual;
LeftCorrect(block,:) = sum(responses ==Leftactual)/length(responses);
RightCorrect(block,:) = sum(responses == Rightactual)/length(responses);
correctP(block,:) = [LeftCorrect(block,:),RightCorrect(block,:)];
LeftError(block,:) = sum(responses ~= Leftactual)/length(responses);
RightError(block,:)= sum(responses ~= Rightactual)/length(responses);
for tone = 1:4
    cnt = 1;
    KK = [];
    for PR = 1:length(responses)
        if ismember(tone, Output(block).Permutations{PR})
            KK = [KK,cnt];
        end
        cnt = cnt +1;
    end
    
end

switch Output(block).Order
            case 'both', this = 1;
            case 'right', this =2;
            case 'left', this = 3;
end
Dichotic(this).KK = KK;
Dichotic(this).LrRMat= LrRMat;
Dichotic(this).LeftActual = Leftactual;
Dichotic(this).RightActual = Rightactual;
Dichotic(this).response = responses;
Dichotic(this).correct = Correct(block,:);
Dichotic(this).block = Output(block).Order;
Dichotic(this).REA = RightCorrect(block,:);
Dichotic(this).LEA = LeftCorrect(block,:);
Dichotic(this).REA = RightCorrect(block,:)/(LeftCorrect(block,:)+RightCorrect(block,:));
Dichotic(this).LEA = LeftCorrect(block,:)/(LeftCorrect(block,:)+RightCorrect(block,:));
Dichotic(this).LeftPOE = LeftError(block,:);
Dichotic(this).RightPOE = RightError(block,:);
Dichotic(this).LeftCorrect = LeftCorrect(block,:);
Dichotic(this).RightCorrect = RightCorrect(block,:);
Dichotic(this).LeftPOE = LeftError(block,:)/(LeftError(block,:)+RightError(block,:));
Dichotic(this).RightPOE = RightError(block,:)/(LeftError(block,:)+RightError(block,:));
Dichotic(this).in_index = find(~Correct(block,:));
Dichotic(this).errors = [Dichotic(this).LeftActual(~Correct(block,:))';...
    Dichotic(this).RightActual(~Correct(block,:))';...
    Dichotic(this).response(~Correct(block,:))']';
Dichotic(this).NFLI = (Dichotic(this).REA - Dichotic(this).LEA)./...
    (Dichotic(this).REA + Dichotic(this).LEA)*100;
end


end

