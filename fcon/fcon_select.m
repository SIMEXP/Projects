function [] = fcon_select(subjects,opt)

% Creates a text file and an histogram of the database's age distribution.
% 
% [] = fcon_select(subjects,opt)
% 
% IN:
%   subjects:
%     Matrix containing subject information. See fcon_read_demog for more information.
%   opt:
%     Structure containing:
%       flag_nohist:
%         Logical value which tells to create an histogram or not. 0 to create, 1 to not create. By default: 0.
%       image_path:
%         Path where to save the histogram image. By default: age_distribution.png (current folder).
%       diary_path:
%         Path where to save the text file with the age distribution information. By default: age_distribution.txt (current folder).
% 
% OUT:
%   VOID
% 

gb_name_structure = 'opt'; 
gb_list_fields = {'flag_nohist','image_path','diary_path'};
gb_list_defaults = {0,'age_distribution.png','age_distribution.txt'};
niak_set_defaults 

%% Parameters
age_window = [0 129];

age_groups{1} = [0 9];
age_groups{2} = [10 19];
age_groups{3} = [20 29];
age_groups{4} = [30 39];
age_groups{5} = [40 49];
age_groups{6} = [50 54];
age_groups{7} = [55 59];
age_groups{8} = [60 64];
age_groups{9} = [65 69];
age_groups{10} = [70 74];
age_groups{11} = [75 79];
age_groups{12} = [80 84];
age_groups{13} = [85 89];
age_groups{14} = [90 99];
age_groups{15} = [100 139];
age_groups{16} = [140 Inf];

list_age_m = zeros(1,length(age_groups));
list_age_f = zeros(1,length(age_groups));
list_age_o = zeros(1,length(age_groups));
list_age_m2 = zeros(1);
list_age_f2 = zeros(1);
list_age_o2 = zeros(1);

nb_m = zeros(length(age_groups));
nb_f = zeros(length(age_groups));
nb_o = zeros(length(age_groups));
nb_m2 = 0;
nb_f2 = 0;
nb_o2 = 0;
nb_subj = zeros(length(age_groups));
nb_m3 = 0;
nb_f3 = 0;
nb_o3 = 0;

if ~exist(diary_path,'file')
  system(['touch ' diary_path]);
end
fid = fopen(diary_path,'w');

for num_g = 1:length(age_groups)
  age_window = age_groups{num_g};
  
  %% Init variables
  for num_s = 1:length(subjects)
    age_int = str2double(subjects{num_s,3});
    if (age_int>=age_window(1))&(age_int<=age_window(2))
      nb_subj(num_g) = nb_subj(num_g)+1;
      if strcmpi(strtrim(subjects{num_s,4}),'m')
	nb_m(num_g) = nb_m(num_g) + 1;
	nb_m2 = nb_m2 + 1;
	list_age_m(nb_m(num_g),num_g) = age_int;
	list_age_m2(nb_m2) = age_int;
	list_subj_age_m{nb_m(num_g),num_g} = subjects{num_s,1};
	if num_s == length(age_groups)
	  nb_m3 = nb_m3 + 1;
	end
      elseif strcmpi(strtrim(subjects{num_s,4}),'f')
	nb_f(num_g) = nb_f(num_g)+1;
	nb_f2 = nb_f2 + 1;
	list_age_f(nb_f(num_g),num_g) = age_int;
	list_age_f2(nb_f2) = age_int;
	list_subj_age_f{nb_f(num_g),num_g} = subjects{num_s,1};
	if num_s == length(age_groups)
	  nb_f3 = nb_f3 + 1;
	end
      else
	nb_o(num_g) = nb_o(num_g) + 1;
	nb_o2 = nb_o2 + 1;
	list_age_o(nb_o(num_g),num_g) = age_int;
	list_age_o2(nb_o2) = age_int;
	list_subj_age_o{nb_o(num_g),num_g} = subjects{num_s,1};
	if num_s == length(age_groups)
	  nb_o3 = nb_o3 + 1;
	end
      end
    end
  end

  if(nb_subj(num_g) ~= 0)
    %% A little table
    fprintf(fid,'\n****************************************\nAge group : from %i yo to %i yo\n****************************************\n',age_window(1),age_window(2));
    fprintf(fid,'Total number of subjects : %i (%i men, %i women)\n',nb_subj(num_g),nb_m(num_g),nb_f(num_g));

    fprintf(fid,'List of men :\n');
    if (nb_m(num_g) ~= 0)
      for num_s = 1:nb_m(num_g)-1
	fprintf(fid,'%s, ',list_subj_age_m{num_s,num_g}(end-4:end));
      end
      fprintf(fid,'%s\n',list_subj_age_m{nb_m(num_g),num_g}(end-4:end));
    else
      fprintf(fid,'No men in list');
    end 
    fprintf(fid,'\n')

    fprintf(fid,'List of women :\n')
    if (nb_f(num_g) ~= 0)
      for num_s = 1:nb_f(num_g)-1
	fprintf(fid,'%s, ',list_subj_age_f{num_s,num_g}(end-4:end));
      end
      fprintf(fid,'%s\n',list_subj_age_f{nb_f(num_g),num_g}(end-4:end));
    else
      fprintf(fid,'No women in list');
    end
    fprintf(fid,'\n');


    if (nb_o(num_g) ~= 0)
      fprintf(fid,'List of other :\n')
      for num_s = 1:nb_o(num_g)-1
	fprintf(fid,'%s, ',list_subj_age_o{num_s,num_g}(end-4:end));
      end
      fprintf(fid,'%s\n',list_subj_age_o{nb_o(num_g),num_g}(end-4:end));
    end
  end    
