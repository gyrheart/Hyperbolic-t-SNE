%% Download and unzip the data from: https://www.ebi.ac.uk/arrayexpress/files/E-MTAB-62/E-MTAB-62.processed.2.zip

%% This processing is slow, you may try other methods read the csv file to mat file.

clearvars
clc
raw_data = readtable('hgu133a_rma_okFiles_080619_MAGETAB.csv');
Sample = table2array(raw_data(2:end,2:end));
Data = cellfun(@str2double,Sample);
save('E_MTAB_62.mat','Data','-v7.3');

