close all; clear all;

subject={
};


file_stem={
'ses-01_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold';
};

output_fstem={
    'ses-01_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold';
    };

TR=2.0; %second

target_subject='fsaverage';

root_path='/space_lin1/quanta/';

setenv('SUBJECTS_DIR','/space_lin1/quanta/subjects');

subject={
    'sub-0100';
    };

for ii=1:291
	subject{ii}=sprintf('sub-%04d',ii);
end;
%subject='';
%d=textread('subject_list.txt');
%d=d(1:100);
%for d_idx=1:length(d)
%        subject{d_idx}=num2str(d(d_idx));
%end;

mni152=MRIread(sprintf('%s/scripts/%s',root_path,'MNI152_T1_2mm.nii.gz'));
mni305=MRIread(sprintf('%s/scripts/%s',root_path,'mni305.cor.subfov2.mgz'));

xfm=etc_read_xfm('file_xfm',sprintf('%s/scripts/%s',root_path,'mni152.mni305.cor.subfov2.dat'));


for subj_idx=1:length(subject)

% 
%     etc_render_fsbrain('vol',mni305 ,'overlay_vol',fmri_mni305,'vol_reg',(xfm0));
 
    file_register=sprintf('%s/scripts/mni305_register.dat',root_path);

    if(~exist(sprintf('%s/%s/analysis',root_path,subject{subj_idx})))
        eval(sprintf('!mkdir %s/%s/analysis',root_path,subject{subj_idx}));
    end;


    if(exist(sprintf('%s/%s',root_path,subject{subj_idx})))
        for idx=1:length(file_stem)
            %do this outside matlab....
            %make sure freesurfer environment, register file, and subjects directory are all set.
            fn_out1=sprintf('%s/%s/analysis/%s_2_%s_%s-lh.stc',root_path,subject{subj_idx},subject{subj_idx},target_subject,file_stem{idx});
            fn_out2=sprintf('%s/%s/analysis/%s_2_%s_%s-rh.stc',root_path,subject{subj_idx},subject{subj_idx},target_subject,file_stem{idx});


            if(~exist(fn_out1)&&~exist(fn_out2))

                fn0=sprintf('%s/%s/func/%s_%s.nii.gz',root_path,subject{subj_idx},subject{subj_idx},file_stem{idx});
                if(exist(fn0))

                    fmri=MRIread(fn0); %fMRI data in MNI152 space

                    fmri_mni152=etc_MRIvol2vol(fmri,mni152,eye(4));
                    fmri_mni305=etc_MRIvol2vol(fmri_mni152,mni305,inv(xfm));

                    fn=sprintf('%s/%s/analysis/%s.nii.gz',root_path,subject{subj_idx},output_fstem{idx})
                    MRIwrite(fmri_mni305,fn);

                    
                end;
            else
                fprintf('[%s] and [%s] existed!\n',fn_out1, fn_out2);
            end;
        end;
    end;
end;

