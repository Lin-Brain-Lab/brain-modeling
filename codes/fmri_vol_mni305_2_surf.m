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

for ii=101:291
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

                fn0=sprintf('%s/%s/analysis/%s.nii.gz',root_path,subject{subj_idx},file_stem{idx});
                if(exist(fn0))
                    fn1=sprintf('%s/%s/analysis/%s_%s-lh.mgh',root_path,subject{subj_idx},subject{subj_idx},file_stem{idx});
                    fn2=sprintf('%s/%s/analysis/%s_%s-rh.mgh',root_path,subject{subj_idx},subject{subj_idx},file_stem{idx});
                    eval(sprintf('!mri_vol2surf --icoorder 5 --fwhm 10 --src %s --srcreg %s --hemi lh --noreshape --out %s',fn0,file_register,fn1));
                    eval(sprintf('!mri_vol2surf --icoorder 5 --fwhm 10 --src %s --srcreg %s --hemi rh --noreshape --out %s',fn0,file_register,fn2));

                    brain_lh = MRIread(fn1);
                    fn3=sprintf('%s/%s/analysis/%s_%s-lh.stc',root_path,subject{subj_idx},subject{subj_idx},file_stem{idx});
                    stc=squeeze(brain_lh.vol); if(min(size(stc))==1) stc=stc'; end;
                    inverse_write_stc(stc,[0:brain_lh.nvoxels-1],0,TR.*1e3,fn3);

                    brain_rh = MRIread(fn2);
                    fn4=sprintf('%s/%s/analysis/%s_%s-rh.stc',root_path,subject{subj_idx},subject{subj_idx},file_stem{idx});
                    stc=squeeze(brain_rh.vol); if(min(size(stc))==1) stc=stc'; end;
                    inverse_write_stc(stc,[0:brain_rh.nvoxels-1],0,TR.*1e3,fn4);

                    %morphing
                    %fn_in=fn3;
                    %fn_out=sprintf('%s/%s/analysis/%s_2_%s_%s',root_path,subject{subj_idx},subject{subj_idx},target_subject,file_stem{idx});
                    %cmd=sprintf('!mne_make_movie --subject %s --stcin %s --morph %s --stc %s --%s --smooth 5', subject{subj_idx}, fn_in, target_subject, fn_out, 'lh');
                    %eval(cmd);

                    %fn_in=fn4;
                    %fn_out=sprintf('%s/%s/analysis/%s_2_%s_%s',root_path,subject{subj_idx},subject{subj_idx},target_subject,file_stem{idx});
                    %cmd=sprintf('!mne_make_movie --subject %s --stcin %s --morph %s --stc %s --%s --smooth 5', subject{subj_idx}, fn_in, target_subject, fn_out, 'rh');
                    %eval(cmd);

                    %eval(sprintf('!rm %s %s %s %s',fn1,fn2,fn3,fn4));
		    eval(sprintf('!rm %s %s',fn1,fn2));
                end;
            else
                fprintf('[%s] and [%s] existed!\n',fn_out1, fn_out2);
            end;
        end;
    end;
end;

