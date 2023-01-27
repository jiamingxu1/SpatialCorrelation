function [] = quickSetupPlot(h,ttl,xlab,ylab,xLU,yLU,leg,legPos)

figure(h);
if ~isempty(xlab); xlabel(xlab); end
if ~isempty(ylab); ylabel(ylab); end
if ~isempty(xLU); xlim([xLU(1) xLU(2)]); end
if ~isempty(yLU); ylim([yLU(1) yLU(2)]); end
if ~isempty(leg); legend(leg,'Position',legPos); end
if ~isempty(ttl); title(ttl); end
set(gca,'FontSize',14);

end