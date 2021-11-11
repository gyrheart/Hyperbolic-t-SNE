# Hyperbolic t-SNE
Performing t-SNE embedding in hyperbolic space to preserve global hyperbolic structure of data.

Saved_data: this folder contains all the saved .mat files. The Lukk’s dataset was not included here and needs to be downloaded from https://www.ebi.ac.uk/arrayexpress/files/E-MTAB-62/E-MTAB-62.processed.2.zip. After downloading and unzipping the file, go to /Saved_data/SaveLukkData.m and follow the commands to transform and save the data as .mat format.

Hyperbolic_functions: this folder contains all the functions required to run the codes.

Hyperbolic_tsne: this folder contains the code(Fig_mds_Lukk.m) that reproduces Figure 6C in the manuscript [1]. Note that the codes are commented so that you can directly generate the figures. If you want to run the hyperbolic t-SNE functions, just uncomment the codes.

# Reference
[1] Yuansheng Zhou and Tatyana Sharpee. Hyperbolic geometry of gene expression. iScience 24 (3), 102225, 2021.




