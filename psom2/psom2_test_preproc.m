clear

%% Check the demoniak data
path_test.demoniak = '';
if isempty(path_test.demoniak)
    % Grab the demoniak dataset    
    [status,err,data_demoniak] = niak_wget(struct('type','data_test_niak_mnc1'));
    path_test.demoniak = data_demoniak.path;
    if status
        error('There was a problem downloading the test data');
    end
else
    fprintf('I am going to use the demoniak data at %s', path_test.demoniak);
end

%% Build test pipeline
nb_rep = 3;
opt_t.flag_test = true;
pipe = struct;
for rr = 1:nb_rep
    path_test.result{rr} = [pwd filesep sprintf('result%i',rr) filesep];
    opt_t.folder_out = path_test.result{rr};
    pipe = psom_merge_pipeline(pipe,niak_demo_fmri_preprocess(path_test.demoniak,opt_t),sprintf('res%i_',rr));
end

%% Run pipeline
opt_p.path_logs = [pwd filesep 'logs' filesep];
opt_p.max_queued = 3;
psom_run_pipeline(pipe,opt_p);