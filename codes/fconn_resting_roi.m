close all; clear all;

data_path='/space_lin1/quanta';

fstem={
	'ses-01_task-rest_space-MNI152NLin2009cAsym_desc-preproc_bold';
};

file_annot={
%    '/Applications/freesurfer/subjects/fsaverage/label/lh.aparc.a2009s.annot',    '/Applications/freesurfer/subjects/fsaverage/label/rh.aparc.a2009s.annot';
	'/usr/local/freesurfer/7.1.0-1/subjects/fsaverage/label/lh.aparc.a2009s.annot', '/usr/local/freesurfer/7.1.0-1/subjects/fsaverage/label/lh.aparc.a2009s.annot';
    };

for annot_idx=1:size(file_annot,1)
    for annot_hemi_idx=1:2
        [vertices{annot_idx,annot_hemi_idx} label{annot_idx,annot_hemi_idx} ctab{annot_idx,annot_hemi_idx}] = read_annotation(file_annot{annot_idx,annot_hemi_idx});
    end;
end;

TR=2.0; %second

n_dummy=0;
flag_gavg=0;

subject='';
for d_idx=1:293
    subject{d_idx}=sprintf('sub-%04d',d_idx);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f_idx=1:length(fstem)
    valid_subj_idx=[];
    for d_idx=1:length(subject)
        fprintf('[%s]...(%04d|%04d)....\r',subject{d_idx},d_idx,length(subject));
        
        roi=[];
        STC=[];
        for hemi_idx=1:2
            switch hemi_idx
                case 1
                    hemi_str='lh';
                case 2
                    hemi_str='rh';
            end;
            
            fn=sprintf('%s/%s/analysis/%s_%s-%s.stc',data_path,subject{d_idx},subject{d_idx},fstem{f_idx},hemi_str);
            if(exist(fn))
                [stc{hemi_idx},v{hemi_idx},d0,d1,timeVec]=inverse_read_stc(fn);
                
                %remove dummy scans
                stc{hemi_idx}(:,1:n_dummy)=[];
                stc{hemi_idx}(:,end-n_dummy+1:end)=[];
                
                STC=cat(1,STC,stc{hemi_idx});
                flag_fe=1;
            else
                flag_fe=0;
            end;
        end;
        if(flag_fe)
            
            valid_subj_idx=cat(1,valid_subj_idx,d_idx);
            
            fn=sprintf('%s/analysis/%s_resting.mat',data_path,subject{d_idx});
            if(exist(fn))
                D_reg=[];
                load(fn);
                D_reg(:,1)=regressor_ventricle(1:end-1);
                D_reg(:,2)=regressor_wm(1:end-1);
                D_reg(1:n_dummy,:)=[];
                D_reg(end-n_dummy+1:end,:)=[];
            else
                D_reg=[];
            end;
            
            %remove global mean
            D=ones(size(STC,2),1);
            if(~isempty(D_reg))
                D=cat(2,D,D_reg);
            end;
            if(flag_gavg);
                D=cat(2,D,mean(STC,1)');
            end;
            STC=(STC'-D*(inv(D'*D)*D'*STC')).';
            
            stc_hemi{1}=STC(1:length(v{1}),:);
            stc_hemi{2}=STC(length(v{1})+1:end,:);
            
            for hemi_idx=1:2                
                for annot_idx=1:size(ctab,1)
                    for roi_idx=2:size(ctab{annot_idx,hemi_idx}.table,1)
                        roi_vertices=vertices{annot_idx,hemi_idx}(find(label{annot_idx,hemi_idx}==ctab{annot_idx,hemi_idx}.table(roi_idx,5)));
                        
                        [dummy, iidx]=intersect(v{hemi_idx},roi_vertices);
                        
			%these are ROI average and std
                        ROI_avg(roi_idx,:,hemi_idx,annot_idx)=mean(stc_hemi{hemi_idx}(iidx,:),1);
                        ROI_std(roi_idx,:,hemi_idx,annot_idx)=std(stc_hemi{hemi_idx}(iidx,:),0,1);
                    end;
                end;
            end;
            
            
            %%% do your analysis for each subject here ....
            
           
	    ROI_avg(1,:,:)=[]; 
            tmp=permute(ROI_avg,[2 1 3]);
            tmp=reshape(tmp,[size(tmp,1) size(tmp,2)*size(tmp,3)]);
            fconn{f_idx}(:,:,d_idx)=corrcoef(tmp);


            
            %%% end of subject-wise analysis.....
        end;
    end;
    
    fprintf('\n');

end;
save fconn_resting_roi.mat fconn
