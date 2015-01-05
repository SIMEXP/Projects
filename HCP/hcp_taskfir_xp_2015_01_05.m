# Octave 3.8.1, Mon Jan 05 12:05:51 2015 EST <pbellec@merisier>
build_path_std
cd /home/pbellec/database/HCP_task/stability_fir_perc_MOTORrh_hcp_all_sub/stability_group/sci80_scg80_scf83
pwd
niak_brick_mnc2nii('/home/pbellec/database/HCP_task/stability_fir_perc_MOTORrh_hcp_all_sub/stability_group/sci80_scg80_scf83','/home/pbellec/database/HCP_task/stability_fir_perc_MOTORrh_hcp_all_sub/stability_group/sci80_scg80_scf83_nii')
pwd
ls
load fdr_group_average_sci80_scg80_scf83.mat
whos
plot(test_fir.mean(:,2))
plot(test_fir.mean(:,10))
ls
cd ../
ls
cd fir/
ls
clear
load fir_group_level_HCP164030.mat
whos
list_files = dir('fir_group_level_*');
list_files = {list_files.name};
for ff = 1:list_files
for ff = 1:length(list_files);
data = load(list_files{ff},'sci80_scg80_scf83');
fir_all(:,:,ff) = data.sci80_scg80_scf83.fir_mean;
end
size(fir_all)
plot(mean(fir_all(:,2,:),3))
plot(mean(fir_all(:,10,:),3))
plot(squeeze(fir_all(:,10,:)))
D = niak_build_distance (squeeze(fir_all(:,10,:)));
niak_visu_matrix(D)
hier = niak_hierarchical_clustering (-D);
order = niak_hier2order (hier);
niak_visu_matrix(D(order,order))
part = niak_threshold_hierarchy (hier,struct('thresh',10));
figure
niak_visu_part (part(order))
figure
niak_visu_matrix(D(order,order))
figure, plot(mean(fir_all(:,10,part==4),3))
figure, plot(mean(fir_all(:,10,part==9),3))
figure
plot(mean(fir_all(:,2,:),3))
figure, plot(fir_all(:,10,part==9))
figure, plot(mean(fir_all(:,10,part==4),3))
plot(mean(fir_all(:,10,part==9),3))
figure, plot(mean(fir_all(:,10,part==4),3))
hold on
plot(mean(fir_all(:,10,part==9),3),'r')
plot(mean(fir_all(:,10,part==9),7),'g')
plot(mean(fir_all(:,10,part==7),3),'g')
plot(mean(fir_all(:,10,part==5),3),'')
plot(mean(fir_all(:,10,part==5),3),'k')
plot(mean(fir_all(:,10,part==8),3),'y')
hist
history
help history
pwd
cd
cd Desktop/
ls
pwd
cd
cd git/
cd projects/
ls
cd HCP/
ls
history -w hcp_taskfir_xp_2015_01_05.m
