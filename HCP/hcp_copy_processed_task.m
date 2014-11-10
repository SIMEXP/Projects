% copy unprocessed HCP task data from connectome in box hard drives to a remote server 
for nn = 2:2 
    path_data = ['/media/S500-' num2str(nn) '-20140805/'];
    path_out  = '/media/database8/HCP/';
    server    = 'peuplier';
    user_name = 'yassinebha';

    % Grab subjects list
    list_subject_raw = dir(path_data);
    nb_subject = 0;
    for num_ss = 1:length(list_subject_raw)
        if ~ismember(list_subject_raw(num_ss).name,{'.','..'}) && exist([ path_data list_subject_raw(num_ss).name filesep 'MNINonLinear/' ],'dir')
          nb_subject = nb_subject + 1;
          sprintf('Adding subject %s', list_subject_raw(num_ss).name)
          list_subject{nb_subject} = list_subject_raw(num_ss).name;     
        else 
          sprintf('subject %s is discarded', list_subject_raw(num_ss).name)
        end  
    end

    % Rsync folders
    for nn=1:length(list_subject);
    sprintf('Syncing subjet %s ', list_subject{nn})
    system(['ssh ' user_name '@' server ' mkdir -p ' path_out list_subject{nn} filesep 'MNINonLinear/']);
    system(['rsync -ravv -f"- fsaverage_LR32k/" -f"- Native/" -f"- xfms/" -f"- rfMRI_*/" -f"- *.gii"  -f"- *.nii" ' path_data list_subject{nn} filesep 'MNINonLinear/ ' user_name '@' server ':' path_out list_subject{nn} filesep 'MNINonLinear/']);   
    end

end
