clc;
clear all;
close all;

user = randi([1,6],[15,15]); %Randomizing user distribution in a 15x15 area
umax = max(max(user));       %Max user requirement

final = zeros(15,15);        %Area matrix
final(4,4) = 115;            %Assigning locations and max capacities to the base stations
final(2,9) = 205;  
final(4,12) = 165; 
final(10,1) = 80;  
final(14,2) = 75;  
final(9,7) = 215;  
final(15,9) = 120; 
final(11,14) = 135;
final(15,15) = 150;

c = 1;     %Combining user distribution matrix with base stations and their respective power consumptions
for i = 1:15
    for j= 1:15
        if final(i,j)==0                            %user di%user in double overlap area
127
                    u = bgroup(b1,q);stribution
          final(i,j) = user(i,j);
        else
          final(i,j) = final(i,j)-user(i,j);        %BS internal power usage
          b(c) = final(i,j);                        %Final BS capacity
          xbs(c) = i;                               %BS location coordinates                    
          ybs(c) = j;                               
          c = c + 1;
        end
    end
end
nbs = length(b);                                        %number of BS available in given area

for k = 1:nbs   %for power distribution among users
    [m,n] = find(final == b(k));    %coordinates of the corresponding base station
    c = 1;
    for pa = m-3:m+3                %considering a 7x7 coverage area
        for qa = n-3:n+3
            if pa > 0 && qa > 0 && pa <= 15 && qa <= 15     %considering BS with coverage range inside working area
                if (pa == m && qa == n)                     %ignoring BS coordinates to avoid overlapping
                    continue;
                else
                    if final(pa,qa) > umax                  %considering case of BSs inside coverage area of another BS
                        bgroup(k,c) = nan;                  
                        xcod(k,c) = nan;
                        ycod(k,c) = nan;
                        agroup(k,c) = nan;
                    else
                        bgroup(k,c) = final(pa,qa);         %user and BS matrix values around each BS entered in each row
                        xcod(k,c) = pa;                     %coordinates
                        ycod(k,c) = qa;                     
                        agroup(k,c) = str2num([num2str(pa*10+qa),num2str(abs(pa*10-qa)),num2str(final(pa,qa))]);
                                                            %user and BS matrix including its coordinates
                    end
                end
            else                                            %considering BS with coverage range outside working area (replaced nby NaN)
                if (pa == m) && (qa == n)                   %ignoring BS coordinates to avoid overlapping
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
len = length(bgroup); %length of rows of users under BS coverage area matrix

C2 = nan(1,len+2);          %considering overlap area of base stations taking two at a time
if ~isempty(agroup)
    a = 1;
    for i = 1:nbs-1
        for j = i+1:nbs
            y = intersect(agroup(i,:),agroup(j,:));            %finding overlap points
            if ~isempty(y)
                C2(a,:) = [i,j,y,zeros(1,len-length(y))];      %entering overlap points of each BS in a row, along with coordinates, if any
                a = a + 1;            
            end
        end
    end
end

C3 = nan(1,len+3);              %considering overlap area of base stations taking three at a time
if ~isnan(C2)
    a = 1;
    for i = 1:size(C2,1)
        for j = i+2:nbs
            if C2(i,1) < j && C2(i,2) < j
                y = intersect(C2(i,2:length(C2)),agroup(j,:));      %finding overlap points
                if ~isempty(y)
                    C3(a,:) = [C2(i,1),C2(i,2),j,y,zeros(1,len-length(y))];     %entering overlap points of each BS in a row, along with coordinates, if any
                    a = a + 1;                
                end
            end
        end
    end
end

x = [b;zeros(1,nbs)]; %matrix for BS capacity and no of users supported
figure,

for i = 1:nbs             %Supporting users that come under coverage area of one BS only with corresponding BS 
    for j = 1:len
        if ~(ismember(agroup(i,j),C2(:,3:length(C2))))
            if bgroup(i,j) <= umax && bgroup(i,j) > 0 && x(1,i) >= bgroup(i,j)
              x(1,i) = x(1,i) - bgroup(i,j);
              x(2,i) = x(2,i) + 1;                %no of users under one BS only
              plot(xcod(i,j),ycod(i,j),'k.');     %plotting users
              hold on
            end
        end
    end
