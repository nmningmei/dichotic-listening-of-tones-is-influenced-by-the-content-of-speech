function [ correctP, Dichotic ] = DichoticErrorTone(Output)
correctP = zeros(3,2);
for ii = 1:length(Output)
Leftactual = Output(ii).Left';
responses = str2num(Output(ii).response');
Rightactual = Output(ii).Right';
LrRMat = [Leftactual,responses,Rightactual];


Correct(ii,:) = responses == Rightactual | responses ==Leftactual;
LeftCorrect(ii,:) = sum(responses ==Leftactual)/length(responses);
RightCorrect(ii,:) = sum(responses == Rightactual)/length(responses);
correctP(ii,:) = [LeftCorrect(ii,:),RightCorrect(ii,:)];

for tone = 1:4
    cnt = 1;
    KK = [];
    for PR = 1:length(responses)
        if ismember(tone, Output(ii).Permutations{PR})
            KK = [KK,cnt];
        end
        cnt = cnt +1;
    end
    
end

switch Output(ii).Order
            case 'both', this = 1;
            case 'right', this =2;
            case 'left', this = 3;
end
Dichotic(this).KK = KK;
Dihcotic(this).LrRMat= LrRMat;
Dichotic(this).LeftActual = Leftactual;
Dichotic(this).RightActual = Rightactual;
Dichotic(this).response = responses;
Dichotic(this).correct = Correct(ii,:);
Dichotic(this).block = Output(ii).Order;
Dichotic(this).REA = RightCorrect(ii,:);
Dichotic(this).LEA = LeftCorrect(ii,:);
Dichotic(this).in_index = find(~Correct(ii,:));
Dichotic(this).a = [Dichotic(this).LeftActual(find(~Correct(ii,:)))';...
    Dichotic(this).RightActual(find(~Correct(ii,:)))';...
    Dichotic(this).response(find(~Correct(ii,:)))']';
Dichotic(this).NFLI = (Dichotic(this).REA - Dichotic(this).LEA)./...
    (Dichotic(this).REA + Dichotic(this).LEA)*100;
end


end