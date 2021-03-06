function view_tcgrid(lab1, re3)
% This .m file, "view_tcgrid.m", plots ratechanges calculated with tcgrid.m
% needs re3, gx, gy
%
% define size of the plot etc.
%
if isempty(name)
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
%co = 'w';



% This is the info window text
%
ttlStr='The b and p -Value Map Window                 ';
hlpStr1zmap= ...
    ['                                                '
    ' This window displays b-values and p-values     '
    ' using a color code.                            '
    ' Some of the menu-bar options are               '
    ' described below:                               '
    '                                                '
    ' Threshold: You can set the maximum size that   '
    '   a volume is allowed to have in order to be   '
    '   displayed in the map. Therefore, areas with  '
    '   a low seismicity rate are not displayed.     '
    '   edit the size (in km) and click the mouse    '
    '   outside the edit window.                     '
    'FixAx: You can chose the minimum and maximum    '
    '        values of the color-legend used.        '
    'Polygon: You can select earthquakes in a        '
    ' polygon either by entering the coordinates or  '
    ' defining the corners with the mouse            '];
hlpStr2zmap= ...
    ['                                                '
    'Circle: Select earthquakes in a circular volume:'
    '      Ni, the number of selected earthquakes can'
    '      be edited in the upper right corner of the'
    '      window.                                   '
    ' Refresh Window: Redraws the figure, erases     '
    '       selected events.                         '

    ' zoom: Selecting Axis -> zoom on allows you to  '
    '       zoom into a region. Click and drag with  '
    '       the left mouse button. type <help zoom>  '
    '       for details.                             '
    ' Aspect: select one of the aspect ratio options '
    ' Text: You can select text items by clicking.The'
    '       selected text can be rotated, moved, you '
    '       can change the font size etc.            '
    '       Double click on text allows editing it.  '
    '                                                '
    '                                                '];

% Set up the Seismicity Map window Enviroment
%

% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('rc-value-map',1);
newrcmapWindowFlag=~existFlag;

if newrcmapWindowFlag
    oldfig_button = 0
end

if oldfig_button == 0
    rcmap = figure_w_normalized_uicontrolunits( ...
        'Name','rc-value-map',...
        'NumberTitle','off', ...
        'NextPlot','new', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    

    %lab1 = 'p-value:';

    add_symbol_menu('eq_plot');

    %    uicontrol('Units','normal',...
    %       'Position',[.0 .93 .08 .06],'String','Info ',...
    %        'Callback',' web([''file:'' hodi ''/zmapwww/chp11.htm#996756'']) ');



    options = uimenu('Label',' Analyze ');
    uimenu(options,'Label','Refresh ', 'Callback','view_tcgrid(lab1,re3)')
    %    uimenu(options,'Label','Select EQ in Circle',...
    %        'Callback','h1 = gca;met = ''ni''; ZG=ZmapGlobal.Data;ZG.hold_state=false;cirpva;watchoff(rcmap)')
    uimenu(options,'Label','Select EQ in Circle - Constant R',...
         'Callback','h1 = gca;met = ''ra''; ZG=ZmapGlobal.Data;ZG.hold_state=false;plot_circ_magshift;watchoff(rcmap)')
    uimenu(options,'Label','Select EQ with const. number',...
         'Callback','h1 = gca;ZG=ZmapGlobal.Data; ZG.hold_state2=true;ZG=ZmapGlobal.Data;ZG.hold_state=true;plot_constnrbootfit_a2;watchoff(rcmap)')


    op1 = uimenu('Label',' Maps ');

    %Menu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'Callback','asel = ''mag''; adju2; view_tcgrid(lab1,re3)')
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'Callback','asel = ''rmax''; adju2; view_tcgrid(lab1,re3)')
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'Callback','asel = ''gofi''; adju2; view_tcgrid(lab1,re3)')
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'Callback','asel = ''pstdc''; adju2; view_tcgrid(lab1,re3)')

    % Menu MAPS
    uimenu(op1,'Label','Magnitude shift',...
         'Callback',' lab1=''dM'';re3 = mMagShift; view_tcgrid(lab1,re3)')
    uimenu(op1,'Label','KS-Test result',...
         'Callback','lab1=''H'';re3 = mHkstest; view_tcgrid(lab1,re3)')
    uimenu(op1,'Label','Magnitude shift validated',...
         'Callback',' lab1=''dM'';re3 = mMagShift_valid; view_tcgrid(lab1,re3)')
    uimenu(op1,'Label','Normalized \Delta_{FMD}',...
         'Callback','lab1=''\Delta_{FMD}'';re3 = mChFMD; view_tcgrid(lab1,re3)')

    uimenu(op1,'Label','Resolution Map (Number of events period 1)',...
         'Callback','lab1=''Number of events'';re3 = mNumevents1; view_tcgrid(lab1,re3)')
    uimenu(op1,'Label','Resolution Map (Number of events period 2)',...
         'Callback','lab1=''Number of events'';re3 = mNumevents2; view_tcgrid(lab1,re3)')


    % Menu DISPLAY
    add_display_menu(1);

    %re3 = pvalg;
    tresh = nan; re4 = re3;
    oldfig_button = 1;

    colormap(jet)
    tresh = nan; minpe = nan; Mmin = nan; minsd = nan;

end   % This is the end of the figure setup.

% Now lets plot the color-map!
%
figure_w_normalized_uicontrolunits(rcmap)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% find max and min of data for automatic scaling
ZG.maxc = max(max(re3));
ZG.maxc = fix(ZG.maxc)+1;
ZG.minc = min(min(re3));
ZG.minc = fix(ZG.minc)-1;

% set values greater tresh = nan
%
re4 = re3;

% plot image
%
orient landscape
%set(gcf,'PaperPosition', [0.5 1 9.0 4.0])

%Plots re4, which contains the filtered values.
axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on
if sha == 'fl'
    shading flat
else
    shading interp
end
% make the scaling for the recurrence time map reasonable
if lab1(1) =='T'
    l = isnan(re3);
    re = re3;
    re(l) = [];
    caxis([min(re) 5*min(re)]);
end

%If the colorbar is freezed.
if fre == 1
    caxis([fix1 fix2])
end


title([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.s,...
    'Color','r','FontWeight','bold')

xlabel('Longitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)
ylabel('Latitude [deg]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s)

% plot overlay
%
hold on
overlay_
ploeq = plot(ZG.primeCatalog.Longitude,ZG.primeCatalog.Latitude,'k.');
set(ploeq,'Tag','eq_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)



set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.s,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ 0.33 0.06 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.s,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
%
set(gca,'FontSize',ZmapGlobal.Data.fontsz.s,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(rcmap);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(rcmap)
%whitebg(gcf,[ 0 0 0 ])
done
