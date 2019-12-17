function [ correctP, Dichotic ] = DichoticErrorToneNo3(Output)
correctP = zeros(3,2);
for block = 1:length(Output)
Leftactual = Output(block).Left';
responses = str2num(Output(block).respond');
Rightactual = Output(block).Right';
LrRMat = [Leftactual,responses,Rightactual];
tone = 3;
I = cellfun(@(x) find(x==tone), Output(block).Permutations, 'UniformOutput', false);
kk = cellfun('isempty',I);
Leftactual(kk == 0) = [];
responses(kk==0) = [];
Rightactual(kk==0) = [];

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
Dihcotic(this).LrRMat= LrRMat;
Dichotic(this).LeftActual = Leftactual;
Dichotic(this).RightActual = Rightactual;
Dichotic(this).response = responses;
Dichotic(this).correct = Correct(block,:);
Dichotic(this).block = Output(block).Order;
Dichotic(this).REA = RightCorrect(block,:);
Dichotic(this).LEA = LeftCorrect(block,:);
Dichotic(this).LeftPOE = LeftError(block,:);
Dichotic(this).RightPOE = RightError(block,:);
Dichotic(this).in_index = find(~Correct(block,:));
Dichotic(this).a = [Dichotic(this).LeftActual(find(~Correct(block,:)))';...
    Dichotic(this).RightActual(find(~Correct(block,:)))';...
    Dichotic(this).response(find(~Correct(block,:)))']';
Dichotic(this).NFLI = (Dichotic(this).REA - Dichotic(this).LEA)./...
    (Dichotic(this).REA + Dichotic(this).LEA)*100;
end


end