
close all;
clear all;
clc;

foldpath='E:\科研\图像数据库\berkelyimagedatase\BSDS300\300\'; % fold path of image database
gtpath='E:\科研\图像数据库\berkelyimagedatase\BSDS300\gt\all\'; % fold path of ground truth
resultPath='E:\科研\正在调试的代码\cosegment_HCRF_CLUST\img\result\'; %path of segmentation result

evalFilepath=fullfile(resultPath,'300.txt');
fid=fopen(evalFilepath,'w+');
fprintf(fid,'%8s:  %6s   %6s   %6s   %6s    %6s\n', 'image', 'PRI',   'VOI', 'GcE','BDE','time');

totalPRI=0;
totalVoI=0;
totalGCE=0;
totalBDE=0;
totalTime=0;
fileStaus=dir(fullfile(foldpath,'*.jpg'));
totalnum=length(fileStaus);
for i=1:totalnum
    imgName=fileStaus(i).name;
    [~,fileName,fileExt]=fileparts(imgName);
    img=imread(fullfile(foldpath,imgName));
    %      find out the K of this image
    load(fullfile(gtpath,fileName));
    K=realmax('double');
    for j=1:length(groundTruth)
        gtk=max(groundTruth{j}.Segmentation(:));
        if (K>gtk)
            K=gtk;
        end
    end
 
    timeVal=tic;    
    label=MyHMRFFCM_Demo(img,K);    
    elapseTime=toc(timeVal);   
    
    totalTime=totalTime+elapseTime;
   
     imwrite(label./max(label(:)),fullfile(resultPath,['segResult\',fileName,'.bmp']));
     showImg=show_seg(img,label,100,0);
     imwrite(showImg,fullfile(resultPath,['segResult\',fileName,'.jpg']));
    %      evaluate the segmentation result
    out_vals=evaluteSegResult(label,groundTruth);
    fprintf(fid,'%8s:  %4f   %4f   %4f   %4f\n', fileName, out_vals.PRI,  out_vals.VoI, out_vals.GCE,out_vals.BDE);
    totalPRI=totalPRI+out_vals.PRI;
    totalVoI=totalVoI+ out_vals.VoI;
    totalGCE=totalGCE+out_vals.GCE;
    totalBDE=totalBDE+out_vals.BDE;
    clear gt_imgs;
    
end
totalPRI=totalPRI/totalnum;
totalVoI=totalVoI/totalnum;
totalGCE=totalGCE/totalnum;
totalBDE=totalBDE/totalnum;
totalTime=totalTime/totalnum;
fprintf(fid,'%8s:  %4f   %4f   %4f   %4f    %4f\n', 'Average',totalPRI,  totalVoI, totalGCE,totalBDE,totalTime);
fclose(fid);
