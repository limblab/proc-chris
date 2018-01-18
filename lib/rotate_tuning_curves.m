function [figure_handles, output_data]=rotate_tuning_curves(active, passive,bins)
% Find scaling and rotation between two tuning curves in PM and DL
% workspaces

%% Get data to fit

% get relevant data
tuning_PM = active;
tuning_DL = passive;
FR_PM = tuning_PM.binnedResponse;
FR_DL = tuning_DL.binnedResponse;
angs_PM = bins;
angs_DL = bins;

%% Convert to complex polar representation
polar_PM_curve = [FR_PM.*exp(1i*angs_PM)]';
polar_DL_curve = [FR_DL.*exp(1i*angs_DL)]';

unit_ids = tuning_PM.signalID;
%% Fit data
for i = 1:length(unit_ids(:,1))
%     tbl = table(polar_PM_curve(:,i),polar_DL_curve(:,i),'VariableNames',{'PM_curve','DL_curve'});
%     lm = fitlm(tbl,'DL_curve ~ PM_curve - 1');
%     complex_scale_factor(1,i) = lm.Coefficients.Estimate;
%     
%     complex_scale_manual(1,i) = (polar_PM_curve(:,i)'*polar_PM_curve(:,i))\polar_PM_curve(:,i)'*(polar_DL_curve(:,i));

    % Fit with optimization
    real_imag_scale = fminsearch(@(x) (find_ms_curve_dist(polar_DL_curve(:,i),(x(1)+1i*x(2))*polar_PM_curve(:,i)))^2,rand(2,1));
    complex_scale_factor(1,i) = real_imag_scale(1)+1i*real_imag_scale(2);
    
    disp(['Done with ' num2str(i)])
end
output_data.complexScale = complex_scale_factor;
output_data.scale_factor = abs(complex_scale_factor);
output_data.rot_factor = angle(complex_scale_factor);

%% Plot fits
figure_handles = [];
unit_ids = tuning_PM.signalID;
for i = 1:length(unit_ids(:,1))
    fig = figure('name',['channel_' num2str(unit_ids(i,1)) '_unit_' num2str(unit_ids(i,2)) '_tuning_plot']);
    figure_handles = [figure_handles fig];
    
    % polar tuning curve
    subplot(211)
    max_rad = max(abs([polar_PM_curve(:,i);polar_DL_curve(:,i)]));
    h=polar(0,max_rad);
    set(h,'color','w')
    hold on
    h=polar(angle(repmat(polar_PM_curve(:,i),2,1)),abs(repmat(polar_PM_curve(:,i),2,1)));
    set(h,'linewidth',2,'color',[0.6 0.5 0.7])
    hold on
    h=polar(angle(repmat(polar_DL_curve(:,i),2,1)),abs(repmat(polar_DL_curve(:,i),2,1)));
    set(h,'linewidth',2,'color',[1 0 0])
    h=polar(angle(repmat(polar_PM_curve(:,i)*complex_scale_factor(i),2,1)),abs(repmat(polar_PM_curve(:,i)*complex_scale_factor(i),2,1)));
    set(h,'linewidth',2,'color',[0 1 0])
    title 'Wrapped tuning curves'
    
    % flat tuning curve
    subplot(212)
    [rays_PM,mags_PM] = get_full_curve(polar_PM_curve(:,i));
    [rays_DL,mags_DL] = get_full_curve(polar_DL_curve(:,i));
    [rays_fit,mags_fit] = get_full_curve(polar_PM_curve(:,i)*complex_scale_factor(i));
    h=plot(180/pi*rays_PM,mags_PM);
    set(h,'linewidth',2,'color',[0.6 0.5 0.7])
    hold on
    h=plot(180/pi*rays_DL,mags_DL);
    set(h,'linewidth',2,'color',[1 0 0])
    h=plot(180/pi*rays_fit,mags_fit);
    set(h,'linewidth',2,'color',[0 1 0])
    
    set(gca,'xlim',[-180,180],'xtick',[-180 -90 0 90 180],'tickdir','out','box','off');
    xlabel 'Movement direction (deg)'
    ylabel 'Average spikes per 50 ms time bin'
    legend('Active','Pas','Rotated/Scaled Active curve')
    legend('boxoff')
    title 'Unwrapped tuning curves'
    
%     saveas(fig,['channel_' num2str(unit_ids(i,1)) '_unit_' num2str(unit_ids(i,2)) '_tuning_plot' '.png'])
end



end

function [dist] = find_ms_curve_dist(curve1,curve2)
    %% add up distances along many rays
    % pad curves with wrap-around term for full curve
    curve1_wrap = [curve1(end);curve1];
    curve2_wrap = [curve2(end);curve2];
    
    % find full curves and remove duplicate point
    interpolater = linspace(1,length(curve1_wrap),length(curve1_wrap)*500+1)';
    interpolater = interpolater(2:end);
    curve1_full = interp1(curve1_wrap,interpolater);
    curve2_full = interp1(curve2_wrap,interpolater);
    
    % get sorted curves in angles and magnitudes
    curve1_sort = sortrows([angle(curve1_full) abs(curve1_full)],1);
    curve2_sort = sortrows([angle(curve2_full) abs(curve2_full)],1);
    
    % pad sorted curves with endpoints to wrap around
    curve1_sort_padded = [curve1_sort(end,:);curve1_sort;curve1_sort(1,:)];
    curve2_sort_padded = [curve2_sort(end,:);curve2_sort;curve2_sort(2,:)];
    curve1_sort_padded(1,1) = curve1_sort_padded(1,1)-2*pi;
    curve2_sort_padded(1,1) = curve2_sort_padded(1,1)-2*pi;
    curve1_sort_padded(end,1) = curve1_sort_padded(end,1)+2*pi;
    curve2_sort_padded(end,1) = curve2_sort_padded(end,1)+2*pi;
    
    % find distance at many rays
    rays = linspace(-pi,pi,10000)';
    rays = rays(2:end);
    curve1_mags = interp1(curve1_sort_padded(:,1),curve1_sort_padded(:,2),rays);
    curve2_mags = interp1(curve2_sort_padded(:,1),curve2_sort_padded(:,2),rays);
    dist = mean((curve1_mags-curve2_mags).^2);
end

function [rays,mags] = get_full_curve(curve)
    % pad curves with wrap-around term for full curve
    curve_wrap = [curve(end);curve];
    
    % find full curves and remove duplicate point
    interpolater = linspace(1,length(curve_wrap),length(curve_wrap)*500+1)';
    interpolater = interpolater(2:end);
    curve_full = interp1(curve_wrap,interpolater);
    
    % get sorted curves in angles and magnitudes
    curve_sort = sortrows([angle(curve_full) abs(curve_full)],1);
    
    % pad sorted curves with endpoints to wrap around
    curve_sort_padded = [curve_sort(end,:);curve_sort;curve_sort(1,:)];
    curve_sort_padded(1,1) = curve_sort_padded(1,1)-2*pi;
    curve_sort_padded(end,1) = curve_sort_padded(end,1)+2*pi;
    
    % find distance at many rays
    rays = linspace(-pi,pi,9)';
%     rays = rays(2:end);
    mags = interp1(curve_sort_padded(:,1),curve_sort_padded(:,2),rays);
end