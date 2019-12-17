function [ correctP, Dichotic ] = DichoticErrorTone_RT(Output,lower,upper,flag)
correctP = zeros(3,2);
for block = 1:length(Output)
outlierIndex = Output(block).RT < lower | Output(block).RT > upper; 
Leftactual = Output(block).Left';
Leftactual = Leftactual(~outlierIndex);
responses = str2num(Output(block).respond');
responses = responses(~outlierIndex);
Rightactual = Output(block).Right';
Rightactual = Rightactual(~outlierIndex);
LrRMat = [Leftactual,responses,Rightactual];
if flag == 1
tone = 3;
I = cellfun(@(x) find(x==tone), Output(block).Permutations, 'UniformOutput', false);
kk = cellfun('isempty',I);
kk = kk(~outlierIndex);
Leftactual(kk == 0) = [];
responses(kk==0) = [];
Rightactual(kk==0) = [];
end
Correct{block,:} = responses == Rightactual | responses ==Leftactual;
LeftCorrect{block,:} = sum(responses ==Leftactual)/length(responses);
RightCorrect{block,:} = sum(responses == Rightactual)/length(responses);
correctP(block,:) = [LeftCorrect{block,:},RightCorrect{block,:}];

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
Dichotic(this).correct = Correct{block,:};
Dichotic(this).block = Output(block).Order;
Dichotic(this).REA = RightCorrect{block,:};
Dichotic(this).LEA = LeftCorrect{block,:};
Dichotic(this).in_index = find(~Correct{block,:});
Dichotic(this).errorterms = [Dichotic(this).LeftActual((~Correct{block,:}))';...
    Dichotic(this).RightActual((~Correct{block,:}))';...
    Dichotic(this).response((~Correct{block,:}))']';
Dichotic(this).NFLI = (Dichotic(this).REA - Dichotic(this).LEA)./...
    (Dichotic(this).REA + Dichotic(this).LEA)*100;
end


end