%This script plots the original points
%and can be used for inputting the starting locations of the markers

%Note that yellow is plotted in cyan for visibility

%% User input (set frames you're looking at)

frames=1:5;


%% Rename data from loaded file (if it's in the new format)
if exist('color_coords_allframes','var')
    color1=color_coords_allframes(:,1)';
    color2=color_coords_allframes(:,2)';
    color3=color_coords_allframes(:,3)';
    color4=color_coords_allframes(:,4)';
end


%% Plot

n=length(color1);
xlims=[-.4 .5];
ylims=[-.4 .4]; 
zlims=[.8 1.5];

figure;

xlim(zlims)
ylim(xlims)
zlim(ylims)
set(gca,'NextPlot','replacechildren');


for i=frames
    temp=color1{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'b')
    hold on;
    temp=color2{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'g')
    temp=color3{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'r')
    temp=color4{i};
    x=temp(1:end/3);
    y=temp(end/3+1:2*end/3);
    z=temp(2*end/3+1:end);
    scatter3(z,x,y,'c')
    hold off
    title(i);
    xlabel('z')
    ylabel('x')
    zlabel('y')
    xlim(zlims)
    ylim(xlims)
    zlim(ylims)
%     pause(.03)
    pause;
end