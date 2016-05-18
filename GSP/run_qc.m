
% IN.ANAT.(SUBJECT) (string) the file name of an individual T1 volume (in stereotaxic space).
%   Labels SUBJECT are arbitrary but need to conform to matlab's specifications for
%   field names.
% IN.FUNC.(SUBJECT) (string) the file name of an individual functional volume (in stereotaxic space)
%   Labels SUBJECT need to be consistent with IN.ANAT.
% IN.TEMPLATE   (string) the file name of the template used for registration in stereotaxic space.
% OPT.FOLDER_OUT (string) where to generate the outputs.
% OPT.COORD       (array N x 3) Coordinates for the figure. The default is:
%                               [-30 , -65 , -15 ;
%                                  -8 , -25 ,  10 ;
%                                 30 ,  45 ,  60];
% OPT.PSOM (structure) options for PSOM. See PSOM_RUN_PIPELINE.
% OPT.FLAG_VERBOSE (boolean, default true) if true, verbose on progress.
% OPT.FLAG_TEST (boolean, default false) if the flag is true, the pipeline will
%   be generated but no processing will occur.

addpath(genpath('/Users/Clara/GitHub/qc_fmri_preprocess'))
path_preprocess = '/Users/Clara/Desktop/Chuv/Mni_Crigum/GSP/fmri_preprocess/anat';
list_subject = dir(path_preprocess);
list_subject = {list_subject.name};
list_subject = list_subject(~ismember(list_subject,{'.','..','template_aal.mnc.gz','template_fmri_stereo.mnc.gz',}));
in = struct();
for ii = 1:length(list_subject)
    subject = list_subject{ii};
    in.anat.(subject) = [path_preprocess filesep subject filesep 'anat_' subject '_nuc_stereolin.mnc.gz'];
    in.func.(subject) = [path_preprocess filesep subject filesep 'func_' subject '_mean_stereonl.mnc.gz'];
end
in.template = '/Users/Clara/GitHub/Niak/template/mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz';
opt.folder_out = '/Users/Clara/Desktop/Chuv/Mni_Crigum/GSP/outputs_QC';
niak_pipeline_qc_fmri_preprocess(in,opt)
