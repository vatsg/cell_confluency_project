% Machine Learning growth rate predictor
function predictGrowthRate()
    clear; clc;

    modelFun =  @(p,x) 100./(1+exp(-p(1).*(x-p(2)))); % growth function (logistic growth)
    day_cut_off = 3; % last day to use when making predictions

    % Select which data set to use (confluency predictions)
    tables_used = ["./growth_rates/181005_124727_RB177 RB183 6WP.csv"]
    all_data_pts = getTableData(tables_used);

    total_squared_error = 0;
    for i = 1:size(all_data_pts,1) % make predictions on each image
        name = all_data_pts{i,1};
        days = all_data_pts{i,2};
        values = all_data_pts{i,3};
        
        [nnVals, nnCoeff] = getNearestNeighbor(all_data_pts, name, days, values, day_cut_off, modelFun); % uses nearest-neighbors to pick coeff. of closest neighbor
        predVals = modelFun(nnCoeff,days(day_cut_off+1:end)'); % make predictions
        total_squared_error = total_squared_error + (predVals - values(day_cut_off+1:end)').^2;
        
%         plotPredictions(days,values,nnVals,nnCoeff,day_cut_off);
    end
    avg_squared_error = total_squared_error / size(all_data_pts,1)
    table(days(day_cut_off+1:end),avg_squared_error','VariableNames',{'Predicted_Day','Avg_Squared_Error'})
end

% gets data from confluency table in ordering of days and values, by name
function data_pts = getTableData(tables)
    confluency_table = readtable(tables{1},'Delimiter','comma');
    for i = 2:numel(tables) % concatenate tables
        t = readtable(tables{i},'Delimiter','comma'); % input data
        confluency_table = vertcat(confluency_table,t);
    end
        
    concat_confluency_table = cell(size(confluency_table,1),2);
    concat_confluency_table(:,1) = strcat(confluency_table.Data_Source, '_', confluency_table.Image_Name);
    concat_confluency_table(:,2) = num2cell(confluency_table.Percent_Confluency);

    image_names = concat_confluency_table(:,1);
    temp_image_names = image_names;
    for i = 1:length(image_names)
        temp_image_names{i} = image_names{i}(1:end-7);
    end
    
    % get the confluency for a single day
    unique_temp_image_names = unique(temp_image_names);
    data_pts = cell(numel(unique_temp_image_names),3); % create output cell arr of appropriate size
    
    for i = 1:length(unique_temp_image_names)
        inds = find(contains(concat_confluency_table(:,1),unique_temp_image_names{i}));  % matching unique name
        name = unique_temp_image_names(i);
        days = str2num(cell2mat(extractBetween(confluency_table.Image_Name(inds),26,28))); % gets days as ints
        vals = confluency_table.Percent_Confluency(inds);
            
        % add to data_pts
        data_pts(i,1) = unique_temp_image_names(i);
        data_pts(i,2) = {days};
        data_pts(i,3) = {vals};
    end
end

% Gets coefficients of nearest neighbor look-up
function [nnVals, nnCoeff] = getNearestNeighbor(all_data_pts, image_name, days, values,day_cut_off,modelFun)
    all_data_pts(find(contains(all_data_pts(:,1),image_name)),:) = []; % remove current data
    tAllDays = all_data_pts(:,2);
    tAllVals = all_data_pts(:,3);
            
    [a,ind] = max(cellfun('length', tAllDays));
    numDataPts = numel(tAllDays);
    numLongestData = numel(tAllDays{ind});
    allDays = -1 * ones(numDataPts,numLongestData);
    allVals = -1 * ones(numDataPts,numLongestData);
    
    for i = 1:numel(tAllDays)
       tDays = tAllDays{i}';
       tVals = tAllVals{i}';
       
       allDays(i,1:numel(tDays)) = tDays;
       allVals(i,1:numel(tVals)) = tVals;
    end
        
    daysT = days(1:day_cut_off)'; % now cut off values so that we can make the predictions
    valuesT = values(1:day_cut_off)';
    allDaysT = allDays(:,1:day_cut_off);
    allValsT = allVals(:,1:day_cut_off);
    
    inds = find(ismember(allDaysT,daysT,'rows')); % re-compute this values
    nnInd = inds(knnsearch(allValsT(inds,:),valuesT,'K',3,'Distance','euclidean')); % find closest neighbor
    
    nnFitVals = mean(allVals(nnInd,:));
    
    % predict growth
    startParams = [.8, 4]; % Change?
    nnCoeff = nlinfit(allDays(nnInd(1),:), nnFitVals, modelFun, startParams); %non-linear fit (using LM opt.)        
    nnVals = allVals(nnInd,1:numel(values)); % nearest neighbor values
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