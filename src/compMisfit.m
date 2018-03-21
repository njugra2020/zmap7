function compMisfit(mi2, stressParams) % autogenerated function wrapper
    %  COMPMISFIT Compare Misfits of Different Stress Models
    % adds the stress parameters to a growing list of misfits
    % August 95 by Zhong Lu and Alex Allmann
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun(mfilename('fullpath'));
    
    persistent xNumber yMisfit cumuMisfit loopNumber obsNum StressPara
    mif99=findobj('Type','Figure','-and','Name','Compare Misfits of Different Stress Models');
    
    
    
    if isempty(mif99)
        mif99 = figure_w_normalized_uicontrolunits( ...
            'Name','Compare Misfits of Different Stress Models',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        
        hold on
        
        %initiate variables
        loopNumber = 0;
        xNumber = [];
        yMisfit = [];
        cumuMisfit = [];
        stressPara =[];
        xNumber = [1:length(mi2(:,1))]';
        obsNum = length(mi2);
    else
        delete(findobj(mif99,'Type','axes'));
    end
    
    figure(mif99)
    
    hold on
    
    loopNumber = loopNumber + 1;
    yMisfit(:,loopNumber) = mi2(:,2);
    cumuMisfit(:,loopNumber) = cumsum(yMisfit(:,loopNumber));
    
    % save the parameters of the stress model
    stressPara(loopNumber,:) = [stressParams.sig,...
        stressParams.plu,...
        stressParams.az,...
        stressParams.R,...
        stressParams.phi];
    
    increment = 100;  % offset between curves.
    
    lineattributes = {'ro','yo','mo','c.','b.','r.','y*','m*','c+','b+'};
    markersizes = [4 7 10 7 12 17 5 8 5 8];
    ax=gca;
    
    [lastRow,colI] = sort(cumuMisfit(obsNum,:));
    for i = 1 : loopNumber
        plot(ax,xNumber, cumuMisfit(:,colI(i)) + increment * (i-1) , lineattributes{i}, ...
            'MarkerSize', markersizes(i) );
        hold on
    end
    
    stress = stressPara.subset(colI);
    grid(ax,'on');
    
    xlabel('Number of Earthquake','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    hold off;
end
