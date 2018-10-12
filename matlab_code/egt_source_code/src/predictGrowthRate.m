% Machine Learning growth rate predictor

function predictGrowthRate()
%     sdir = uigetdir(pwd,'Select Image Folder Path');
%     image_struct = dir([sdir '/' '*' 'Phase' '*tif']);
    modelFun =  @(p,x) 100./(1+exp(-p(1).*(x-p(2)))); % growth function (logistic growth)
    day_cut_off = 3; % last day to use when making predictions
    loader = load('./growth_rates/modeled_data.mat'); % use this for nearest neighbor lookup
    value_func_map = loader.value_func_map;

%     t1 = readtable('./growth_rates/confluency_rb137_4x.csv','Delimiter','comma'); % will test from here (leave one out)
%      t1 = readtable('./growth_rates/confluency_rb137_10x.csv','Delimiter','comma');
%     t1 = readtable('./growth_rates/confluency_rb182_4x.csv','Delimiter','comma');
    t1 = readtable('./growth_rates/confluency_rb182_10x.csv','Delimiter','comma');
    
    confluency = t1;
    image_names = confluency{:,1};

    temp_image_names = image_names;
    for i = 1:length(image_names)
        temp_image_names{i} = image_names{i}(1:end-7);
    end
    
    % get the confluency for a single day
    total_squared_error = 0;
    unique_temp_image_names = unique(temp_image_names);
    for i = 1:length(unique_temp_image_names)
        idx = strfind(confluency.Image_Name',unique_temp_image_names(i));
        index = find(~cellfun(@isempty,idx));
        
        values = round(confluency{index,2},4); % confluency estimates - the rounding is to match the rounding on the database
        days = double(extractBetween(string(image_names(index)),26,28)); % day estimate was taken on        
                
        [nnVals, nnCoeff] = getNearestNeighbor(value_func_map, days, values, day_cut_off); % uses nearest-neighbors to pick coeff. of closest neighbor
        predVals = modelFun(nnCoeff,days(day_cut_off+1:end)');
        total_squared_error = total_squared_error + (predVals - values(day_cut_off+1:end)').^2;
        
%         plotPredictions(days,values,nnVals,nnCoeff,day_cut_off);
    end
    avg_squared_error = total_squared_error / length(unique_temp_image_names);
    table(days(day_cut_off+1:end),avg_squared_error','VariableNames',{'Predicted_Day','Avg_Squared_Error'})
end

% Gets coefficients of nearest neighbor look-up
function [nnVals, nnCoeff] = getNearestNeighbor(value_func_map, days, values,day_cut_off)
    all_map_keys = keys(value_func_map)';
    allKeys = split(all_map_keys , ';');
    
    allDays = allKeys(:,1);
    allVals = allKeys(:,2);
    
    allDays = str2double(split(allDays,','));
    allVals = str2double(split(allVals,','));

    inds = find(ismember(allDays,days','rows')); % values to compare with (days need to match)
    match = find(ismember(allVals(inds,:),values','rows')); % find any exact matches
    
    allDays(match,:) = []; % remove any identical matches so that the test is valid
    allVals(match,:) = [];
    all_map_keys(match) = []; % need to remove this too so can match with model func
    
    daysT = days(1:day_cut_off); % now cut off values so we are missing some data
    valuesT = values(1:day_cut_off);
    allDaysT = allDays(:,1:day_cut_off);
    allValsT = allVals(:,1:day_cut_off);
    
    inds = find(ismember(allDaysT,daysT','rows')); % re-compute this values
    nnInd = inds(knnsearch(allValsT(inds,:),valuesT','Distance','euclidean')); % find closest neighbor
    
    nnCoeff = value_func_map(all_map_keys{nnInd}); % optimal coefficients 
    nnVals = allVals(nnInd,:); % nearest neighbor values
end

function plotPredictions(days,values,nnVals, nnCoeff,day_cut_off)
    modelFun =  @(p,x) 100./(1+exp(-p(1).*(x-p(2)))); % growth function (logistic growth)
    plotTitle = ['Growth Predictions with day ' num2str(day_cut_off) ' cut off date'];
    f = figure();
    figure(f); clf;
    figure(f); scatter(days(1:day_cut_off),values(1:day_cut_off),50,'filled','b'); 
    figure(f); hold on; scatter(days(day_cut_off+1:end),values(day_cut_off+1:end),50,'filled','r'); 
    figure(f); hold on; scatter(days,nnVals,50,'filled','g'); 
    figure(f); xlim([0,10]); figure(f); ylim([0,100]);
    figure(f); hold on; line([0:.1:10], modelFun(nnCoeff,[0:.1:10]), 'Color','black'); hold off;
    figure(f); title(plotTitle);
    figure(f); xlabel('Days'); figure(f); ylabel('Confluency');
    figure(f); legend('Given Confluencies','Not Given Confluencies','Nearest Neighbor Confluencies','Fitted Logistic Function');
end