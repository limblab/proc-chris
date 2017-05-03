figure
for  corRow=4000:length(all_medians2(1,1,:))   
        scatter3(all_medians2(1,1,corRow), all_medians2(1,2,corRow), all_medians2(1,3,corRow), 'g')
        hold on
        scatter3(all_medians2(2,1,corRow), all_medians2(2,2,corRow), all_medians2(2,3,corRow), 'b')
        scatter3(all_medians2(3,1,corRow), all_medians2(3,2,corRow), all_medians2(3,3,corRow), 'r')
        scatter3(all_medians2(4,1,corRow), all_medians2(4,2,corRow), all_medians2(4,3,corRow), 'y')     
        scatter3(all_medians2(5,1,corRow), all_medians2(5,2,corRow), all_medians2(5,3,corRow), 'g')
        scatter3(all_medians2(6,1,corRow), all_medians2(6,2,corRow), all_medians2(6,3,corRow), 'g')
        scatter3(all_medians2(7,1,corRow), all_medians2(7,2,corRow), all_medians2(7,3,corRow), 'b')
        scatter3(all_medians2(8,1,corRow), all_medians2(8,2,corRow), all_medians2(8,3,corRow), 'r')
        scatter3(all_medians2(9,1,corRow), all_medians2(9,2,corRow), all_medians2(9,3,corRow), 'g')
        scatter3(all_medians2(10,1,corRow), all_medians2(10,2,corRow), all_medians2(10,3,corRow), 'r')
        view(2)
        title(num2str(corRow))
        pause(.01)
end