%OccLoad
fid = fopen('occ001treatedNH.csv');
C = textscan(fid, '%f,%s %8s,%u8');
fclose(fid);
%2001-12-18 11:09:57
S = strcat(C{2},{' '},C{3});
dv = datevec(S, 'yyyy-mm-dd HH:MM:SS');

%weekday(datenum(dv)); %1 = sunday
%plot(datenum(dv), C{4});

%It works by detection of absence: if two presence events are distanced of more
%than X (3?) hours, user is declared absent until first event seen.
%A present event means that user is present during the current hour.
%-> construction of matrix 52*7*24 full year of presence/absence
%-> construction of matrix 7*24 average week of presence/absence
%-> construction of more than 1 week absence duration histogram
Timeout = 3;

i = 1;
present = 0;
LastSeenPresenceDate = datenum(dv(i,:)); %[in days]
LastDateSet = 0;
CurrentYear = 2000;
waittwoi = 0;

while (i < 155308)
    if dv(i,1) ~= CurrentYear || i == 155307
        if waittwoi == 2
            %Prepare and save data
            OccAveWeek = squeeze(mean(OccYear(2:52,:,:),1));
            %save(strcat('''','year',datestr(dv(i-1,:),'yyyy'),''''),OccAveWeek, OccYear);
            if CurrentYear ~= 2000
                save(strcat('year',datestr(dv(i-3,:),'yyyy')),'OccAveWeek', 'OccYear');
            end
            %Reinitialize matrix
            OccYear = ones(53,7,24)*2;
            CurrentYear = dv(i,1)
            waittwoi = 0;
        else
            waittwoi = waittwoi + 1;
        end
    end
    if present == 0
        if C{4}(i) == 1 % User enters room
            %Presence is declared, set only current hour
            present = 1;
            OccYear(weeknum(datenum(dv(i,:))),weekday(datenum(dv(i,:))), dv(i,4)+1)= 1;
            %Absence is set backwards
            for hh = 1:floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)
                datecurrentnum = datenum(dv(i,:))-hh/24;
                [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 0;
            end
            %Set presence during timeout
            for hh = floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)+1:floor((datenum(dv(i,:)) - LastSeenPresenceDate)*24)
                datecurrentnum = datenum(dv(i,:))-hh/24;
                [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 1;
            end
            LastSeenPresenceDate = datenum(dv(i,:));
        else
            %Absence is set backwards (should never be called if function is called at occupancy changes only)
            disp('Still absent, should not be called!')
            for hh = 0:floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)
                datecurrentnum = datenum(dv(i,:))-hh/24;
                [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 0;
            end
            %Set presence during timeout
            for hh = floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)+1:floor((datenum(dv(i,:)) - LastSeenPresenceDate)*24)
                datecurrentnum = datenum(dv(i,:))-hh/24;
                [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 1;
            end
        end
    else
        if C{4}(i) == 1
            if datenum(dv(i,:)) > LastSeenPresenceDate + Timeout/24 %User is present again, but previous absence was longer than timeout
                %Presence is declared, set only current hour
                OccYear(weeknum(datenum(dv(i,:))),weekday(datenum(dv(i,:))), dv(i,4)+1)= 1;
                %Absence is set backwards
                for hh = 1:floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)
                    datecurrentnum = datenum(dv(i,:))-hh/24;
                    [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                    OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 0;
                    if weekday(datecurrentnum) == 0
                        datestr(datecurrentnum)
                        weeknum(datecurrentnum)
                        temph+1
                    end
                end
                %Set presence during timeout
                for hh = floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)+1:floor((datenum(dv(i,:)) - LastSeenPresenceDate)*24)
                    datecurrentnum = datenum(dv(i,:))-hh/24;
                    [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                    OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 1;
                end
            else %User is present again, and previous absence was shorter than timeout
                %Set presence backwards
                for hh = 0:floor((datenum(dv(i,:)) - LastSeenPresenceDate)*24)
                    datecurrentnum = datenum(dv(i,:))-hh/24;
                    [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                    OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 1;
                end
            end
            LastSeenPresenceDate = datenum(dv(i,:));
        else
            if datenum(dv(i,:)) > LastSeenPresenceDate + Timeout/24 %User is absent, and timeout is finished
                %Absence is declared and set backwards
                present = 0;
                for hh = 0:floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)
                    datecurrentnum = datenum(dv(i,:))-hh/24;
                    [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                    OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 0;
                end
                %Set presence during timeout
                for hh = floor((datenum(dv(i,:)) - LastSeenPresenceDate-Timeout/24)*24)+1:floor((datenum(dv(i,:)) - LastSeenPresenceDate)*24)
                    datecurrentnum = datenum(dv(i,:))-hh/24;
                    [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                    OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 1;
                end
            else %User is absent, but timeout is not finished: thus user still present, set presence backwards (called too often?)
                for hh = 0:floor((datenum(dv(i,:)) - LastSeenPresenceDate)*24)
                    datecurrentnum = datenum(dv(i,:))-hh/24;
                    [~, ~, ~, temph, ~, ~] = datevec(datecurrentnum);
                    OccYear(weeknum(datecurrentnum),weekday(datecurrentnum), temph+1) = 1;
                end
            end
        end
    end
    i = i + 1;
end
save(strcat('year',datestr(dv(i,:),'yyyy')),'OccAveWeek', 'OccYear');

