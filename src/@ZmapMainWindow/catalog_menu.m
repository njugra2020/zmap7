function catalog_menu(obj, force)
    % catalog_menu was create_catalog_menu adds a menu designed to handle catalog modifications
    % catalog_menu(mycatalog, force, handle)
    % mycatalog is a name of the ZmapGlobal.Data field containing a ZmapCatalog
    % myview is a name of the ZmapGlobal.Data.View field containing a ZmapCatalogView
    %
    % Menu Options:
    %   Crop catalog to window -
    %   Edit Ranges -
    %   Rename -
    %   - - -
    %   Memorize/Recall Catalog -
    %   Clear Memorized Catalog -
    %   - - -
    %   Combine Catalogs -
    %   Compare Catalogs -
    %   Save Current Catalog - save as a ZmapCatalog (.mat) or a v6 or v7+ ASCII table (.dat)
    %   - - -
    %   Stats -
    %   Get/Load Catalog -
    %   Reload Last Catalog -
    
    
    %TODO clear up mess between ZG.catalogs and ZG.Views.view
    
    % to find this menu, use findobj(obj.fig, 'Tag');
    
    %mycatalog = 'primeCatalog';
    ZG = ZmapGlobal.Data; % for use in all subroutines
    h = findobj(obj.fig,'Tag','menu_catalog');
    if ~exist('force','var')
        force=false;
    end
    if ~isempty(h) && force
        delete(h); h=[];
    end
    if ~isempty(h)
        return
    end
    
    submenu = uimenu('Label','Catalog','Tag','menu_catalog');
    
    catmenu = uimenu(submenu,'Label','Get/Load Catalog');
    
    uimenu(submenu,'Label','Reload last catalog',MenuSelectedField(),@cb_reloadlast,...
        'Enable','off');
    
    uimenu(catmenu,'Label','from *.mat file',...
        MenuSelectedField(), {@cb_importer,@load_zmapfile});
    uimenu(catmenu,'Label','from other formatted file',...
        MenuSelectedField(), {@cb_importer,@zdataimport});
    uimenu(catmenu,'Label','from FDSN webservice',...
        MenuSelectedField(), {@cb_importer,@get_fdsn_data_from_web_callback});
    uimenu(catmenu,'Label','from the current MATLAB Workspace',...
        MenuSelectedField(), {@cb_importer,@cb_catalog_from_workspace});
    
    
    uimenu(submenu,'Label','Save current catalog',MenuSelectedField(),@(~,~)save_zmapcatalog(obj.catalog));
    
    catexport = uimenu(submenu,'Label','Export current catalog...');
    uimenu(catexport,'Label','to workspace (ZmapCatalog)',MenuSelectedField(),@(~,~)exportToWorkspace(obj.catalog,'ZmapCatalog'));
    uimenu(catexport,'Label','to workspace (Table)',MenuSelectedField(),@(~,~)exportToWorkspace(obj.catalog,'table'));
        uimenu(catexport,'Label','to workspace (old ZmapArray)',MenuSelectedField(),@(~,~)exportToWorkspace(obj.catalog,'ZmapArray'));
    
    
    uimenu(catmenu,'Separator','on','Label','Set as main catalog',...
        MenuSelectedField(),@cb_replace_main); % Replaces the primary catalog, and replots this subset in the map window
    uimenu(catmenu,'Separator','on','Label','Reset',...
        MenuSelectedField(),@cb_resetcat); % Resets the catalog to the original selection
    
    uimenu(submenu,'Separator','on',...
        'Label','Edit Raw Catalog Range...',MenuSelectedField(),@cb_editrange);
    
    % choose a time range by clicking on the axes. only available if x-axis is a datetime axis.
    
    uimenu(submenu,'Label','Rename...',MenuSelectedField(),@cb_rename);
    
    uimenu(submenu,'Separator','on',...
        'Label','Memorize Catalog',  MenuSelectedField(), @cb_memorize);
    uimenu(submenu,'Label','Recall Catalog', MenuSelectedField(), @cb_recall);
    
    uimenu(submenu,'Label','Clear Memorized Catalog',MenuSelectedField(),@cb_clearmemorized);
    
    uimenu(submenu,'Label','Combine catalogs',MenuSelectedField(),@cb_combinecatalogs,...
        'Separator','on');
    
    uimenu(submenu,'Label','Compare catalogs - find identical events',MenuSelectedField(),@(~,~)comp2cat);
    

    uimenu(submenu,'Label','Info (Summary)',MenuSelectedField(),@(~,~)info_summary_callback(obj.catalog),...
        'Separator','on');
    
    
    uimenu (submenu,'Label','Decluster the catalog',...
        MenuSelectedField(),@(~,~)ResenbergDeclusterClass(obj.catalog));
    
    function cb_recall(~,~)
        mcm = MemorizedCatalogManager;
        if ~isempty(mcm) && any(mcm.list=="default")
            obj.rawcatalog = mcm.recall();
            
            [obj.mshape,obj.mdate]=obj.filter_catalog();
            obj.map_axes.XLim=bounds2(obj.rawcatalog.Longitude);
            obj.map_axes.YLim=bounds2(obj.rawcatalog.Latitude);
            
            hh=msgbox_nobutton('The catalog has been recalled.','Recall Catalog');
            hh.delay_for_close(1);
        else
            warndlg('No catalog is currently memorized','Recall Catalog');
        end
    end
    
    function cb_memorize(~,~)
        mcm = MemorizedCatalogManager;
        mcm.memorize(obj.catalog);
        hh=msgbox_nobutton('The catalog has been memorized.','Memorize Catalog');
        hh.delay_for_close(1);
    end
    
    function cb_clearmemorized(~,~)
        mcm = MemorizedCatalogManager;
        if isempty(mcm) || ~any(mcm.list=="default")
            warndlg('No catalogs are currently memorized','Clear Memorized Catalog');
        else
            mcm.remove();
            hh=msgbox_nobutton('The memorized catalog has been cleared.','Clear Memorized Catalog');
            hh.delay_for_close(1);
        end
    end
    
    function [catalog,ok]=cb_catalog_from_workspace(opt, fn)
        % TODO Implement this!
        %fig=ancestor(src,'figure');
        ok = false;
        catalog = [];
        ed=errordlg(['not yet fully implemented. To get data from the worskpace into zmap do one of the following:' newline ...
            'for a ZmapCatalog MyCat, use ', newline , ...
            '   ZmapMainWindow(MyCat)'...
            newline 'If loading a table MyCat, use: ' newline '   ZmapMainWindow(ZmapCatalog(MyCat))', newline, newline...
            'You can also specify the figure, as in ZmapMainWindow(fig, MyCat)']);
        app=catalog_from_workbench();
        uiwait(app)
    end
    
    function cb_crop(~,~)
        ax = findobj(obj.fig, 'Type','Axes');
        all_ax=[ax.Xaxis, ax.Yaxis, ax.Zaxis];
        v=ax.View;
        switch ax.Tag
            case 'mainmap_ax'
                fields={'Longitude','Latitude','Depth'};
            case 'cumtimeplot_ax'
                fields={'Date','',''};
            otherwise
                fields={'','',''};
                warning('ZMAP:unknownCatalogCut','Do not know how to crop catalog to these axes');
        end
        
        if isequal(v , [0 90]) % XY view
            style='XY';
        elseif isequal(v,[0 0]) % XZ view
            style='XZ';
        elseif isequal(v,[90 0]) % YZ view
            style='YZ';
        else % all three views
            style='XYZ';
        end
        mask=true(obj.catalog.Count,1);
        if contains(style,'X') && ~isempty(fields{1})
            mask=mask & obj.catalog.(fields{1}) >= ax.XLim(1) &...
                obj.catalog.(fields{1}) <= ax.XLim(2);
        end
        if contains(style,'Y') && ~isempty(fields{2})
            mask=mask & obj.catalog.(fields{2}) >= ax.YLim(1) &...
                obj.catalog.(fields{2}) <= ax.YLim(2);
        end
        if contains(style,'Z') && ~isempty(fields{3})
            mask=mask & obj.catalog.(fields{3}) >= ax.YLim(1) &...
                obj.catalog.(fields{3}) <= ax.YLim(2);
        end
        obj.catalog.subset_in_place(mask);
        zmap_update_displays();
    end
    
    
    function cb_replace_main(~,~)
        ZG.primeCatalog=obj.catalog;
        obj.replot_all();
    end
    
    function cb_shapecrop(~,~)
        if isempty(obj.shape)
            errordlg('No polygon exists. Create one from the selection menu first','Cannot crop to polygon');
            return
        end
        events_in_shape = obj.shape.isInside(obj.catalog.Longitude, obj.catalog.Latitude);
        obj.catalog=obj.catalog.subset(events_in_shape);
        
        zmap_update_displays();
        
        % adjust the size of the main map if the current figure IS the main map
        set(obj.map_axes,...
            'XLim',bounds2(obj.catalog.Longitude),...
            'YLim',bounds2(obj.catalog.Latitude));
    end
    
    function cb_editrange(~,~)
        watchon;
        summ = obj.rawcatalog.summary;
        app=range_selector(obj.rawcatalog);
        waitfor(app);
        if ~isequal(summ, obj.rawcatalog.summary)
            obj.catalog = obj.rawcatalog;
            ZG.maepi = obj.catalog.subset(obj.catalog.Magnitude>=ZG.CatalogOpts.BigEvents.MinMag);
        end
        watchoff
        obj.replot_all;
    end
    
    function cb_rename(~,~)
        oldname=obj.rawcatalog.Name;
        [~,~,newname]=smart_inputdlg('Rename',...
            struct('prompt','Catalog Name:','value',oldname));
        obj.rawcatalog.Name=newname;
        obj.catalog.Name=newname;
    end
    
    
    function cb_combinecatalogs(~,~)
        combine_catalogs;
    end
    
    function cb_importer(src, ev, fun)
        f=get(groot,'CurrentFigure');
        f.Pointer = 'watch';
        drawnow('nocallbacks');
        ok=ZmapImportManager(fun);
        if ok
            % get rid of the message box asking us to load a catalog
            delete(findobj(groot,'-depth', 1, 'Tag','Msgbox_No Active Catalogs'));
            f=obj.fig;
            %delete(obj);
            ZmapMainWindow(f);
        else
            warndlg('Did not load a catalog');
        end
        f.Pointer = 'arrow';
    end
end

function exportToWorkspace(catalog, fmt)
    safername=matlab.lang.makeValidName(catalog.Name);
    fn=inputdlg('Variable Name for export:','Export to workspace',1,{safername});
    if ~isempty(fn)
        safername = matlab.lang.makeValidName(fn{1});
        switch lower(fmt)
        case 'zmapcatalog'
            assignin('base',safername,catalog);
        case 'zmaparray'
            assignin('base',safername,catalog.ZmapArray);
        case 'table'
            assignin('base',safername,catalog.table())
        end
    end
end

function info_summary_callback(mycatalog)
    summarytext=mycatalog.summary('stats');
    f=msgbox(summarytext,'Catalog Details');
    f.Visible='off';
    f.Children(2).Children.FontName='FixedWidth';
    p=f.Position;
    p(3)=p(3)+95;
    p(4)=p(4)+10;
    f.Position=p;
    f.Visible='on';
end
