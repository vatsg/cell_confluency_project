% Disclaimer:  IMPORTANT:  This software was developed at the National Institute of Standards and Technology by employees of the Federal Government in the course of their official duties. Pursuant to title 17 Section 105 of the United States Code this software is not subject to copyright protection and is in the public domain. This is an experimental system. NIST assumes no responsibility whatsoever for its use by other parties, and makes no guarantees, expressed or implied, about its quality, reliability, or any other characteristic. We would appreciate acknowledgment if the software is used. This software can be redistributed and/or modified freely provided that any derivative works bear some notice that they are derived from it, and any modified versions bear some notice that they have been modified.

% OPTIMAL PARAMETERS 
% 180328_121909_GMP047, 180328_125817_GMP007 P1-P2, 180404_121829_GMP007, 180404_123306_GMP087
% 4x : MCA = 650px, FHST = 500px, Erosion = 1, Dilation = 0, Secondary Erosion = 4, Greedy = 0
% 10x: MCA = 2750px, FHST = 2000px, Erosion = 1, Dilation = 0, Seondary Erosion = 4, Greedy = 0

% 180328_123423_RB137, 180328_124322_RB049-RB182, 180404_124147_RB037
% 4x : MCA = 650px, FHST = 500px, Erosion = 1, Dilation = 0, Secondary Erosion = 2, Greedy = 0
% 10x: MCA = 2750px, FHST = 2000px, Erosion = 1, Dilation = 0, Secondary Erosion = 2, Greedy = 0

% 181005_124727_RB177 RB183 6WP: MCA: 3000, FHST: 2750, Erosion = 2, Dilation = 2 Seondary Erosion: 6, Greedy = -1

function Edge_Detection_GUI_v1()
clear; clc;

%  Global Parameters
%-----------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------

raw_images_path = [pwd filesep 'test' filesep];
raw_images_common_name = '';
raw_image_files = [];
nb_frames = 0;
current_frame_nb = 1;

morphological_operations = {'None','Dilate','Erode','Close','Open'};
greedy_range = 50;

grayscale_image = [];
foreground_mask = [];
I1 = [];

colormap_options = {'gray','jet','hsv','hot','cool'};
colormap_selected_option = colormap_options{1};

contour_color_options = {'Red', 'Green', 'Blue', 'Black', 'White'};
countour_color_selected_opt = contour_color_options{1};

% Figure setup
%-----------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------
GUI_Name = 'Edge Detection';

% if the GUI is already open, don't open another copy, bring the current copy to the front
open_fig_handle = findobj('type', 'figure', 'name', GUI_Name);
if ~isempty(open_fig_handle)
    %     figure(open_fig_handle);
    %     return;
    close(open_fig_handle);
end

% Define General colors
lt_gray = [0.86,0.86,0.86];
dark_gray = [0.7,0.7,0.7];
green_blue = [0.0,0.3,0.4];


%   Get user screen size
SC = get(0, 'ScreenSize');
MaxMonitorX = SC(3);
MaxMonitorY = SC(4);

%   Set the figure window size values
main_tabFigScale = 0.5;          % Change this value to adjust the figure size
gui_ratio = 0.6;
gui_width = round(MaxMonitorX*main_tabFigScale);
gui_height = gui_width*gui_ratio;
% MaxWindowY = round(MaxMonitorY*main_tabFigScale);
% if MaxWindowX <= MaxWindowY, MaxWindowX = round(1.6*MaxWindowY); end
offset = 0;
if (SC(2) ~= 1)
    offset = abs(SC(2));
end
XPos = (MaxMonitorX-gui_width)/2 - offset;
YPos = (MaxMonitorY-gui_height)/2 + offset;


hctfig = figure(...
    'units', 'pixels',...
    'Position',[ XPos, YPos, gui_width, gui_height ],...
    'Name',GUI_Name,...
    'NumberTitle','off',...
    'CloseRequestFcn', @closeAllGuis);

