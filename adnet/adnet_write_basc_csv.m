%% csv models adnet


clear all

data.dir_raw                =   '/home/atam/database/adnet/models/';
data.name_csv_group         =   'admci_model_group_20141210';


data.subjects ={'ad_0001','ad_0002','ad_0004','ad_0005','ad_0006','ad_0007','ad_0008','ad_0009','ad_0010','ad_0014','ad_0015','ad_0016','ad_0019','ad_0020','ad_0023','ad_1002','ad_1003','ad_1004','ad_1006','ad_1007','ad_1008','ad_1009','ad_1010','ad_1011','ad_1012','ad_1013','ad_1014','ad_1016','ad_1017','ad_1018','ad_1019','ad_1020','ad_1021','ad_1022','ad_dat_101','ad_dat_102','ad_dat_103','ad_dat_104','ad_dat_106','ad_dat_107','ad_dat_108','ad_dat_109','ad_dat_110','ad_dat_113','ad_dat_115','ad_dat_116','ad_dat_117','ad_dat_118','ad_hc_101','ad_hc_102','ad_hc_103','ad_hc_104','ad_hc_105','ad_hc_106','ad_hc_107','ad_hc_108','ad_hc_109','ad_hc_110','ad_hc_111','ad_hc_112','ad_hc_113','ad_hc_114','ad_hc_115','ad_hc_116','ad_hc_118','ad_hc_119','AD001','AD002','AD004','AD005','AD006','AD007','AD008','AD009','AD010','AD011','AD012','AD013','AD014','AD015','AD016','AD017','AD018','AD019','AD020','AD021','AD022','AD023','AD024','AD025','AD026','AD027','AD028','AD029','AD030','AD031','AD032','AD033','AD034','AD035','AD036','AD037','AD038','AD039','AD040','AD041','AD042','AD043','AD044','AD045','AD046','SB_30007','SB_30008','SB_30011','SB_30013','SB_30014','SB_30015','SB_30017','SB_30018','SB_30019','SB_30022','SB_30023','SB_30024','SB_30025','SB_30026','SB_30028','SB_30029','SB_30030','SB_30033','SB_30034','SB_30035','SB_30038','SB_30040','SB_30041','SB_30049','SB_30051','SB_30052','SB_30057','SB_30058','SB_30059','subject0107','subject0186','subject0295','subject0685','subject0729','subject0731','subject0778','subject0919','subject1155','subject1186','subject1261','subject1268','subject1280','subject2010','subject2017','subject2018','subject2022','subject2043','subject2073','subject2133','subject2138','subject2155','subject2180','subject2233','subject2324','subject2351','subject2357','subject2373','subject2389','subject2391','subject2396','subject2403','subject4005','subject4021','subject4024','subject4029','subject4032','subject4042','subject4094','subject4128','subject4149','subject4150','subject4153','subject4171','subject4188','subject4189','subject4192','subject4194','subject4203','subject4213','subject4218','subject4219','subject4220','subject4225','subject4229','subject4237','subject4250','subject4251','subject4252','subject4257','subject4262','subject4268','subject4269','subject4270','subject4285','subject4287','subject4293','subject4294','subject4313','subject4343','subject4345','subject4346','subject4349','subject4352','subject4357','subject4363','subject4367','subject4369','subject4371','subject4395','subject4399','subject4400','subject4405','subject4408','subject4415','subject4417','subject4422','subject4433','subject4442','subject4447','subject4449','subject4468','subject4469','subject4473','subject4474','subject4476','subject4477','subject4485','subject4496','subject4511','subject4512','subject4515','subject4517','subject4521','subject4542','subject4546','subject4548','subject4549','subject4556','subject4557','subject4578','subject4579','subject4580','subject4589','subject4590','subject4595','subject4597','subject4605','subject4616','subject4641','subject4654','subject4660','subject4661','subject4679','subject4680','subject4696','subject4713','subject4721','subject4726','subject4727','subject4730','subject4731','subject4733','subject4746','subject4768','subject4761','subject4791','subject4799','subject4809','subject4813','subject4817','subject4835','subject4836','subject4848','subject4867','subject4868','subject4883','subject4884','subject4889','subject4917','subject4925','subject4932','subject4947','subject4956','subject4960','subject4971','subject4982','subject4984','subject4985','subject4990','subject4993','subject4997','subject5006','subject5012','subject5018','subject5019','subject5059','subject5070','subject5071','subject5074','subject5075','subject5091','subject5096','subject5102','subject5106','subject5137','subject5138','subject5142','subject5148','subject5153','subject5163','subject5171','subject5178','subject5180','subject5202','subject5208','subject5230','subject5240','subject5242','subject5256'};
data.names = {'gender','diagnosis'};
%gender
data.values(:,1)=[1;1;1;1;1;2;1;2;2;2;2;2;2;1;2;1;2;1;1;1;1;2;2;2;2;2;2;1;2;2;1;1;2;2;2;2;2;2;2;2;2;2;2;1;2;1;2;1;2;2;1;2;2;2;2;2;2;1;1;2;2;1;1;1;1;2;2;2;2;2;1;2;1;1;1;2;1;2;1;1;1;1;1;1;2;2;1;2;1;2;2;2;2;1;2;2;1;2;2;2;2;1;2;2;1;2;2;2;2;1;1;1;2;2;2;1;1;2;1;1;2;2;2;2;2;1;2;2;2;2;2;2;1;1;1;1;2;1;2;2;2;2;1;2;2;1;1;1;1;1;2;1;2;2;2;2;1;2;2;2;1;2;2;2;2;2;1;2;2;2;2;2;1;1;2;1;2;1;2;2;1;1;1;1;1;2;1;1;2;2;1;2;2;1;1;2;1;1;2;1;2;2;2;2;1;2;1;2;2;1;1;1;2;1;2;2;2;1;1;2;2;1;1;1;2;1;2;2;2;2;2;2;1;1;1;1;2;1;2;1;2;1;2;1;2;1;1;1;1;2;2;1;2;2;2;1;2;2;1;2;2;2;1;1;2;2;1;1;2;2;2;2;1;2;2;2;2;1;1;1;1;1;1;1;1;1;2;2;1;1;1;1;1;2;1;1;2;2;2;2;2;2;2;1;1;2;1;1;1;2;2;1;1;2;1;2;1;2;1;1;1;2;1;1;2;1;2;2;1;2];

