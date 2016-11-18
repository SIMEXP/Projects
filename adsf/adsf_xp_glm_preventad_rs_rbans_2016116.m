%% script to test preventad resting state weights with RBANS

clear all

net = [2 5 7];
c_field = {'immediate_memory_index_score','visuospatial_constructional_index_score','language_index_score','attention_index_score','delayed_memory_index_score'};

for nn = 1:3
    files_in.weight = strcat('rs_net',num2str(net(nn)),'_weights.mat');
    files_in.model = 'preventad_model_rs_weights_2016116.csv';
    files_out = struct;
    for cc = 1:5
        field = c_field{cc};
        opt.contrast.(field) = 1;
        opt.contrast.age = 0;
        opt.contrast.gender = 0;
        opt.contrast.edu = 0;
        opt.scale = 1;
        opt.folder_out = strcat('net',num2str(net(nn)),'/',field);
        psom_mkdir(opt.folder_out);
        niak_brick_association_test(files_in,files_out,opt)
        clear opt
    end
end

clear all

net = [2 5 7];
c_field = {'immediate_memory_index_score','visuospatial_constructional_index_score','language_index_score','attention_index_score','delayed_memory_index_score'};

for nn = 1:3
    files_in.weight = strcat('rs_net',num2str(net(nn)),'_weights.mat');
    files_in.model = 'preventad_model_rs_weights_2016116.csv';
    files_out = struct;
    
    for cc = 1:5
        field = c_field{cc};
        opt.contrast.(field) = 1;
        opt.contrast.age = 0;
        opt.contrast.gender = 0;
        opt.contrast.edu = 0;
        opt.scale = 1;
        opt.data_type = 'continuous';
        opt.folder_out = strcat('net',num2str(net(nn)),'/',field);
        files_in.association = strcat('net',num2str(net(nn)),'/',field,'/association_stats.mat');
        niak_brick_visu_subtype_glm(files_in,files_out,opt)
        clear opt
    end
end