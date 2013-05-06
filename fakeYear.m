OccYear=zeros(53,7,24);
specialday = 0;
for wn = 1:53
    for wd = 1:7
        % adding random special days
        if rand(1) < 0.1
            specialday= 1;
        else
            specialday=0;
        end
        for hh = 1:24
%             % schedule perfectly respected
%             if hh < 9 || hh > 18 || wd == 1 || wd == 7 % Standard office hour (at least for this office room! ;) )
%                 OccYear(wn,wd,hh)=0;
%             else
%                 OccYear(wn,wd,hh)=1;
%             end
            % home schedule
            if hh < 6 || hh > 23  % sleep at night
                OccYear(wn,wd,hh)=0; 
            elseif ~specialday && ((hh > 9 && hh < 13) || (hh > 14 && hh < 18)) && (wd ~= 1 && wd ~= 7) % at office
                OccYear(wn,wd,hh)=0;
            elseif ~specialday && (hh > 9 && hh < 17 && wd == 7) % on saturday absent during midday
                OccYear(wn,wd,hh)=0;
            elseif specialday && (wd == 4 || wd == 1) %sometimes on wednesday or sunday nobody is here
                OccYear(wn,wd,hh)=0; 
            else
                OccYear(wn,wd,hh)=1;
            end
            % Adding noise 
            if rand(1) < 1/24 % ~1 presence random per day
                OccYear(wn,wd,hh) = randi(2)-1;
            end
            % Adding holiday
            if wn == 20 || wn==31 || wn == 32 || wn == 33
                OccYear(wn,wd,hh)=0;
            end
        end
    end
end
