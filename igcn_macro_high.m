clc;
clear all;
close all;

grid = randi([5,10],15);		%Randomly user distribution in a 15x15 area for high traffic distribution
umax = max(max(grid));			%Maximum user requirement

grid(8,8) = 2500;			%Placing BS at randomly selected location

figure,			        %Plotting the grid
rectangle('Position',[0.5 0.5 15 15],'EdgeColor','y');			%Marking outer boundary of the grid
xlim([0 16]);			%Limiting the x-axis of the plot
ylim([0 16]);			%Limiting the y-axis of the plot
hold on;

bs = [grid(8,8),0,0];
for i = 1:15
    for j = 1:15
        if ~eq(i,8) || ~eq(j,8)
            bs(1) = bs(1) - grid(i,j);		%Subtract user requirement from remaining BS capacity
            bs(2) = bs(2) + 1;			%Add 1 to number of users connected
            plot(i,j,'k.');			%Plot user as black dot
            hold on
        end
    end
end
plot(8,8,'rs','MarkerFaceColor','r');			%Plot BS  as square
title('Locations and Distribution of Users and BSs');
hold off

equipment = 50;         %Initial Investment - Equipment Cost
site_buildout = 70;         %Initial Investment - Site Buildout Cost
site_installation = 30;         %Initial Inveatment - Site Installation Cost
initial_cost = equipment + site_buildout + site_installation;
operation_maintenance = 3;          %Annual Operation and Maintenance Cost
site_lease = 10;         %Annual Site Lease
transmission_per_connection = 5;            %Annual Cost for Transmission to 1 connection
annual_cost = operation_maintenance + site_lease;
trc = transmission_per_connection * bs(2);         %Total transmission Cost for each BS
bs(3) = initial_cost + annual_cost + trc;          %Total charges for each BS
X = [initial_cost, annual_cost, trc];
figure,
pie(X,{'Initial','Annual','Transmission'});         %Plotting Pie Chart showing cost distribution per BS
title('OPEX distribution');