%diagnosis
data.values(:,2)=[1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;3;3;3;3;3;3;3;3;3;3;3;3;3;3;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;1;1;2;1;1;2;2;2;2;2;3;2;2;3;3;2;2;2;2;2;2;2;2;1;1;1;1;1;2;2;1;2;1;1;2;1;1;2;1;1;1;1;3;3;1;2;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;1;2;2;2;1;2;2;2;2;2;1;2;1;1;1;3;1;3;2;2;2;1;2;1;2;NaN;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;2;1;3;2;1;2;3;2;2;1;3;2;2;3;3;2;2;1;1;2;2;1;2;2;2;2;3;1;1;2;1;1;2;2;2;2;1;1;1;2;1;1;1;2;1;1;1;2;1;1;2;2;2;2;1;1;1;2;1;2;1;2;1;2;3;1;1;1;2;2;2;2;2;3;2;3;2;2;1;1;1;3;2;2;2;2;1;3;2;3;2;2;2;3;2;2;1;1;3;1;3;2;2;2;2;2;2;2;2;1;2;2;3;2;2;2;2;2;2;2;2;2;2;3;3;3;2;3;3;3;3;3;3;3;3;3;3;3;1;1;1;1;3;1;3;1;1;1;3;1;1;1;1;3;1;3;1;1];



%% write csv                        

opt.labels_y = data.names;
opt.labels_x = data.subjects;
%opt.precision = 2;
niak_write_csv(strcat(data.dir_raw,data.name_csv_group,'.csv'),data.values,opt)










