ind = 8;
D = niak_build_distance (squeeze(fir_all(:,ind,:)));
hier = niak_hierarchical_clustering (-D);
order = niak_hier2order (hier);
figure
niak_visu_matrix(D(order,order))

nb_clust = 3;
part = niak_threshold_hierarchy (hier,struct('thresh',nb_clust));
figure
niak_visu_part (part(order))

switch nb_clust
    case 3
        figure
        hold on 
        plot(mean(fir_all(:,ind,part==1),3),'r')
        plot(mean(fir_all(:,ind,part==2),3),'b')
        plot(mean(fir_all(:,ind,part==3),3),'g')
    case 4
        figure
        hold on 
        plot(mean(fir_all(:,ind,part==1),3),'r')
        plot(mean(fir_all(:,ind,part==2),3),'b')
        plot(mean(fir_all(:,ind,part==3),3),'g')
        plot(mean(fir_all(:,ind,part==4),3),'k')
    case 5
        figure
        hold on 
        plot(mean(fir_all(:,ind,part==1),3),'r')
        plot(mean(fir_all(:,ind,part==2),3),'b')
        plot(mean(fir_all(:,ind,part==3),3),'g')
        plot(mean(fir_all(:,ind,part==4),3),'k')
        plot(mean(fir_all(:,ind,part==5),3),'p')
end