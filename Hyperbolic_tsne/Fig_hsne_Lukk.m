%% Reproduce the hsne embedding results in Fig.6C. 

% Here you can load the data and directly get the plots, you can also uncomment the
% codes and run the results yourself

% To load the E_MTAB_62.mat file, you need to download and transform the
% data first using the code in ../Saved_data/SaveLukkData.m

%%
clc
clearvars
addpath('../Saved_data/')
addpath('../Hyperbolic_functions/')
%%
% load E_MTAB_62 Data
% select_data = Data';

%% Run multiple repeats of h-SNE

% learn_rate = 1;
% ydims = 2;
% repeats = 3;
% record_loss = zeros(repeats,1);
% lambda_screen = 8; % This is the parameter used in the manuscript
% R_init_screen = 1; % This is the parameter used in the manuscript
% options.MaxIter = 1.5e3;
% 
% for count_lambda = 1:length(lambda_screen)
%     lambda = lambda_screen(count_lambda);
%     
% for count_R_init = 1:length(R_init_screen)
%     R_init = R_init_screen(count_R_init);
%     min_loss = 1e1;
%     for count_repeat = 1:repeats
%         disp(count_repeat)
%         [pos_geo, loss]= fHTSNE(select_data,lambda,'Algorithm','exact', ...,
%                 'InitialR',R_init,'geometry','native','Options',options);
%         
%         disp(loss)
%         record_pos_geo(count_repeat,:,:) = pos_geo;
%         save(['LukkHTSNEScreen_opt_temp','.mat'],'record_pos_geo');
%     end
% end
% end
% save(['LukkHTSNEScreen_opt','.mat'],'record_pos_geo');


%% Get cell lables 
filename = 'E-MTAB-62.sdrf.txt';
Labels = tdfread(filename);
markersize = 3.5;

label_name = fieldnames(Labels);
GroupName1 = Labels.Factor_Value0x5B6_meta0x2Dgroups0x5D;
[GroupLabelTrim1, label_index1] = fGroupLabelTrim(GroupName1);
colors1 = hsv(length(unique(GroupLabelTrim1)));

GroupName2 = Labels.Characteristics0x5B4_meta0x2Dgroups0x5D;
[GroupLabelTrim2, label_index2] = fGroupLabelTrim(GroupName2);
colors2 = hsv(length(unique(GroupLabelTrim2)));

GroupName3 = Labels.Characteristics0x5B15_meta0x2Dgroups0x5D;
[GroupLabelTrim3, label_index3] = fGroupLabelTrim(GroupName3);
colors3 = hsv(length(unique(GroupLabelTrim3)));

%% h-tSNE visualization with three types of lables
clc
gray_idx = [1,2,3,6,7,8,10,11,12,14,15];
gray_color = [1,1,1]*0.75;
colors = [255,0,0;
    205,102,0;
    200,200,0;
    255,204,0;
    0,255,0;
    0,130,0;
    0,180,100;
    0,205,255;
    0,255,255;
    0,102,155;
    0,0,255;
    120,0,255;
    255,0,255;
    180,0,220;
    120,0,102]/255;
cluster_id = [4,5,9,13];

markersize = 3;
hFig = figure(2);
set(hFig,'units','centimeters','position',[0 0 18 6])

load LukkHTSNE_Lmd8_opt_pos opt_pos

% load LukkHTSNEScreen_opt record_pos_geo
% [repeats,N,d] = size(record_pos_geo);
% opt_pos = reshape(record_pos_geo(1,:,:),N,d);

opt_pos(:,1) = tanh(opt_pos(:,1)/2);
Y_hyper_cart = fPolar2Cart(opt_pos);
subaxis(1,3,1,'Spacing',0.0,'Padding',0.005,'Margin', 0.00,'MarginTop',0.1);
ftessellation_7_3
hold on
gscatter(Y_hyper_cart(label_index3,1),Y_hyper_cart(label_index3,2),GroupLabelTrim3',colors3,[],markersize,'off') 
hold off
title('15 types')

subaxis(1,3,2,'Spacing',0.0,'Padding',0.005,'Margin', 0.00,'MarginTop',0.1);

ftessellation_7_3
hold on
gscatter(Y_hyper_cart(label_index1,1),Y_hyper_cart(label_index1,2),GroupLabelTrim1',colors1,[],markersize,'off') 
hold off
title('hematopoietic')

subaxis(1,3,3,'Spacing',0.0,'Padding',0.005,'Margin', 0.00,'MarginTop',0.1);
ftessellation_7_3
hold on
gscatter(Y_hyper_cart(label_index2,1),Y_hyper_cart(label_index2,2),GroupLabelTrim2',colors2,[],markersize,'off') 
hold off
title('Malignancy')
