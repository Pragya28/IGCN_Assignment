clc;
clear all;
close all;

user = randi(6,15);				%Randomly user distribution in a 15x15 area for medium traffic distribution
umax = max(max(user));			%Maximum user requirement

grid = zeros(15,15);			%Area matrix
grid(4,4) = 450;			%Placing BSs at randomly selected locations
grid(2,9) = 450;  
grid(4,12) = 450; 
grid(10,1) = 450;  
grid(14,4) = 450;  
grid(9,7) = 450;  
grid(15,11) = 450; 
grid(11,14) = 450;
grid(15,15) = 450;

c = 1;			%Combining user distribution matrix with BSs and forming 15x15 grid
for i = 1:15			
    for j= 1:15
        if grid(i,j)==0			%Placing user requirement values in the grid
          grid(i,j) = user(i,j);
        else
          b(c) = grid(i,j);			%Storing BS value in a array
          xbs(c) = i;			%BS x-coodrinates array
          ybs(c) = j;			%BS y-coodrinates array
          c = c + 1;
        end
    end
end
nbs = length(b);			%Total number of BSs available in grid
bs = [b;zeros(2,nbs)];			%Matrix for BS capacity, no of users supported and opex cost

figure,			%Plotting the grid
for i = 1:nbs
    rectangle('Position',[xbs(i)-3.5 ybs(i)-3.5 7 7],'EdgeColor','y');			%Marking the area covered by each BS
end
rectangle('Position',[0.5 0.5 15 15],'EdgeColor','y');			%Marking outer boundary of the grid
xlim([0 16]);			%Limiting the x-axis of the plot
ylim([0 16]);			%Limiting the y-axis of the plot
hold on;

for k = 1:nbs 			%For each BS                       
    c = 1;
    for pa = xbs(k)-3:xbs(k)+3			%Considering a 7x7 coverage area 
        for qa = ybs(k)-3:ybs(k)+3
            if pa > 0 && qa > 0 && pa <= 15 && qa <= 15			%Considering BS with coverage range inside working area
                if (pa == xbs(k) && qa == ybs(k))			%Ignoring BS coordinates
                    continue;
                else
                    if grid(pa,qa) > umax			%Considering other BSs lie inside coverage area of this BS   
                        bgroup(k,c) = nan;
                        xcod(k,c) = nan;
                        ycod(k,c) = nan;
                        agroup(k,c) = nan;
                    else
                        bgroup(k,c) = grid(pa,qa);			%User requirement values around the BS entered in each row
                        xcod(k,c) = pa;			%x-coordinate of corresponding user in bgroup
                        ycod(k,c) = qa;			%y-coordinate of corresponding user in bgroup
                        agroup(k,c) = str2num([num2str(pa*10+qa),num2str(abs(pa*10-qa)),num2str(grid(pa,qa))]);			%Coded values using coordinates and user requirement such that values are not same for two different users
                    end
                end
            else                                          %Considering coverage range of BS outside working area - all values are taken as NaN)
                if (pa == xbs(k)) && (qa == ybs(k))
                    continue;
                else
                    bgroup(k,c) = nan;
                    xcod(k,c) = nan;
                    ycod(k,c) = nan;
                    agroup(k,c) = nan;
                end
            end
            c = c+1;
        end
    end
end
len = length(bgroup);			%Length of rows of users under BS coverage area matrix

C2 = nan(1,len+2);			%Initialising the matrix containing users in overlap area of BSs taking two at a time by row of NaN
if ~isempty(agroup)			%Check if agroup (matrix containing coded values about users) is empty or not
    a = 1;
    for i = 1:nbs-1
        for j = i+1:nbs
            y = intersect(agroup(i,:),agroup(j,:));        %Finding overlap points between two BSs
            if ~isempty(y)			%Intersect is present or not
                C2(a,:) = [i,j,y,zeros(1,len-length(y))];			%Storing BS numbers (column 1 and 2) and common user codes
                a = a + 1;
            end
        end
    end
end

C3 = nan(1,len+3);			%Initialising the matrix containing users in overlap area of BSs taking three at a time by row of NaN
if ~isnan(C2)			%Check if C2 (matrix containing user codes common in two BSs) is empty or not
    a = 1;
    for i = 1:size(C2,1)
        for j = i+2:nbs           
            if C2(i,1) < j && C2(i,2) < j
                y = intersect(C2(i,2:length(C2)),agroup(j,:));			%Finding overlap points between three BSs
                if ~isempty(y)			%Intersect is present or not
                    C3(a,:) = [C2(i,1),C2(i,2),j,y,zeros(1,len-length(y))];			%Storing BS numbers (column 1 and 2) and common user codes
                    a = a + 1;
                end
            end
        end
    end
end

color = [0 0.25 0.25; 0.5 0 0.5; 0 0.75 0.25; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 0.75 0.9 0.15];			%Matrix containing RGB colour values for plotting users

for i = 1:nbs
    for j = 1:len
        if ~(ismember(agroup(i,j),C2(:,3:length(C2))))			%Check if user is common in two BS or not
            if bgroup(i,j) > 0 && bs(1,i) >= bgroup(i,j)			%If user lies in only one BS coverage area, check it is not greater than remaining BS capacity value
              bs(1,i) = bs(1,i) - bgroup(i,j);			%Subtract user requirement from remaining BS capacity
              bs(2,i) = bs(2,i) + 1;			%Add 1 to number of users connected
              plot(xcod(i,j),ycod(i,j),'k.');			%Plot user as black dot
              hold on
              plot(xcod(i,j),ycod(i,j),'o', 'MarkerEdgeColor',color(i,:));			%Plot user connected to different BS in different colours as circle
              hold on
            end
        end
    end
end