end

if ~isnan(C2)               %attempt to reach full capacity utilization for BS by providing power to the users in...
    for i = 1:size(C2,1)    %...overlapping area from the BS which is nearer to achieving full capacity utilization
        b1 = C2(i,1);
        b2 = C2(i,2);
        for j = 3:length(C2)
            if ~eq(C2(i,j),0)
                if ~(ismember(C2(i,j),C3(:,4:length(C3))))
                    q = find(agroup(b1,:) == C2(i,j));      %user in double overlap area
                    u = bgroup(b1,q);
                    if u > 0
                        if u < x(1,b1) && u < x(1,b2)           %checking if user requirement esser thn BS capacity
                            if x(1,b1) > x(1,b2)                %proving from BS with min remaining power value
                                x(1,b1) = x(1,b1) - u;
                                x(2,b1) = x(2,b1) + 1;
                                plot(xcod(b1,q),ycod(b1,q),'m.'); %plotting users
                                hold on;
                            else
                                x(1,b2) = x(1,b2) - u;
                                x(2,b2) = x(2,b2) + 1;
                                plot(xcod(b2,q),ycod(b2,q),'m.');
                                hold on;
                            end
                        elseif u < x(1,b1) && u > x(1,b2)
                            x(1,b1) = x(1,b1) - u;
                            x(2,b1) = x(2,b1) + 1;
                            plot(xcod(b1,q),ycod(b1,q),'m.');
                            hold on;
                        elseif u > x(1,b1) && u < x(1,b2)
                            x(1,b2) = x(1,b2) - u;
                            x(2,b2) = x(2,b2) + 1;
                            plot(xcod(b2,q),ycod(b2,q),'m.');
                            hold on;
                        end
                    end
                end
            end
        end
    end
end

if ~isnan(C3)
    for i = 1:size(C3,1)
        b1 = C3(i,1);
        b2 = C3(i,2);
        b3 = C3(i,3);
        for j = 4:length(C3)
            if ~eq(C3(i,j),0)
                q = find(agroup(b1,:) == C3(i,j));          %user in triple overlap area
                u = bgroup(b1,q);
                arr = [x(1,b1),x(1,b2),x(1,b3),u];              %checking if user requirement esser thn BS capacity ad providing...
                arr2 = [x(2,b1),x(2,b2),x(2,b3)];               %...with power rom the BS having lesser value
                sorted_ar = sort(arr);
                g = find(sorted_ar == u);
                h = find(arr == sorted_ar(g+1));
                arr(h) = arr(h) - u;
                arr2(h) = arr2(h) + 1;
                plot(xcod(b1,q),ycod(b1,q),'c.');                 %plotting users
                hold on
            end
            x(:,b1) = [arr(1),arr2(1)];                         %entering final calculated value to BS data matrix
            x(:,b2) = [arr(2),arr2(2)];
            x(:,b3) = [arr(3),arr2(3)];
        end
    end
end

plot(xbs,ybs,'rs');         %Plotting the Base Stations
xlim([1 15]);               %limiting the x and y axis as per the area considered
ylim([1 15]);
hold off;
title('Locations of Users and Base Stations');

figure,                     %Plotting the coordinates of the users (*) for each corresponding BS (squares)
for i = 1:nbs
    plot(xcod(i,:),ycod(i,:),'*');
    hold on;
end
plot(xbs,ybs,'rs');
hold off;
xlim([1 15]);
ylim([1 15]);
title('Locations of Users and Base Stations');

Ctxstatic = 0.8;            %Power Calculation and OPEX
Ctxnl = 0.04;
Pspstatic = 15;
Pspnl = 0.55;
Cps = 0.11;
upa = 0.20;
Ptx = 24;

Pstatic = (Ptx/upa*Ctxstatic+Pspstatic)*(1+Cps);
for i = 1:nbs
    nl = x(2,i);
    Pdyn(i) = (Ptx/upa*(1+Ctxstatic)*Ctxnl+Pspnl)*nl*(1+Cps);
    Pbs(i) = Pstatic + Pdyn(i);
end