% other guis (mitotic, border, seed
    function closeAllGuis(varargin)
        
        fh = findobj('type','figure','name','Save Images');
        close(fh);
        closereq();
        
    end


% Create main menu tab, 'Foreground Segmentation'
main_panel = uipanel('Units', 'normalized', 'Parent', hctfig,'Visible', 'on', 'Backgroundcolor', lt_gray,'BorderWidth',0,'Position', [0,0,1,1]);


%-----------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------
% Edge Detection
%-----------------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------------
foreground_min_object_size = 250;
foreground_display_contour = false;
foreground_display_raw_image = false;
foreground_display_labeled_image = false;
foreground_display_labeled_text = false;
foreground_strel_disk_radius = 2;
foreground_morph_operation = morphological_operations{2};
foreground_min_hole_size = 2*foreground_min_object_size;
adjust_contrast_raw_image = 0;
erosion_val = 1;
dilation_val = 0;

%-----------------------------------------------------------------------------------------
% Main Display Tabs
%-----------------------------------------------------------------------------------------
DispLabels = {'Cell Segmentation','Cell Growth'};
display_panel = sub_panel(main_panel, [0.01,0.02,.7,.955], ['Image: <' '>'], 'lefttop', green_blue, lt_gray, 14, 'serif');
growthRateTab = push_button(main_panel, [.575 0.960 0.135 0.04], 'Show Growth Rate', 'center', 'k', lt_gray, 0.5, 'serif', 'bold', 'off', {@show_growth_callback});
exportGrowthsTab = push_button(main_panel, [.440 0.960 0.135 0.04], 'Export Growth Rates', 'center', 'k', lt_gray, 0.5, 'serif', 'bold', 'off', {@export_growth_callback});

%-----------------------------------------------------------------------------------------
% Option Tabs
%-----------------------------------------------------------------------------------------
TabLabels = {'Image Folders'; 'Params';};

% Number of tabs to be generated
NumberOfTabs = length(TabLabels);

h_tabpanel = zeros(NumberOfTabs,1);
h_tabpb = zeros(NumberOfTabs,1);

tab_label_text_size = 0.5;

% Create options menu tab, 'Image Folder'
h_tabpanel(1) = sub_panel(main_panel, [0.72,0.02,.27,.93], '', 'lefttop', green_blue, lt_gray, 14, 'serif');
h_tabpb(1) = push_button(main_panel, [.72 0.95 0.135 0.05], TabLabels(1), 'center', 'k', lt_gray, tab_label_text_size, 'serif', 'bold', 'on', {@first_tab_callback} );

% Create options menu tab, 'Params'
h_tabpanel(2) = sub_panel(main_panel, [0.72,0.02,.27,.93], '', 'lefttop', green_blue, lt_gray, 14, 'serif');
h_tabpb(2) = push_button(main_panel, [.855 0.95 0.135 0.05], TabLabels(2), 'center', 'k', dark_gray, tab_label_text_size, 'serif', 'bold', 'off', {@second_tab_callback} );
set(h_tabpanel(2), 'Visible', 'off');

axes('Parent', h_tabpanel(1), 'Units', 'normalized', 'Position', [.05 0 .9 .25]);
axis image;
axis off

try
    imshow('NIST_Logo.tif');
catch err
    warning('unable to load and show NIST logo');
end


function first_tab_callback(varargin)
    set(h_tabpb(1), 'Backgroundcolor', dark_gray);
    set(h_tabpb(2), 'Backgroundcolor', lt_gray);

    set(h_tabpanel(1), 'Visible', 'on');
    set(h_tabpanel(2), 'Visible', 'off');

end

function second_tab_callback(varargin)
    set(h_tabpb(1), 'Backgroundcolor', lt_gray);
    set(h_tabpb(2), 'Backgroundcolor', dark_gray);

    set(h_tabpanel(1), 'Visible', 'off');
    set(h_tabpanel(2), 'Visible', 'on');

end

function show_growth_callback(varargin)
%     figure(4); 
      curr_name = raw_image_files(current_frame_nb).name;
      base_name = curr_name(1:end-7); % without days
      all_names = {raw_image_files(:).name}';
      
      image_names = [];
      
      for i = 1:length(all_names) % get all matching images for that cell
        name = all_names{i};
        if strfind(name,base_name)
            image_names = [image_names, string(name)];
        end
      end
         
      confluencies = zeros(1,length(image_names));
      for i = 1:length(image_names)
        name = char(image_names(i));
        grayscale_image = imread([raw_images_path name]);
        I1 = double(grayscale_image);
        upper_hole_size_bound = foreground_min_hole_size;
        foreground_mask = EGT_Segmentation(I1, foreground_min_object_size, upper_hole_size_bound, greedy_slider_num,erosion_val,dilation_val);

        foreground_morph_operation = lower(regexprep(foreground_morph_operation, '\W', ''));
        foreground_mask = morphOp(grayscale_image, foreground_mask, foreground_morph_operation, foreground_strel_disk_radius);       
        confluencies(i) = getConfluency(foreground_mask);
      end
      
      modelGrowthRate(image_names,confluencies);
end

function export_growth_callback(varargin)
    % Create figure, if found return, this prevents opening multiples of the same figure
    % Create figure in case not found
    if numel(findobj('type','figure','name','Export Growth')) > 0
        export_fig = findobj('type','figure','name','Export Growth');
        figure(export_fig)
    else 
        export_fig = figure(...
            'units', 'pixels',...
            'Position', [ (MaxMonitorX-gui_width*0.3)/2 - offset, (MaxMonitorY-gui_height*0.5)/2 + offset, gui_width*0.3, gui_height*0.5 ], ...
            'Name','Export Growth',...
            'NumberTitle','off',...
            'Menubar','none',...
            'Toolbar','none',...
            'Resize', 'on');        
    end
            
    content_panel = sub_panel(export_fig, [0 0 1 1], '', 'lefttop', green_blue, lt_gray, 14, 'serif');

    save_common_name='Export Growth';
    label(content_panel, [.03 .68 .2 .09], 'Name:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    save_common_name_edit = editbox(content_panel, [.27 .69 .7 .09], save_common_name, 'left', 'k', 'w', .6, 'normal');    
    
    export_range = 'All';        
    label(content_panel, [.03 .57 .2 .09], 'Range:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    export_range_edit = editbox(content_panel, [.27 .58 .7 .09], export_range, 'left', 'k', 'w', .6, 'normal');
    label(content_panel, [.27 .49 .7 .09], 'i.e. - All or subset 1,2,3:7,12', 'left', 'k', lt_gray, .45, 'sans serif', 'normal');
    
    push_button(content_panel, [.01 .01 .49 .09], 'Export Growth', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on', {@export_callback});
    push_button(content_panel, [.5 .01 .49 .09], 'Cancel', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on', {@cancel_export_callback});
   
    function export_callback(varargin)
        export_range = get(export_range_edit, 'String');
        export_growths(export_range, save_common_name);
        if ishandle(export_fig), close(export_fig); end
    end
   
    function cancel_export_callback(varargin)
         if ishandle(export_fig), close(export_fig); end
    end

end

function export_growths(range, save_name)
    % directory
    sdir = uigetdir(pwd,'Select Export Path');
    if sdir ~= 0
        try
            h = msgbox('Working...');
            nb_frames_temp = nb_frames;
            
            export_growths_path = validate_filepath(sdir);
            print_to_command(['Exporting Growth Images to: ' export_growths_path]);
                            
            if(strcmp(range, 'All'))
                range = '0';
            end

            images_to_export = str2num(range); %#ok<ST2NM>    
            % make sure images_to_export is valid
            images_to_export(images_to_export > nb_frames_temp) = [];
            if ~isempty(images_to_export) && any(images_to_export > 0)
                nb_frames_temp = numel(images_to_export);
            else
                images_to_export = 1:nb_frames_temp; % export all
                nb_frames_temp = numel(images_to_export);
            end
            
            upper_hole_size_bound = foreground_min_hole_size;
            zero_pad = num2str(length(num2str(nb_frames_temp)));
            
            print_update(1, 1, nb_frames_temp);
            
            % get growth models and save results
            confluencies = zeros(nb_frames_temp,1);
            image_names = strings(nb_frames_temp,1);
            for i = 1:nb_frames_temp
                
                print_update(2,i,nb_frames_temp);
                raw_image = imread([raw_images_path raw_image_files(images_to_export(i)).name]);

                I1 = double(raw_image);
                BW = EGT_Segmentation(I1, foreground_min_object_size, upper_hole_size_bound, greedy_slider_num,erosion_val,dilation_val);

                foreground_morph_operation = lower(regexprep(foreground_morph_operation, '\W', ''));
                BW = morphOp(grayscale_image, BW, foreground_morph_operation, foreground_strel_disk_radius);

                % Govin: Add confluency estimates and names to array
                confluencies(i) = getConfluency(BW);
                image_names(i) = string(raw_image_files(images_to_export(i)).name);
                %                                                
            end
            
            exportGrowthRates(image_names,confluencies, export_growths_path); % export and save plots of growth
            
            if ishandle(h), close(h); end
            
        catch err
            if (strcmp(err.identifier,'validate_filepath:notFoundInPath')) || ...
                    (strcmp(err.identifier,'validate_filepath:argChk'))
                errordlg('Invalid directory selected');
                return;
            else
                rethrow(err);
            end
        end
    end     
end

%-----------------------------------------------------------------------------------------
% Data Panel
%-----------------------------------------------------------------------------------------

component_height = .05;

label(h_tabpanel(1), [.01 .91 .99 component_height], 'Raw Images Path:', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
input_dir_editbox = editbox(h_tabpanel(1), [.01 .87 .98 component_height], raw_images_path, 'left', 'k', 'w', .6, 'normal');
push_button(h_tabpanel(1), [.5 .815 .485 component_height], 'Browse', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on',  {@choose_raw_images_callback} );

label(h_tabpanel(1), [.01 .73 .95 .05], 'Raw Common Name:', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
common_name_editbox = editbox(h_tabpanel(1), [.01 .69 .98 component_height], '', 'left', 'k', 'w', .6, 'normal');

 function choose_raw_images_callback(varargin)
        % get directory
        sdir = uigetdir(pwd,'Select Image(s)');
        if sdir ~= 0
            try
                raw_images_path = validate_filepath(sdir);
            catch err
                if (strcmp(err.identifier,'validate_filepath:notFoundInPath')) || ...
                        (strcmp(err.identifier,'validate_filepath:argChk'))
                    errordlg('Invalid directory selected');
                    return;
                else
                    rethrow(err);
                end
            end
            set(input_dir_editbox, 'String', raw_images_path);
        end
 end


push_button(h_tabpanel(1), [.1 .5 .8 1.5*component_height], 'Load Images', 'center', 'k', dark_gray, 0.6, 'sans serif', 'bold', 'on',  {@initImages} );


%-----------------------------------------------------------------------------------------
% Params Panel
%-----------------------------------------------------------------------------------------

label(h_tabpanel(2), [.03 .93 .5 component_height], 'Min Cell Area', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
Foreground_Options_min_object_size_edit = editbox_check(h_tabpanel(2), [.05 .89 .3 component_height], num2str(foreground_min_object_size), 'left', 'k', 'w', .6, 'normal', @Foreground_Options_min_object_size_Callback);
label(h_tabpanel(2), [.35 .885 .1 component_height], 'px', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');

    function bool = Foreground_Options_min_object_size_Callback(varargin)
        bool = false;
        temp = str2double(get(Foreground_Options_min_object_size_edit, 'String'));
        if isnan(temp) || temp < 0
            errordlg('Invalid Min Object Size');
            return;
        end
        foreground_min_object_size = temp;
        bool = true;
    end


label(h_tabpanel(2), [.51 .93 .7 component_height], 'Fill Holes Under', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
Foreground_Options_min_hole_size_edit = editbox_check(h_tabpanel(2), [.53 .89 .3 component_height], num2str(foreground_min_hole_size), 'left', 'k', 'w', .6, 'normal', @Foreground_Options_min_hole_size_Callback);
label(h_tabpanel(2), [.83 .885 .1 component_height], 'px', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');

    function bool = Foreground_Options_min_hole_size_Callback(varargin)
        bool = false;
        temp = str2double(get(Foreground_Options_min_hole_size_edit, 'String'));
        if isnan(temp) || temp < 0
            errordlg('Invalid Min Hole Size');
            return;
        end
        foreground_min_hole_size = temp;
        bool = true;
    end

%%%

label(h_tabpanel(2), [.03 .83 .5 component_height], 'Erosion', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
erosion_options_edit = editbox_check(h_tabpanel(2), [.05 .79 .3 component_height], num2str(erosion_val), 'left', 'k', 'w', .6, 'normal', @Foreground_Options_Erosion_Callback);
label(h_tabpanel(2), [.35 .785 .1 component_height], 'rad', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');

    function bool = Foreground_Options_Erosion_Callback(varargin)
        bool = false;
        temp = str2double(get(erosion_options_edit, 'String'));
        if isnan(temp) || temp < 0
            errordlg('Invalid Min Object Size');
            return;
        end
        erosion_val = temp;
        bool = true;
    end

label(h_tabpanel(2), [.51 .83 .7 component_height], 'Dilation', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
dilation_options_edit = editbox_check(h_tabpanel(2), [.53 .79 .3 component_height], num2str(dilation_val), 'left', 'k', 'w', .6, 'normal', @Foreground_Options_Dilation_Callback);
label(h_tabpanel(2), [.83 .785 .1 component_height], 'rad', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');


    function bool = Foreground_Options_Dilation_Callback(varargin)
        bool = false;
        temp = str2double(get(dilation_options_edit, 'String'));
        if isnan(temp) || temp < 0
            errordlg('Invalid Min Hole Size');
            return;
        end
        dilation_val = temp;
        bool = true;
    end


label(h_tabpanel(2), [.05 .71 .95 component_height], 'Additional Morphological Operation', 'left', 'k', lt_gray, .55, 'sans serif', 'normal');
Foreground_Options_morph_dropdown = popupmenu(h_tabpanel(2), [.05 .67 .91 component_height], morphological_operations, 'k', 'w', .6, 'normal', @Foreground_Options_morph_Callback);
set(Foreground_Options_morph_dropdown, 'value',1);

    function Foreground_Options_morph_Callback(varargin)
        temp = get(Foreground_Options_morph_dropdown, 'value');
        foreground_morph_operation = morphological_operations{temp};
    end



label(h_tabpanel(2), [.15 .61 .5 component_height], 'with radius:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
Foreground_Options_strel_radius_edit = editbox_check(h_tabpanel(2), [.7 .615 .265 component_height], num2str(foreground_strel_disk_radius), 'right', 'k', 'w', .6, 'normal', @Foreground_Options_strel_radius_Callback);

    function bool = Foreground_Options_strel_radius_Callback(varargin)
        bool = false;
        temp = round(str2double(get(Foreground_Options_strel_radius_edit, 'string')));
        if temp < 0
            errordlg('Invalid strel radius');
            return;
        end
        foreground_strel_disk_radius = temp;
        bool = true;
    end


label(h_tabpanel(2), [.05 .55 .95 component_height], 'Greedy', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');

% Create Slider for image display
greedy_slider_num = 0;
Foreground_Options_greedy_edit = uicontrol('style','slider',...
    'Parent',h_tabpanel(2),...
    'unit','normalized',...
    'Min',-greedy_range,'Max',greedy_range,'Value',greedy_slider_num, ...
    'position',[.05 .5 .8 component_height],...
    'SliderStep', [1, 1]/(greedy_range - -greedy_range), ...  % Map SliderStep to whole number, Actual step = SliderStep * (Max slider value - Min slider value)
    'callback',{@greedySliderCallback});

slider_num_label = label(h_tabpanel(2), [.85 .51 .15 component_height], greedy_slider_num, 'center', 'k', lt_gray, .6, 'sans serif', 'normal');
    
    function greedySliderCallback(varargin)
        greedy_slider_num = ceil(get(Foreground_Options_greedy_edit, 'value'));
        set(slider_num_label, 'String', num2str(greedy_slider_num));
    end

push_button(h_tabpanel(2), [.1 .43 .78 .06], 'Update Preview', 'center', 'k', dark_gray, 0.5, 'sans serif', 'bold', 'on', {@Foreground_Display_update_image});

label(h_tabpanel(2), [.05 .34 .95 component_height], 'ColorMap:', 'left', 'k', lt_gray, .6, 'sans serif', 'normal');
OS_Options_colormap_dropdown = popupmenu(h_tabpanel(2), [.05 .3 .91 component_height], colormap_options, 'k', 'w', .6, 'normal', @OS_Options_colormap_Callback);
    function OS_Options_colormap_Callback(varargin)
        temp = get(OS_Options_colormap_dropdown, 'value');
        colormap_selected_option = colormap_options(temp);
        colormap_selected_option = colormap_selected_option{1};
        update_display_image();
    end



Foreground_Display_labeled_image_checkbox = checkbox(h_tabpanel(2), [.05 .24 .45 component_height], 'Label Image', 'center', 'k', lt_gray, .6, 'sans serif', 'normal', {@Foreground_Display_labeled_image_checkbox_Callback});
    function Foreground_Display_labeled_image_checkbox_Callback(varargin)
        foreground_display_labeled_image = logical(get(Foreground_Display_labeled_image_checkbox, 'value'));
        if foreground_display_labeled_image
            set(Foreground_Display_labeled_text_checkbox, 'enable', 'on');
            set(contour_color_dropdown, 'enable', 'off');
        else
            set(Foreground_Display_labeled_text_checkbox, 'enable', 'off');
            foreground_display_labeled_text = false;
            set(Foreground_Display_labeled_text_checkbox, 'value', foreground_display_labeled_text);
            set(contour_color_dropdown, 'enable', 'on');
        end
        update_label_image();
    end

Foreground_Display_labeled_text_checkbox = checkbox(h_tabpanel(2), [.53 .24 .45 component_height], 'Show Labels', 'center', 'k', lt_gray, .6, 'sans serif', 'normal', {@Foreground_Display_labeled_text_checkbox_Callback});
    function Foreground_Display_labeled_text_checkbox_Callback(varargin)
        foreground_display_labeled_text = logical(get(Foreground_Display_labeled_text_checkbox, 'value'));
        update_display_image();
    end
set(Foreground_Display_labeled_text_checkbox, 'enable', 'off');



Foreground_Display_contour_checkbox = checkbox(h_tabpanel(2), [.05 .19 .54 component_height], 'Display Contour', 'center', 'k', lt_gray, .6, 'sans serif', 'normal', {@Foreground_Display_contour_checkbox_Callback});
    function Foreground_Display_contour_checkbox_Callback(varargin)
        foreground_display_contour = logical(get(Foreground_Display_contour_checkbox, 'value'));
        if(nb_frames <= 0)
            return;
        else 
            update_display_image
        end
            
    end

contour_color_dropdown = popupmenu(h_tabpanel(2), [.659 .19 .3 component_height], contour_color_options, 'k', 'w', .6, 'normal', @contour_color_callback);
    function contour_color_callback(varargin)
        temp1 = get(contour_color_dropdown, 'value');
        countour_color_selected_opt = contour_color_options(temp1);
        update_display_image
    end

Foreground_Display_raw_image_checkbox = checkbox(h_tabpanel(2), [.05 .14 .65 component_height], 'Display Raw Image', 'center', 'k', lt_gray, .6, 'sans serif', 'normal', {@Foreground_Display_raw_image_checkbox_Callback});
    function Foreground_Display_raw_image_checkbox_Callback(varargin)
        foreground_display_raw_image = logical(get(Foreground_Display_raw_image_checkbox, 'value'));
        if(nb_frames <= 0)
            return;
        else 
            update_display_image
        end
            
    end

Adjust_Contrast_raw_image_checkbox = checkbox(h_tabpanel(2), [.05 .09 .65 component_height], 'Adjust Contrast', 'center', 'k', lt_gray, .6, 'sans serif', 'normal', {@Adjust_Contrast_raw_image_checkbox_Callback});
    function Adjust_Contrast_raw_image_checkbox_Callback(varargin)
        adjust_contrast_raw_image = logical(get(Adjust_Contrast_raw_image_checkbox, 'value'));
        if(nb_frames <= 0)
            return;
        else 
            update_display_image
        end            
    end

show_orig_image_checkbox = checkbox(h_tabpanel(2), [.58 .09 .65 component_height], 'Orig. Image', 'center', 'k', lt_gray, .6, 'sans serif', 'normal', {@show_orig_image_checkbox_Callback});
    function show_orig_image_checkbox_Callback(varargin)
        show_orig_raw_image = logical(get(show_orig_image_checkbox, 'value'));
        if(nb_frames <= 0)
            return;
        else 
            update_display_image
        end            
    end

push_button(h_tabpanel(2), [.005 .01 .5 1.2*component_height], 'Save Segmented Images', 'center', 'k', dark_gray, 0.3, 'sans serif', 'bold', 'on', {@save_images_GUI_callback});
push_button(h_tabpanel(2), [.51 .01 .485 1.2*component_height], 'Export Confluency Table', 'center', 'k', dark_gray, 0.3, 'sans serif', 'bold', 'on', {@export_confluency_GUI_callback});

% Export confluency table popup GUI
% -------------------------------------------------------------------------------------
function export_confluency_GUI_callback(varargin)
    % Create figure, if found return, this prevents opening multiples of the same figure
    % Create figure in case not found
    if numel(findobj('type','figure','name','Confluency Table')) > 0
        export_fig = findobj('type','figure','name','Confluency Table');
        figure(export_fig)
    else 
        export_fig = figure(...
            'units', 'pixels',...
            'Position', [ (MaxMonitorX-gui_width*0.3)/2 - offset, (MaxMonitorY-gui_height*0.5)/2 + offset, gui_width*0.3, gui_height*0.5 ], ...
            'Name','Confluency Table',...
            'NumberTitle','off',...
            'Menubar','none',...
            'Toolbar','none',...
            'Resize', 'on');        
    end
            
    content_panel = sub_panel(export_fig, [0 0 1 1], '', 'lefttop', green_blue, lt_gray, 14, 'serif');

    save_common_name='Confluency Table';
    label(content_panel, [.03 .68 .2 .09], 'Name:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    save_common_name_edit = editbox(content_panel, [.27 .69 .7 .09], save_common_name, 'left', 'k', 'w', .6, 'normal');    
    
    export_range = 'All';        
    label(content_panel, [.03 .57 .2 .09], 'Range:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    export_range_edit = editbox(content_panel, [.27 .58 .7 .09], export_range, 'left', 'k', 'w', .6, 'normal');
    label(content_panel, [.27 .49 .7 .09], 'i.e. - All or subset 1,2,3:7,12', 'left', 'k', lt_gray, .45, 'sans serif', 'normal');
    
    push_button(content_panel, [.01 .01 .49 .09], 'Export Table', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on', {@export_callback});
    push_button(content_panel, [.5 .01 .49 .09], 'Cancel', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on', {@cancel_export_callback});
   
    function export_callback(varargin)
        export_range = get(export_range_edit, 'String');
        export_confluencies(export_range, save_common_name);
        if ishandle(export_fig), close(export_fig); end
    end
   
    function cancel_export_callback(varargin)
         if ishandle(export_fig), close(export_fig); end
    end
end

% Export images to file
function export_confluencies(range, save_name)
    % directory
    sdir = uigetdir(pwd,'Select Export Path');
    if sdir ~= 0
        try
            h = msgbox('Working...');
            nb_frames_temp = nb_frames;
            
            export_confluencies_path = validate_filepath(sdir);
            print_to_command(['Exporting Confluencies to: ' export_confluencies_path]);
                            
            if(strcmp(range, 'All'))
                range = '0';
            end

            images_to_export = str2num(range); %#ok<ST2NM>    
            % make sure images_to_export is valid
            images_to_export(images_to_export > nb_frames_temp) = [];
            if ~isempty(images_to_export) && any(images_to_export > 0)
                nb_frames_temp = numel(images_to_export);
            else
                images_to_export = 1:nb_frames_temp; % export all
                nb_frames_temp = numel(images_to_export);
            end
            
            upper_hole_size_bound = foreground_min_hole_size;
            zero_pad = num2str(length(num2str(nb_frames_temp)));
            
            print_update(1, 1, nb_frames_temp);
            
            % get confluencies
            confluencies = zeros(nb_frames_temp,1);
            image_names = strings(nb_frames_temp,1);
            for i = 1:nb_frames_temp
                
                print_update(2,i,nb_frames_temp);
                raw_image = imread([raw_images_path raw_image_files(images_to_export(i)).name]);

                I1 = double(raw_image);
                BW = EGT_Segmentation(I1, foreground_min_object_size, upper_hole_size_bound, greedy_slider_num,erosion_val,dilation_val);

                foreground_morph_operation = lower(regexprep(foreground_morph_operation, '\W', ''));
                BW = morphOp(grayscale_image, BW, foreground_morph_operation, foreground_strel_disk_radius);

                % Govin: Add confluency estimates and names to array
                confluencies(i) = getConfluency(BW);
                image_names(i) = string(raw_image_files(images_to_export(i)).name);
                %                                                
            end
                        
            % convert to table and save
            save_table = table(image_names, confluencies,'VariableNames',{'Image_Name', 'Percent_Confluency'});
            save_name = [export_confluencies_path  save_name '.csv'];
            writetable(save_table, save_name);
            
            if ishandle(h), close(h); end
            
        catch err
            if (strcmp(err.identifier,'validate_filepath:notFoundInPath')) || ...
                    (strcmp(err.identifier,'validate_filepath:argChk'))
                errordlg('Invalid directory selected');
                return;
            else
                rethrow(err);
            end
        end
    end     
end

% Save images popup GUI
% -------------------------------------------------------------------------------------
function save_images_GUI_callback(varargin)
    % Create figure, if found return, this prevents opening multiples of the same figure
    % Create figure in case not found
    if numel(findobj('type','figure','name','Save Images')) > 0
        save_fig = findobj('type','figure','name','Save Images');
        figure(save_fig)
    else
        save_fig = figure(...
            'units', 'pixels',...
            'Position', [ (MaxMonitorX-gui_width*0.3)/2 - offset, (MaxMonitorY-gui_height*0.5)/2 + offset, gui_width*0.3, gui_height*0.5 ], ...
            'Name','Save Images',...
            'NumberTitle','off',...
            'Menubar','none',...
            'Toolbar','none',...
            'Resize', 'on');
    end
    
    save_image_format_opts = {'Tiff','PNG','JPG'};
    save_image_format = save_image_format_opts{1};
    save_range = 'All';
    
    type_format_opts = {'Binary Mask', 'As Shown in Preview'};
    type_format = type_format_opts{1};
    
    content_panel = sub_panel(save_fig, [0 0 1 1], '', 'lefttop', green_blue, lt_gray, 14, 'serif');
    
    label(content_panel, [.03 .86 .2 .09], 'Format:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    format_edit_dropdown = popupmenu(content_panel, [.27 .87 .7 .09], save_image_format_opts, 'k', 'w', .6, 'normal', {@format_callback});
    label(content_panel, [.27 .77 .7 .09], 'Binary mask saved as Tiff only', 'left', 'k', lt_gray, .45, 'sans serif', 'normal');
    set(format_edit_dropdown, 'value',1);
    
    function format_callback(varargin)
        temp = get(format_edit_dropdown, 'value');
        save_image_format = save_image_format_opts{temp};
    end
        
    label(content_panel, [.03 .57 .2 .09], 'Range:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    save_range_edit = editbox(content_panel, [.27 .58 .7 .09], save_range, 'left', 'k', 'w', .6, 'normal');
    label(content_panel, [.27 .49 .7 .09], 'i.e. - All or subset 1,2,3:7,12', 'left', 'k', lt_gray, .45, 'sans serif', 'normal');
    
    label(content_panel, [.03 .35 .2 .09], 'Type:', 'right', 'k', lt_gray, .6, 'sans serif', 'normal');
    type_edit_dropdown = popupmenu(content_panel, [.27 .36 .7 .09], type_format_opts, 'k', 'w', .6, 'normal', {@type_callback});
    set(type_edit_dropdown, 'value', 1);
    
    function type_callback(varargin)
        temp1 = get(type_edit_dropdown, 'value');
        type_format = type_format_opts{temp1};
    end

   push_button(content_panel, [.01 .01 .49 .09], 'Save', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on', {@save_callback});
   push_button(content_panel, [.5 .01 .49 .09], 'Cancel', 'center', 'k', 'default', 0.5, 'sans serif', 'bold', 'on', {@cancel_save_callback});
   
    function save_callback(varargin)
        save_range = get(save_range_edit, 'String');
        save_images(save_image_format, save_range, type_format);
        if ishandle(save_fig), close(save_fig); end
    end
   
   
    function cancel_save_callback(varargin)
         if ishandle(save_fig), close(save_fig); end
    end
end


% save customzied options (dilation and erosion values)
function saveCustomizedOpts(dil_val, er_val)
    erosion_val = er_val
    dilation_val = dil_val
end


% Format = tif, png, or jpg
% Range = All or 1,2,3:7,9
% Type = Binary mask or As shown in Preview

 function save_images(format, range, type, varargin)        
    % directory
    sdir = uigetdir(pwd,'Select Saved Path');
    if sdir ~= 0
        try
            h = msgbox('Working...');
            nb_frames_temp = nb_frames;
            
            save_images_path = validate_filepath(sdir);
            
            print_to_command(['Saving Images to: ' save_images_path]);
            
            formatted_format = '';
            switch(format)
                case 'PNG'
                    formatted_format = '.png';
                case 'JPG'
                    formatted_format = '.jpg';
                otherwise
                    formatted_format = '.tif';
            end
                
            if(strcmp(range, 'All'))
                range = '0';
            end

            frames_to_save = str2num(range); %#ok<ST2NM>    
            % truncate frames_to_save
            frames_to_save( frames_to_save > nb_frames_temp) = [];
            if ~isempty(frames_to_save) && any(frames_to_save > 0)
                nb_frames_temp = numel(frames_to_save);
            else
                frames_to_save = 1:nb_frames_temp;
                nb_frames_temp = numel(frames_to_save);
            end
            
            upper_hole_size_bound = foreground_min_hole_size;
            zero_pad = num2str(length(num2str(nb_frames_temp)));
            
            % log parameters
            fh = fopen([save_images_path filesep 'parameters.log'],'w');
            fprintf(fh,'Edge Detection GUI Run on %s\n\n', datestr(clock));
            fprintf(fh,'Empirical Gradient Threshold\n');
            fprintf(fh,'Raw Images Path:\n');
            fprintf(fh,'%s\n',raw_images_path);
            fprintf(fh,'Raw Common Name Path:\n');
            fprintf(fh,'%s\n',raw_images_common_name);
            fprintf(fh,'Min Cell Area: %d\n',foreground_min_object_size);
            fprintf(fh,'Fill Holes Smaller Than: %d\n',upper_hole_size_bound);
            fprintf(fh,'Morphological Operation: %s with radius %d\n',foreground_morph_operation, foreground_strel_disk_radius);
            fprintf(fh,'Greedy: %d\n',greedy_slider_num);
            fclose(fh);
            
            print_update(1, 1, nb_frames_temp);
            for i = 1:nb_frames_temp
                
                print_update(2,i,nb_frames_temp);

                raw_image = imread([raw_images_path raw_image_files(frames_to_save(i)).name]);

                I1 = double(raw_image);
                BW = EGT_Segmentation(I1, foreground_min_object_size, upper_hole_size_bound, greedy_slider_num,erosion_val,dilation_val);

                foreground_morph_operation = lower(regexprep(foreground_morph_operation, '\W', ''));
                BW = morphOp(grayscale_image, BW, foreground_morph_operation, foreground_strel_disk_radius);

                % Govin: Add confluency estimate
                confluency = getConfluency(BW);
                %
                                
                foreground_mask = BW;
                if foreground_display_labeled_image
                    [foreground_mask, nb_objects] = bwlabel(foreground_mask);
                else
                    foreground_mask = foreground_mask>0;
                    nb_objects = 1;
                end
                
                save_name = raw_image_files(frames_to_save(i)).name;
                split_save_name = split(save_name,'.'); % split at period to remove extension
                save_name = split_save_name{1};
                save_name = [save_name '_confluency_' num2str(confluency,3) formatted_format]; % append new format
                switch type
                    case  'Binary Mask'
                        imwrite(BW, [save_images_path save_name]);
%                     case 'Labeled Mask'
%                         imwrite(uint16(bwlabel(foreground_mask)), [save_images_path save_name]);
                    otherwise % as shown in preview
                        image = superimpose_colormap_contour(I1, foreground_mask, colormap([colormap_selected_option '(65000)']), countour_color_selected_opt, foreground_display_raw_image, foreground_display_contour, adjust_contrast_raw_image);
                        imwrite(image, [save_images_path save_name]);
                end
            end
            
            
%             upper_hole_size_bound = foreground_min_hole_size;
%             zero_pad = num2str(length(num2str(nb_frames)));
            
%             disp(save_images_path);
%             disp(format);
%             disp(name);
%             disp(range);
%             disp(type);
            
            
             if ishandle(h), close(h); end
            
        catch err
            if (strcmp(err.identifier,'validate_filepath:notFoundInPath')) || ...
                    (strcmp(err.identifier,'validate_filepath:argChk'))
                errordlg('Invalid directory selected');
                return;
            else
                rethrow(err);
            end
        end
    end     
 end

% ---------------------------------------------------------------------------------------
% Display Panel

% setup the display panel for the foreground tab

    function bool = Foreground_Options_validate(varargin)
        bool = false;
        Foreground_Options_morph_Callback();
        Foreground_Options_strel_radius_Callback();
        if ~Foreground_Options_min_object_size_Callback(), return, end
        if ~Foreground_Options_min_hole_size_Callback(), return, end
        bool = true;
        
    end

    num_objects_label = [];
    function initImagePanel(varargin)
               
        % Create Slider for image display
        if nb_frames > 1            
            image_slider_edit = uicontrol('style','slider',...
                'Parent',display_panel,...
                'unit','normalized',...
                'Min',1,'Max',nb_frames,'Value',1, ...
                'position',[.01 0.01 0.6 0.05],...
                'SliderStep', [1, 1]/(nb_frames - 1), ...  % Map SliderStep to whole number, Actual step = SliderStep * (Max slider value - Min slider value)
                'callback',{@imgSliderCallback});

            % Edit: Cell Numbers to show
            goto_user_frame_edit = uicontrol('style','Edit',...
                'Parent',display_panel,...
                'unit','normalized',...
                'position',[.63 0.01 0.1 0.05],...
                'HorizontalAlignment','center',...
                'String','1',...
                'FontUnits', 'normalized',...
                'fontsize',.5,...
                'fontweight','normal',...
                'backgroundcolor', 'w',...
                'callback',{@gotoFrameCallback});
        end
        
        % # of frames label
        uicontrol('style','text',...
            'Parent',display_panel,...
            'unit','normalized',...
            'position',[.74 .005 .09 .05],...
            'HorizontalAlignment','left',...
            'String',['of ' num2str(nb_frames)],...
            'FontUnits', 'normalized',...
            'fontsize',.6,...
            'backgroundcolor', lt_gray,...
            'fontweight','normal');
        
        num_objects_label = label(display_panel, [.85 .005 .14 .05], [num2str(nb_objects) ' objects'], 'center', 'k', lt_gray, .6, 'sans serif', 'normal');

%         % Pushbutton: Goto Frame
%         uicontrol('style','push',...
%             'Parent',display_panel,...
%             'unit','normalized',...
%             'position',[.89 0.01 0.1 0.05],...
%             'HorizontalAlignment','right',...
%             'String','Go',...
%             'FontUnits', 'normalized',...
%             'fontsize',.5,...
%             'fontweight','normal',...
%             'callback',{@gotoFrameCallback});
       
    function imgSliderCallback(varargin)
        current_frame_nb = ceil(get(image_slider_edit, 'value'));
        set(goto_user_frame_edit, 'String', num2str(current_frame_nb));
        Foreground_Display_update_image();
    end

    function gotoFrameCallback(varargin)
        new_frame_nb = str2double(get(goto_user_frame_edit, 'String'));
        if isnan(new_frame_nb) 
            errordlg(['Invalid frame, please input a valid number.']);
            set(goto_user_frame_edit, 'String', num2str(current_frame_nb));
            return;
        end
        
        % constrain the new frame number to the existing frame numbers
        new_frame_nb = min(new_frame_nb, nb_frames);
        new_frame_nb = max(1, new_frame_nb);
        
        current_frame_nb = new_frame_nb;
        set(goto_user_frame_edit, 'string', num2str(current_frame_nb));
        set(image_slider_edit, 'value', current_frame_nb);
        Foreground_Display_update_image()
    end              
    end

    Foreground_Display_Superimpose_Axis = axes('Parent', display_panel, 'Units','normalized', 'Position', [.001 .1 .999 .90]);
    %set(Foreground_Display_Superimpose_Axis,'nextplot','replacechildren');
    axis off; axis image;  
    colors_vector = 0; nb_objects = 1; text_location = 0;

    function Foreground_Display_update_image(varargin)
        if ~Foreground_Options_validate(), return, end
        
         % Read corresponding images
        grayscale_image = imread([raw_images_path raw_image_files(current_frame_nb).name]);
        set(display_panel, 'Title', ['Image: <' raw_image_files(current_frame_nb).name '>']);
            
        I1 = double(grayscale_image);

        upper_hole_size_bound = foreground_min_hole_size;
        foreground_mask = EGT_Segmentation(I1, foreground_min_object_size, upper_hole_size_bound, greedy_slider_num,erosion_val,dilation_val);
        
        foreground_morph_operation = lower(regexprep(foreground_morph_operation, '\W', ''));
        foreground_mask = morphOp(grayscale_image, foreground_mask, foreground_morph_operation, foreground_strel_disk_radius);       
        
        % Govin: Add confluency estimate
        confluency = getConfluency(foreground_mask);
        display_panel.Title = display_panel.Title + ", Confluency is: " + confluency + "%";
        %
        
        delete(get(Foreground_Display_Superimpose_Axis, 'Children'));
        [disp_I, colors_vector] = superimpose_colormap_contour(I1, foreground_mask, colormap([colormap_selected_option '(65000)']), countour_color_selected_opt, foreground_display_raw_image, foreground_display_contour, adjust_contrast_raw_image, colors_vector);
        imshow(disp_I, 'Parent', Foreground_Display_Superimpose_Axis);
        
        if foreground_display_labeled_image
            update_label_image();
        end
        
    end
    
    function update_label_image(varargin)
        
        if foreground_display_labeled_image
            [foreground_mask, nb_objects] = bwlabel(foreground_mask);
        else
            foreground_mask = foreground_mask>0;
            nb_objects = 1;
        end
        delete(get(Foreground_Display_Superimpose_Axis, 'Children'));
        [disp_I, colors_vector] = superimpose_colormap_contour(I1, foreground_mask, colormap([colormap_selected_option '(65000)']), countour_color_selected_opt, foreground_display_raw_image, foreground_display_contour, adjust_contrast_raw_image);
        imshow(disp_I, 'Parent', Foreground_Display_Superimpose_Axis);
        
        [~, text_location] = find_edges_labeled(foreground_mask, nb_objects);
        % Place the number of the cell in the image
        if foreground_display_labeled_image && foreground_display_labeled_text
            hold on,            
            for i = 1:nb_objects
                cell_number = foreground_mask(text_location(i,2), text_location(i,1));
                
                text(text_location(i,1), text_location(i,2), num2str(cell_number), 'fontsize', 8, ...
                    'FontWeight', 'bold', 'Margin', .1, 'color', 'k', 'BackgroundColor', 'w')
            end
        end
        
        set(num_objects_label, 'String', [num2str(nb_objects) ' objects']);

        set(Foreground_Display_Superimpose_Axis,'nextplot','replacechildren'); % maintains zoom when clicking through slider 
        
    end

    function update_display_image(varargin)
        delete(get(Foreground_Display_Superimpose_Axis, 'Children'));
        if logical(get(show_orig_image_checkbox, 'value'))
            set(Foreground_Display_labeled_text_checkbox,'enable','off','value',0);
            set(Foreground_Display_labeled_image_checkbox,'enable','off','value',0);
            set(Foreground_Display_contour_checkbox,'enable','off','value',0);
            set(Foreground_Display_raw_image_checkbox,'enable','off','value',0);
            set(Adjust_Contrast_raw_image_checkbox,'enable','off','value',0);
            
            imshow(mat2gray(I1))
        else
%             set(Foreground_Display_labeled_text_checkbox,'enable','on');
            set(Foreground_Display_labeled_image_checkbox,'enable','on','value',foreground_display_labeled_image);
            set(Foreground_Display_contour_checkbox,'enable','on','value',foreground_display_contour);
            set(Foreground_Display_raw_image_checkbox,'enable','on','value',foreground_display_raw_image);
            set(Adjust_Contrast_raw_image_checkbox,'enable','on','value',adjust_contrast_raw_image);
            set(show_orig_image_checkbox,'value',0)
            
            [disp_I, colors_vector] = superimpose_colormap_contour(I1, foreground_mask, colormap([colormap_selected_option '(65000)']), countour_color_selected_opt, foreground_display_raw_image, foreground_display_contour, adjust_contrast_raw_image, colors_vector);
            imshow(disp_I, 'Parent', Foreground_Display_Superimpose_Axis);
            if foreground_display_labeled_image && foreground_display_labeled_text
                hold on,            
                for i = 1:nb_objects
                    cell_number = foreground_mask(text_location(i,2), text_location(i,1));

                    text(text_location(i,1), text_location(i,2), num2str(cell_number), 'fontsize', 8, ...
                        'FontWeight', 'bold', 'Margin', .1, 'color', 'k', 'BackgroundColor', 'w')
                end
            end
        end        
        set(Foreground_Display_Superimpose_Axis,'nextplot','replacechildren'); % maintains zoom when clicking through slider        
    end

    function initImages(varargin)
               
        % get path and common name info from gui
        raw_images_path = get(input_dir_editbox, 'string');
        if raw_images_path(end) ~= filesep
            raw_images_path = [raw_images_path filesep];
        end
        raw_images_common_name = get(common_name_editbox, 'string');
        if isempty(raw_images_common_name)
            raw_image_files = [dir([raw_images_path '*.jpg']); dir([raw_images_path '*.png']); dir([raw_images_path '*.tif'])];
        else
            raw_image_files = [dir([raw_images_path '*' raw_images_common_name '*.jpg']); dir([raw_images_path '*' raw_images_common_name '*.png']); dir([raw_images_path '*' raw_images_common_name '*.tif'])];
        end 
        nb_frames = length(raw_image_files);
        if nb_frames <= 0
            errordlg('Chosen image folder or common name doesn''t contain any .tif, .png, or .jpg images.');
            return;
        end
        
        
  
        % Get first image to check its size
        image = imread([raw_images_path raw_image_files(1).name]);

        % if image is very large, send the user a warning
        if numel(image) > 10^7
            
            response = questdlg('Images are large! Visualization might be slow, Continue?', ...
                'Notice','Yes','Cancel','Cancel');
            % Handle response
            switch response
                case 'Yes'
%                     continue displaying images
                case 'Cancel'
                    % if the user did not select yes for continue, abort visualization
                    return;
            end
            
        end
        
        
        initImagePanel
        current_frame_nb = 1;
        Foreground_Display_update_image
        
        set(growthRateTab, 'enable', 'on');
        set(exportGrowthsTab,'enable','on');
        set(h_tabpb(2), 'enable', 'on');
        second_tab_callback
    end

end


% % UI Control Wrappers
function edit_return = editbox(parent_handle, position, string, horz_align, color, bgcolor, fontsize, fontweight, varargin)
edit_return = uicontrol('style','edit',...
    'parent',parent_handle,...
    'unit','normalized',...
    'fontunits', 'normalized',...
    'position',position,...
    'horizontalalignment',horz_align,...
    'string',string,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'fontsize',fontsize,...
    'fontweight',fontweight);
end

function edit_return = editbox_check(parent_handle, position, string, horz_align, color, bgcolor, fontsize, fontweight, callback, varargin)
edit_return = uicontrol('style','edit',...
    'parent',parent_handle,...
    'unit','normalized',...
    'fontunits', 'normalized',...
    'position',position,...
    'horizontalalignment',horz_align,...
    'string',string,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'fontsize',fontsize,...
    'fontweight',fontweight,...
    'callback', callback);
end

function label_return = label(parent_handle, position, string, horz_align, color, bgcolor, fontsize, fontname, fontweight, varargin)
label_return = uicontrol('style','text',...
    'parent',parent_handle,...
    'unit','normalized',...
    'fontunits','normalized',...
    'position',position,...
    'horizontalalignment',horz_align,...
    'string',string,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'fontsize',fontsize,...
    'fontname', fontname,...
    'fontweight',fontweight);
end

function pop_return = popupmenu(parent_handle, position, string_array, color, bgcolor, fontsize, fontweight, callback, varargin)
pop_return = uicontrol('style','popupmenu',...
    'parent',parent_handle,...
    'unit','normalized',...
    'fontunits', 'normalized',...
    'position',position,...
    'string',string_array,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'fontsize',fontsize,...
    'fontweight',fontweight,...
    'callback',callback);
end

function button_return = push_button(parent_handle, position, string, horz_align, color, bgcolor, fontsize, fontname, fontweight, on_off, callback, varargin)
button_return = uicontrol('style','pushbutton',...
    'parent',parent_handle,...
    'unit','normalized',...
    'fontunits','normalized',...
    'position',position,...
    'horizontalalignment',horz_align,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'string',string,...
    'fontsize',fontsize,...
    'fontname', fontname,...
    'fontweight',fontweight,...
    'enable', on_off,...
    'callback',callback);
end


function check_return = checkbox(parent_handle, position, string, horz_align, color, bgcolor, fontsize, fontname, fontweight, callback, varargin)
check_return = uicontrol('style','checkbox',...
    'Parent',parent_handle,...
    'unit','normalized',...
    'fontunits', 'normalized',...
    'position',position,...
    'horizontalalignment',horz_align,...
    'string',string,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'fontsize', fontsize,...
    'fontname', fontname,...
    'fontweight',fontweight,...
    'callback', callback);
end

% UI Panels
function panel_return = sub_panel(parent_handle, position, title, title_align, color, bgcolor, fontsize, fontname, varargin)
panel_return = uipanel('parent', parent_handle,...
    'units', 'normalized',...
    'position',position,...
    'title',title,...
    'titleposition',title_align,...
    'foregroundcolor',color,...
    'backgroundcolor',bgcolor,...
    'fontname', fontname,...
    'fontsize',fontsize,...
    'fontweight', 'bold',...
    'visible', 'on',...
    'borderwidth',1);
end


function BW = morphOp(I, BW, op_str, radius, border_mask)
if radius == 0
    return;
end

if nargin == 5
    use_border_flag = true;
else
    use_border_flag = false;
    border_mask = [];
end
border_mask = logical(border_mask);


op_str = lower(regexprep(op_str, '\W', ''));
switch op_str
    case 'dilate'
        if use_border_flag
            BW = geodesic_imdilate(BW, ~border_mask, strel('disk', radius), radius);
        else
            BW = imdilate(BW, strel('disk', radius));
        end
    case 'erode'
        BW = imerode(BW, strel('disk', radius));
    case 'close'
        if use_border_flag
            BW = geodesic_imclose(BW, ~border_mask, strel('disk', radius), radius);
        else
            BW = imclose(BW, strel('disk', radius));
        end
    case 'open'
        if use_border_flag
            BW = geodesic_imopen(BW, ~border_mask, strel('disk', radius), radius);
        else
            BW = imopen(BW, strel('disk', radius));
        end
        
    case 'iterativegraydilate'
        factorNb = 0.5;
        se = strel('disk', 1);
        
        if ~use_border_flag
            border_mask = true(size(BW));
        end
        BW = logical(BW);
        
        for i = 1:floor((1/factorNb)*radius)
            BWd = imdilate(BW>0, se);
            if use_border_flag
                BWd = BWd & ~border_mask;
            end
            [BWd, nb_obj] = bwlabel(BWd);
            for k = 1:nb_obj
                idx = find(BWd == k);
                % remove non border pixels
                old_idx = BW(idx);
                idx(old_idx) = [];
                
                % decide the pixels to keep
                vals = I(idx);
                [~, locs] = sort(vals, 'ascend');
                locs2 = locs(1:round(numel(locs)*factorNb));
                idx2 = idx(locs2);
                BW(idx2) = 1;
                
            end
        end
        BW = logical(BW);
end

end



function BW = geodesic_imdilate(BW, mask, se, radius)

BW = logical(BW);
BW = BW & mask;
BWmask = imdilate(BW, se);
BWmask = BWmask & mask;

BW1 = bwdistgeodesic(BWmask, BW);

BW = BW1 <= radius;

end

function BW = geodesic_imopen(BW, mask, se, radius)

BW = imerode(BW, se);
BW = geodesic_imdilate(BW,mask,se,radius);

end

function BW = geodesic_imclose(BW, mask, se, radius)

BW = geodesic_imdilate(BW,mask,se,radius);
BW = imerode(BW, se);

end

function confluency = getConfluency(img)
% Govin added: gets confluency given a binary input image

imgSize = size(img,1)*size(img,2);
numPixelsThatAreCells = sum(img(:)==1);

confluency = numPixelsThatAreCells/imgSize * 100;
end

