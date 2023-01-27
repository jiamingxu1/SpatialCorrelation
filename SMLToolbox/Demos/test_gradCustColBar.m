nCol = 30;
x = 1:nCol;
y = x.^3;
k = log(1:nCol)';
y = k*y;
cbrange = k';

figure; 
for jj=1:3
    
    subplot(1,3,jj); hold on
    
    switch 3
        case 1
            gradStart = [0.5 0.5 0.5];
            gradEnd = [0 0 0];
        case 2
            gradStart = rand(nCol,3);
            gradEnd = [];
        case 3 
            gradStart = [0 0 1];
            gradEnd = [0 1 1];
    end
            
[col,cbh(jj)] = gradCustColBar(nCol, cbrange, gradStart, gradEnd);

for ii = 1:nCol
    plot(x,y(:,ii),'Color',col(ii,:))
end

end
