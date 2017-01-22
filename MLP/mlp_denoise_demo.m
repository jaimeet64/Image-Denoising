%% MLP: Generate denoised image using MLP(Multi Layer Perception) technique from a noisy Image 
% Author: Jaimeet Patel
% Email : jpatel99@hawk.iit.edu
% Date  : 09/22/2016
% Description: This program takes a parameter file as the input. The
% parameter file specifies the folder, the header name of the input
% images, the start and end number of images, and the value of sigma 
% (std of noise). The input images must be grayscale. The program applies
% MLP technique to the noisy image to estimate the image.
% Estimated images are inside the root folder in a folder named MLP025.
% Note that input images names are of format headername_0000.ext

%% read parameteres
clc;
clear all;

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
sigma = params{2}(strcmp(params{1},'sigma')); sigma = sigma{1}; sigmaDouble = str2double(sigma); 

outputFolder = params{2}(strcmp(params{1},'outputFolder')); outputFolder = outputFolder{1};
%outputFolder = [rootFolder, '/MLP', sigma];
mkdir(outputFolder)

%% Read/convet input noisy image and estimates the the original image using BM3D Technique 

numImages = str2double(endNum) - str2double(startNum) + 1;

% read noisy image
for i = 1:numImages
    imageNum = sprintf('%04d',i-1);
    imageAddress = [rootFolder, inputFolder, '/', imageHeader, '_', imageNum, '.', imageExt];
    imageAddress_Ref = [rootFolder, inputFolder_Ref, '/', imageHeader_Ref, '_', imageNum, '.', imageExt];
    im_noisy= double(imread(imageAddress));
    im_clean=double(imread(imageAddress_Ref));
    
    
    % define some parameters for denoising
    model = {};
    % width of the Gaussian window for weighting output pixels
    model.weightsSig = 2;
    % the denoising stride. Smaller is better, but is computationally
    % more expensive.
    model.step = 3;
    
    % denoise
    fprintf('Starting to denoise...\n');
    tstart = tic;
    im_denoised = fdenoiseNeural(im_noisy, 25, model);
    telapsed = toc(tstart);
    fprintf('Done! Loading the weights and denoising took %.1f seconds\n',telapsed);
    
    %get PSNR values
     psnr_noisy = getPSNR(im_noisy, im_clean, 255);
     psnr_denoised = getPSNR(im_denoised, im_clean, 255);
     fprintf('PSNRs: noisy: %.2fdB, denoised: %.2fdB\n',psnr_noisy,psnr_denoised);
       
    % save the image
    MLP_result_Address= [outputFolder, '/',imageHeader,'_MLP', sigma, '_', imageNum, '.png'];
    imwrite(im_denoised/255, MLP_result_Address)
    
end


