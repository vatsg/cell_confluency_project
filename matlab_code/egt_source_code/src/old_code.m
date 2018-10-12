% growth_panel = sub_panel(main_panel, [0.01,0.02,.7,.955], ['Image: <' '>'], 'lefttop', green_blue, lt_gray, 14, 'serif');
% 
% disp_tab(1) = push_button(main_panel, [.435 0.95 0.135 0.05], DispLabels(1), 'center', 'k', lt_gray, disp_label_text_size, 'serif', 'bold', 'on', {@show_segmentation_callback} );
% disp_tab(2) = push_button(main_panel, [.575 0.95 0.135 0.05], DispLabels(2), 'center', 'k', lt_gray, disp_label_text_size, 'serif', 'bold', 'off', {@show_growth_callback});
% set(growth_panel, 'Visible', 'off');
% 
%     function show_segmentation_callback(varargin)
%         set(disp_tab(1), 'Backgroundcolor', lt_gray);
%         set(disp_tab(2), 'Backgroundcolor', lt_gray);
%         
%         set(display_panel, 'Visible', 'on');
%         set(growth_panel, 'Visible', 'off');
%     end
% 
%     function show_growth_callback(varargin)
%         set(disp_tab(1), 'Backgroundcolor', lt_gray);
%         set(disp_tab(2), 'Backgroundcolor', lt_gray);
%         
%         set(growth_panel, 'Visible', 'on');        
%         set(display_panel, 'Visible', 'off');
%     end    
