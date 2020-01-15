function f1 = plotSpindleFR(sp,params)
    names = {'abd_poll_longus_len','anconeus_len','bicep_lh_len','bicep_sh_len','brachialis_len','brachioradialis_len','coracobrachialis_len','deltoid_ant_len','deltoid_med_len','deltoid_pos_len','dorsoepitrochlearis_len','ext_carpi_rad_longus_len','ext_carp_rad_brevis_len','ext_carpi_ulnaris_len','ext_digitorum_len','ext_digiti_len','ext_indicis_len','flex_carpi_radialis_len','flex_carpi_ulnaris_len','flex_digit_profundus_len','flex_digit_superficialis_len','flex_poll_longus_len','infraspinatus_len','lat_dorsi_sup_len','lat_dorsi_cen_len','lat_dorsi_inf_len','palmaris_longus_len','pectoralis_sup_len','pectoralis_inf_len','pronator_quad_len','pronator_teres_len','subscapularis_len','supinator_len','supraspinatus_len','teres_major_len','teres_minor_len','tricep_lat_len','tricep_lon_len','tricep_sho_len'};

    if nargin > 1, assignParams(who,params); end % overwrite defaults
    
    for i = 1:length(sp(1,:,1))
        figure
        min1 = min(min(sp(:,i,:)));
        max1 = max(max(sp(:,i,:)));
        range1 = max1-min1;
        for j = 1:8
            switch j
                case 1
                    subplot(3,3,6)
                case 2
                    subplot(3,3,3)
                case 3
                    subplot(3,3,2)
                case 4
                    subplot(3,3,1)
                case 5
                    subplot(3,3,4)
                case 6
                    subplot(3,3,7)
                case 7
                    subplot(3,3,8)
                case 8
                    subplot(3,3,9)
            end
            
            plot(sp(:,i, j))
            ylim([min1-(.05*range1), max1 + (.05*range1)])
            
        end
        suptitle(names{i})
    end
end