end

fprintf(fid,'\n***************************\n');
if nb_m2 ~= 0
  fprintf(fid,'Men : %i\n',nb_m2);
  fprintf(fid,'Average age : %1.2f\n',mean(list_age_m2(1:end-nb_m3)));
  fprintf(fid,'Median age : %1.2f\n',median(list_age_m2(1:end-nb_m3)));
  fprintf(fid,'Max age : %1.2f\n',max(list_age_m2(1:end-nb_m3)));
  fprintf(fid,'Min age : %1.2f\n\n',min(list_age_m2(1:end-nb_m3)));
end
if nb_f2 ~= 0
  fprintf(fid,'Women : %i\n',nb_f2);
  fprintf(fid,'Average age : %1.2f\n',mean(list_age_f2(1:end-nb_f3)));
  fprintf(fid,'Median age : %1.2f\n',median(list_age_f2(1:end-nb_f3)));
  fprintf(fid,'Max age : %1.2f\n',max(list_age_f2(1:end-nb_f3)));
  fprintf(fid,'Min age : %1.2f\n\n',min(list_age_f2(1:end-nb_f3)));
end
if nb_o2 ~= 0
  fprintf(fid,'Other : %i\n',nb_o2);
  fprintf(fid,'Average age : %1.2f\n',mean(list_age_o2(1:end-nb_o3)));
  fprintf(fid,'Median age : %1.2f\n',median(list_age_o2(1:end-nb_o3)));
  fprintf(fid,'Max age : %1.2f\n',max(list_age_o2(1:end-nb_o3)));
  fprintf(fid,'Min age : %1.2f\n\n',min(list_age_o2(1:end-nb_o3)));
end

if opt.flag_nohist
  fprintf(fid,'Histogram not created.\n');
else
  %% A histogram of the age distribution within the group  
  histogram = figure('name',sprintf('Age distribution'));
  %%set(figure,'name',sprintf('Age distribution'));
  X = [0 10 20 30 40 50 55 60 65 70 75 80 85 90 100];
  if(nb_m2 ~= 0 & nb_f2 == 0 & nb_o2 == 0) 
    Ym = histc(list_age_m2,X);
    bar(X,Ym');
    legend({'men'});
    axis([0 130 0 max(Ym)+1]);
  end
  if(nb_f2 ~= 0 & nb_m2 == 0 & nb_o2 == 0)
    Yf = histc(list_age_f2,X);
    bar(X,Yf');
    legend({'women'});
    axis([0 130 0 max(Yf)+1]);
  end
  if(nb_m2 ~= 0 & nb_f2 ~= 0 & nb_o2 == 0)
    Ym = histc(list_age_m2,X);
    Yf = histc(list_age_f2,X);
    bar(X,[Ym',Yf']);
    legend({'men','women'});
    axis([0 130 0 max(max(Ym),max(Yf))+1]);
  end
  if(nb_m2 ~= 0 & nb_f2 == 0 & nb_o2 ~= 0) 
    Ym = histc(list_age_m2,X);
    Yo = histc(list_age_o2,X);
    bar(X,[Ym',Yo]);
    legend({'men','other'});
    axis([0 130 0 max(max(Ym),max(Yo))+1]);
  end
  if(nb_f2 ~= 0 & nb_m2 == 0 & nb_o2 ~= 0)
    Yf = histc(list_age_m2,X);
    Yo = histc(list_age_o2,X);
    bar(X,[Yf',Yo]);
    legend({'women','other'});
    axis([0 130 0 max(max(Yf),max(Yo))+1]);
  end
  if(nb_m2 ~= 0 & nb_f2 ~= 0 & nb_o2 ~= 0)
    Ym = histc(list_age_m2,X);
    Yf = histc(list_age_f2,X);
    Yo = histc(list_age_o2,X);
    bar(X,[Ym',Yf',Yo]);
    legend({'men','women','other'});
    axis([0 130 0 max(max(Ym),max(Yf),max(Yo))+1]);
  end
  if(nb_m2 == 0 & nb_f2 == 0 & nb_o2 ~= 0)
    Yo = histc(list_age_o2,X);
    bar(X,Yo);
    legend({'other'});
    axis([0 130 0 max(Yo)+1]);
  end
  
  if exist('OCTAVE_VERSION','builtin')
    print(opt.image_path);
    replot;
  else
      saveas(histogram,opt.image_path,'png');
  end
end
fclose(fid);
end