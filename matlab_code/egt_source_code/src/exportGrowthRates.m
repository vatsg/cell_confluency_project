% Code to export and fit growth rates for many cells

function exportGrowthRates(image_names, confluencies, export_growths_path)
    startParams = [.8, 4]; % Change?
    modelFun =  @(p,x) 100./(1+exp(-p(1).*(x-p(2)))); % growth function (logistic growth)

    if exist('./growth_rates/modeled_data.mat') ~= 0
        loader = load('./growth_rates/modeled_data.mat');
        value_func_map = loader.value_func_map;
    else
        value_func_map = containers.Map('KeyType','char','ValueType','any');
    end
    
    temp_image_names = image_names;
    
    % Identify each set of images with the same name
    for i = 1:length(image_names)
        temp_image_names{i} = image_names{i}(1:end-7);
    end
    
    unique_temp_image_names = unique(temp_image_names);
    growthRates = cell(1,length(unique_temp_image_names));
    
    for i = 1:length(unique_temp_image_names)
        ind = find(contains(image_names, unique_temp_image_names(i))); % group all images of the same well
        values = confluencies(ind); % confluency estimates
        days = double(extractBetween(image_names(ind),26,28)); % day estimate was taken on
        growthRates{i} = estimateGrowthRate(values, days, value_func_map, modelFun, startParams);
        plotResults(unique_temp_image_names(i),days,values,modelFun, growthRates{i},export_growths_path);
    end
    
    % save value_func_map to file (overwrite if already exists)
    save('./growth_rates/modeled_data.mat','value_func_map');
end

% Input confluency estimate values and days they were recorded on
% Output estimated growth rate
function coefEsts = estimateGrowthRate(values, days, value_func_map, modelFun, startParams)    
    % keys should be confluency estimates, values should be params
    if max(values) >= 0 % TODO: Change this ? How to use an NN approach? find growth rate if more than 60% confluent
        keyd = sprintf('%.4f,',days'); keyd = keyd(1:end-1);
        keyv = sprintf('%.4f,',values'); keyv = keyv(1:end-1);
        key = [keyd ';' keyv];
        if isKey(value_func_map, key)
            coefEsts = value_func_map(key);
        else
            coefEsts = nlinfit(days, values, modelFun, startParams); %non-linear fit (using LM opt.)
            value_func_map(key) = coefEsts;
        end     
    end    
end

% Plot results and Save (plot doesn't actually display)
function plotResults(name, days,values,modelFun, coeff,export_growths_path)
    name = char(name);
    name = name(1:end-1);
    name = strrep(name,'_','-')
    plotTitle= ['Cell Growth for: ' name];
    equation = ['Fitted Function: ' '$$ f(x) = 100/(1+e^{(' num2str(-1*coeff(1),3) ')(x+(' num2str(-1*coeff(2),3) '))}) $$'];
    plotTitle= [plotTitle ' | ' equation];
    
    minTime = days(1);
    maxTime = days(end);

    f = figure();
    figure(f); clf;
    figure(f); scatter(days,values,50,'filled','b'); 
    figure(f); xlim([minTime - 2,maxTime + 2]); figure(f); ylim([0,100]);
    figure(f); hold on; line([minTime:.1:maxTime], modelFun(coeff,[minTime:.1:maxTime]), 'Color','r'); hold off;
    figure(f); title(plotTitle,'Interpreter', 'latex');
    figure(f); xlabel('Days'); figure(f); ylabel('Confluency');
    figure(f); legend('Estimated Confluencies','Fitted Logistic Function');

    saveas(f,[export_growths_path name '.png']);
    close(figure(f));
end