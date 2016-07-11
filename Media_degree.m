%Author: Keyi Yang
%Date:7/11/2016
%For Insight Data Science, Codeing-challenge
%Email: yangkeyi1915@gmail.com

clear
clc

%Extract fields(created_time, target and actor)from the JSON response
%Every row is split by delimiter " into 13 parts and stored in A
fileID = fopen('venmo-trans.txt','r');
A = textscan(fileID,'%q %q %q %q %q %q %q %q %q %q %q %q %q','Delimiter','"');
fclose(fileID);
celldisp(A)
%Extract created_time, target and actor and store in corresponding matrix
created_time =A{1,4}(1:size(A{1,4}),1);
target =A{1,8}(1:size(A{1,8}),1);
actor = A{1,12}(1:size(A{1,12}),1);
%To calculate specified values in the first 60s sliding window
p=0;
s=0;
t=1;
j=1;
%Set the first created_time value as the first timestamp
%Search for transactions within the first 60s sliding window
%Store the selected transactions and calculate node degree and median
timestamp=created_time(1,1);
  while (t<=size(created_time,1))
       t1 = datevec(timestamp,'yyyy-mm-ddTHH:MM:SSZ');
       t2 = datevec(created_time(t,1),'yyyy-mm-ddTHH:MM:SSZ');
       e = etime(t2,t1);
       if (e<=60)&& (e>=-60)
          p=p+1;
          Selected_time(p,1)=created_time(t,1);
          Selected_target(p,1)=target(t,1);
          Selected_actor(p,1)=actor(t,1);
          t=t+1;
          Trans_target=transpose(Selected_target);
Trans_actor=transpose(Selected_actor);
Trans_ta=[Trans_target;Trans_actor];
Sorted_ta=sortrows(Trans_ta);
Separate_ta=transpose(Sorted_ta);
Combined_ta=strcat(Separate_ta(:,1),{', '},Separate_ta(:,2));
Unique_pair=unique(Combined_ta);
Split_unique_pair = regexp(Unique_pair, ',', 'split');
    for a=1:size(Unique_pair,1)
        Unique_target{a,1}=Split_unique_pair{a,1}{1,1};
        Unique_actor{a,1}=Split_unique_pair{a,1}{1,2};
    end
relationship=graph(Unique_target,Unique_actor);
N_Degree = degree(relationship);
MedianMatrix(j,1) = median(N_Degree,1);
j=j+1;
clearvars Unique_target
clearvars Unique_actor
       else
           %
           s=s+1;
           Remaining_time_index(s,1)=t;
           t=t+1;
       end
  end

  
%Make a loop to run the code automatically after 60s sliding window  
i=0;
while (i<size(created_time,1))
timestamp=created_time(Remaining_time_index(1,1),1);
p=0;
s=0;
q=1;
Stored_Selected_time=Selected_time;
Stored_Selected_target=Selected_target;
Stored_Selected_actor=Selected_actor;
Stored_Remaining_time_index=Remaining_time_index;
clearvars Selected_time
clearvars Selected_target
clearvars Selected_actor
clearvars Remaining_time_index
clearvars Unique_target
clearvars Unique_actor
  while (q<=size(Stored_Selected_time,1))
       t1 = datevec(timestamp,'yyyy-mm-ddTHH:MM:SSZ');
       t2 = datevec(Stored_Selected_time(q,1),'yyyy-mm-ddTHH:MM:SSZ');
       e = etime(t2,t1);
       if (e<=60)&& (e>=-60)
          p=p+1;
          Selected_time(p,1)=Stored_Selected_time(q,1);
          Selected_target(p,1)=Stored_Selected_target(q,1);
          Selected_actor(p,1)=Stored_Selected_actor(q,1);
          q=q+1;
          
       else q=q+1;
       end
  end
  
   for t=Stored_Remaining_time_index(1,1):size(created_time,1)
       t3 = datevec(timestamp,'yyyy-mm-ddTHH:MM:SSZ');
       t4 = datevec(created_time(t,1),'yyyy-mm-ddTHH:MM:SSZ');
       e = etime(t4,t3);
       if (e<=60)&& (e>=-60)
          p=p+1;
          Selected_time(p,1)=created_time(t,1);
         Selected_target(p,1)=target(t,1);
          Selected_actor(p,1)=actor(t,1);
          i=t;
          Trans_target=transpose(Selected_target);
Trans_actor=transpose(Selected_actor);
Trans_ta=[Trans_target;Trans_actor];
Sorted_ta=sortrows(Trans_ta);
Separate_ta=transpose(Sorted_ta);
Combined_ta=strcat(Separate_ta(:,1),{', '},Separate_ta(:,2));
Unique_pair=unique(Combined_ta);
Split_unique_pair = regexp(Unique_pair, ',', 'split');
    for a=1:size(Unique_pair,1)
        Unique_target{a,1}=Split_unique_pair{a,1}{1,1};
        Unique_actor{a,1}=Split_unique_pair{a,1}{1,2};
    end
relationship=graph(Unique_target,Unique_actor);
N_Degree = degree(relationship);
MedianMatrix(j,1) = median(N_Degree);
j=j+1;
Output_file=fopen('output.txt','w');
fprintf(Output_file,'%d\n',MedianMatrix(:,1));
fclose(Output_file);
       else
           s=s+1;
           Remaining_time_index(s,1)=t;
       end
   end
clearvars Stored_Selected_time

end
       
       
       
%plot a graph of users and their relationship with one another
%relationship=graph(target,actor);
%plot(relationship)
