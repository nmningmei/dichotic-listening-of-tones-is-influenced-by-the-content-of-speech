clear all;clc;close all
pool = 1:23;soundtype={'hum','tone'};
for i =1:2
for sub =pool
    try
   filename(sub)=dir(sprintf('Dichotic%sClassic_%d.mat',soundtype{i},sub));
   load(filename(sub).name);
   r(sub,:) = str2num(Output(3).respond');
    end
end
figure(i)
hist(r(:))
title(soundtype{i})

end