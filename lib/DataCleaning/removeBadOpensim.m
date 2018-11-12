function td = removeBadOpensim(td, params)
    for i = 1:length(td)
        trial = td(i);
        opensim = trial.opensim;
        plot(.05:.05:.05*length(opensim(:,4)), opensim(:,4))
        pause
    end
end