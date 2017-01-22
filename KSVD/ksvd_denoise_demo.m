%% KSVD: Estimate image using KSVD technique from a noisy Image
% Author: Jaimeet Patel
% Email : jpatel99@hawk.iit.edu
% Date  : 09/04/2016
% Description: This program takes a parameter file as the input. The
% parameter file specifies the folder, the header name of the input
% images, the start and end number of images, and the value of sigma
% (std of noise). The input images must be grayscale. The program applies
% KSVD technique to the noisy image to estimate the image.
% The input and output PSNR are compared, and the
% trained dictionary is displayed.
% Estimated images are inside the root folder in a folder named KSVD025.
% Note that input images names are of format headername_0000.ext.

%% read parameteres

function ksvd_denoise_demo
cd;
paramFile = 'method_params.txt';
fid = fopen(paramFile);
params = textscan(fid, '%[^= ]%*[= ]%s', 'CommentStyle', '%');
fclose(fid);

rootFolder = params{2}(strcmp(params{1},'rootFolder')); rootFolder = rootFolder{1};
inputFolder = params{2}(strcmp(params{1},'inputFolder')); inputFolder = inputFolder{1};
imageHeader = params{2}(strcmp(params{1},'imageHeader')); imageHeader = imageHeader{1};
inputFolder_Ref = params{2}(strcmp(params{1},'inputFolder_Ref')); inputFolder_Ref = inputFolder_Ref{1};
imageHeader_Ref = params{2}(strcmp(params{1},'imageHeader_Ref')); imageHeader_Ref = imageHeader_Ref{1}; 

imageExt = params{2}(strcmp(params{1},'imageExt')); imageExt = imageExt{1};
startNum = params{2}(strcmp(params{1},'startNum')); startNum = startNum{1};
endNum = params{2}(strcmp(params{1},'endNum')); endNum = endNum{1};

sigma = params{2}(strcmp(params{1},'sigma'));sigma = sigma{1};
sigmaDouble = str2double(sigma);

blocksize= params{2}(strcmp(params{1},'blocksize'));blocksize = blocksize;
blocksizeDouble=str2double(blocksize)

dictsize = params{2}(strcmp(params{1},'dictsize'));dictsize = dictsize;
dictsizeDouble=str2double(dictsize)

trainnum = params{2}(strcmp(params{1},'trainnum'));trainnum = trainnum;
trainnumDouble=str2double(trainnum)

iternum= params{2}(strcmp(params{1},'iternum'));iternum = iternum;
iternumDouble=str2double(iternum)

    
outputFolder = params{2}(strcmp(params{1},'outputFolder')); outputFolder = outputFolder{1};
%outputFolder= [rootFolder, '/KSVD', sigma];
mkdir(outputFolder)

outputFolder_Dict= [rootFolder, '/KSVD_Dict', sigma];
mkdir(outputFolder_Dict)

numImages = str2double(endNum) - str2double(startNum) + 1;

% read noisy image
for i = 1:numImages
    
    % read one image
    imageNum = sprintf('%04d',i-1);
    imageAddress = [rootFolder, inputFolder, '/', imageHeader, '_', imageNum, '.', imageExt];
    im_noisy=mat2gray(imread(imageAddress));
    inputImage = im_noisy.*255;
    imageAddress_Ref = [rootFolder, inputFolder_Ref, '/', imageHeader_Ref, '_', imageNum, '.', imageExt];
    im_noisy= double(imread(imageAddress));
    im_clean=double(imread(imageAddress_Ref));
    
 
    %% set parameters %%
    imnoise=double(inputImage);
    params.x = imnoise;
    params.blocksize=blocksizeDouble;
    params.dictsize=dictsizeDouble;  
    params.sigma = sigmaDouble;
    params.maxval = 255;
    params.trainnum=trainnumDouble;
    params.iternum=iternumDouble; 
    params.memusage = 'high';
    
    % denoise!
    disp('Performing K-SVD denoising...');
    [im_denoised, dict] = ksvddenoise(params);
    

    % save results %
    dictimg = showdict(dict,[1 1]*params.blocksize,round(sqrt(params.dictsize)),round(sqrt(params.dictsize)),'lines','highcontrast');
    dict=(imresize(dictimg,2,'nearest'));
    
%     figure
%     imshow(dict)
%     figure; imshow(im/params.maxval); 
    KSVD_result_Address= [outputFolder,'/',imageHeader,'_KSVD', sigmaDouble, '_', imageNum, '.png'];
    imwrite(im_denoised./255, KSVD_result_Address);  
    KSVD_result_Address_Dict= [outputFolder_Dict, '/',imageHeader,'_KSVD_Dict', sigmaDouble, '_', imageNum, '.png'];
    imwrite(dict, KSVD_result_Address_Dict);
end