lena= 718;
% a=textread('adhpres.txt');
% aa=[a  a];
% b= reshape (aa',lena,1);

OccYear=zeros(4,7,24);
i=1;
for wn = 1:size(OccYear,1)
    for wd = 1:7
        for hh = 1:24
            if i <= lena && b(i) > 0.5
                OccYear(wn,wd,hh)=1;
            end
            i=i+1;
        end
    end
end
