% Functions to estimates growth rates of each set of cells with the same name
% Relies on naming convention: 'A1_02_1_1_Phase Contrast_006.tif'
% where the last number before the tif (e.g. 006) stores the day

% plot a growth rate (for a single sample)
function modelGrowthRate(image_names,confluencies)
    modelFun =  @(p,x) 100./(1+exp(-p(1).*(x-p(2)))); % growth function (logistic growth)
    startParams = [.8, 4]; % Change?

    days = double(extractBetween(image_names,26,28));
    coefEsts = nlinfit(days, confluencies, modelFun, startParams); %non-linear fit (using LM opt.)    
    plotResults(image_names(1),days,confluencies,modelFun,coefEsts);  
end

function plotResults(name, days,values,modelFun, coeff)
    name = char(name);
    name = strrep(name,'_','-');
    plotTitle= ['Cell Growth for: ' name(1:end-8)];
    equation = ['Fitted Function: ' '$$ f(x) = 100/(1+e^{(' num2str(-1*coeff(1),3) ')(x+(' num2str(-1*coeff(2),3) '))}) $$'];
    plotTitle= [plotTitle ' | ' equation];

    minTime = days(1);
    maxTime = days(end);
    
    f = figure();
    figure(f); clf;
    figure(f); scatter(days,values,50,'filled','b'); 
    figure(f); xlim([minTime - 2,maxTime + 2]); figure(f); ylim([0,100]);
    figure(f); hold on; line([minTime:.1:maxTime], modelFun(coeff,[minTime:.1:maxTime]), 'Color','r'); hold off;
    figure(f); title(plotTitle,'Interpreter', 'latex','FontSize',20);
    figure(f); xlabel('Days'); figure(f); ylabel('Confluency');
    figure(f); legend('Estimated Confluencies','Fitted Logistic Function');
end