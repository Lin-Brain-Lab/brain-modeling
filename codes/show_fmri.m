close all; clear all;

mni305=MRIread('/Applications/freesurfer/average/mni305.cor.subfov2.mgz');

xfm=etc_read_xfm('file_xfm','/Applications/freesurfer/average/mni152.mni305.cor.subfov2.dat');
xfm0=etc_read_xfm('file_xfm','/Applications/freesurfer/average/mni305.cor.subfov2.reg');


mni152=MRIread('MNI152_T1_2mm.nii.gz');

fmri=MRIread('sub-0046_ses-01_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz'); %fMRI data in MNI152 space

fmri_mni152=etc_MRIvol2vol(fmri,mni152,eye(4));
fmri_mni305=etc_MRIvol2vol(fmri_mni152,mni305,inv(xfm));

etc_render_fsbrain('vol',mni305 ,'overlay_vol',fmri_mni305,'vol_reg',(xfm0));