if ~isnan(C2)			%Check if users common in two BS are present or not
    for i = 1:size(C2,1)      
        b1 = C2(i,1);			%BS number 1 for which common users are taken
        b2 = C2(i,2);			%BS number 2 for which common users are taken
        for j = 3:length(C2)
            arr = [bs(1,b1),bs(1,b2),0];			%Creating array containing BS capacity of both BS and zero at place of user requirementarr = [0,0,0];
            arr2 = [bs(2,b1),bs(2,b2)];			%Creating array containing number of users connected to each BS
            if ~eq(C2(i,j),0)			
                if ~(ismember(C2(i,j),C3(:,4:length(C3))))			%Check if user is common in three BS or not
                    q = find(agroup(b1,:) == C2(i,j));			%Find position of user code in b1 row of agroup matrix
                    u = bgroup(b1,q);			%User requirement for searched user code
                    arr(3) = u;         %Inserting user requirement to the array                    
                    sorted_ar = sort(arr);			%Sort arr
                    g = find(sorted_ar == u);			%Find user position in sorted array
                    if g < 3			%If user requirement is greater than both BS capacities, then skip
                        h = find(arr == sorted_ar(g(1)+1));			%Find BS position with lower capacity in unsorted array
                        arr(h(1)) = arr(h(1)) - u;			%Subtract user requirement from BS with lower capacity
                        arr2(h(1)) = arr2(h(1)) + 1;			%Add 1 to number of connected users for BS with lower capacity
                        plot(xcod(b1,q),ycod(b1,q),'m.');			%Plot user as magenta dot
                        hold on
                        plot(xcod(b1,q),ycod(b1,q),'o', 'MarkerEdgeColor',color(b1,:));			%Plot user connected to different BS in different colours as circle
                        hold on                                            
                    end
                end
                bs(1:2,b1) = [arr(1),arr2(1)];			%Enter final calculated values to BS data matrix for b1
                bs(1:2,b2) = [arr(2),arr2(2)];          %Enter final calculated values to BS data matrix for b2
            end
        end
    end
end

if ~isnan(C3)			%Check if users common in three BS are present or not
    for i = 1:size(C3,1)
        b1 = C3(i,1);			%BS number 1 for which common users are taken
        b2 = C3(i,2);			%BS number 2 for which common users are taken
        b3 = C3(i,3);			%BS number 3 for which common users are taken
        for j = 4:length(C3)
            arr = [bs(1,b1),bs(1,b2),bs(1,b3),0];			%Creating array containing BS capacity of both BS and zero at place of user requirement
            arr2 = [bs(2,b1),bs(2,b2),bs(2,b3)];			%Creating array containing number of users connected to each BS
            if ~eq(C3(i,j),0)
                q = find(agroup(b1,:) == C3(i,j));			%Find position of user code in b1 row of agroup matrix
                u = bgroup(b1,q);			%User requirement for searched user code
                arr(3) = u;         %Inserting user requirement to the array                                    
                sorted_ar = sort(arr);			%Sort arr
                g = find(sorted_ar == u);			%Find user position in sorted array
                if g == 4			%If user requirement is greater than both BS capacities, then skip
                    continue;
                end
                h = find(arr == sorted_ar(g(1)+1));			%Find BS position with lower capacity in unsorted array
                arr(h(1)) = arr(h(1)) - u;			%Subtract user requirement from BS with lower capacity
                arr2(h(1)) = arr2(h(1)) + 1;			%Add 1 to number of connected users for BS with lower capacity
                plot(xcod(b1,q),ycod(b1,q),'c.');			%Plot user as cyan dot
                hold on
                plot(xcod(b1,q),ycod(b1,q),'o', 'MarkerEdgeColor',color(b1,:));			%Plot user connected to different BS in different colours as circle
                hold on                                    
            end
            bs(1:2,b1) = [arr(1),arr2(1)];			%Enter final calculated values to BS data matrix for b1
            bs(1:2,b2) = [arr(2),arr2(2)];          %Enter final calculated values to BS data matrix for b2
            bs(1:2,b3) = [arr(3),arr2(3)];          %Enter final calculated values to BS data matrix for b3
        end
    end
end
for i = 1:nbs
    plot(xbs(i),ybs(i),'s','MarkerEdgeColor',color(i,:),'MarkerFaceColor',color(i,:));			%Plot different BS in different colours as square
    hold on;
    title('Locations and Distribution of Users and BSs');
end
hold off

equipment = 20;         %Initial Investment - Equipment Cost
site_installation = 15;         %Initial Inveatment - Site Installation Cost
initial_cost = equipment + site_installation;
operation_maintenance = 1;          %Annual Operation and Maintenance Cost
site_lease = 3;         %Annual Site Lease
transmission_per_connection = 5;            %Annual Cost for Transmission to 1 connection
annual_cost = operation_maintenance + site_lease;
for i = 1:nbs
    trc(i) = transmission_per_connection * bs(2,i);         %Total transmission Cost for each BS
    bs(3,i) = initial_cost + annual_cost + trc(i);          %Total charges for each BS
end

total_opex_grid = sum(bs(3,:));         %Total Opex for entire grid
figure,
X = (bs(3,:));          %Plotting Pie chart showing contribution of each BS
pie(X,{'BS 1','BS 2','BS 3','BS 4','BS 5','BS 6','BS 7','BS 8','BS 9'});
title('CONTRIBUTION OF EACH BS ON TOTAL OPEX');

figure,
for i = 1:nbs
    X = [initial_cost, annual_cost, trc(i)];
    subplot(3,3,i)          %Plotting Pie Chart showing cost distribution per BS
    pie(X,{'Initial','Annual','Transmission'});
    title(['BS ',num2str(i)]);
end
sgtitle('OPEX DISTRIBUTION FOR EACH BS');