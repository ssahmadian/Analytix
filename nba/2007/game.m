% read in data for 2007
fname = '/home/shaun/scrape/nba/2007/playbyplay/ALL_GAMES.txt';
[gameID time evt1 pnt1 evt2 pnt2] = textread(fname, '%d %d %s %d %s %d', 'delimiter', ',','endofline','\n');

%%
% determine the point differential for each game
games = unique(gameID);

for i=1:length(games)
   gmask=find(games(i)==gameID);
   score = [pnt1(gmask) - pnt2(gmask)];
   diff(i,1:2) = [games(i) score(end)];
   tm = find(time(gmask)>60 & time(gmask)<120);
   t60= gmask(tm(end));
   %time(t60)
   score60 = [pnt1(t60) - pnt2(t60)];
   diff60(i,1:2) = [games(i) score60(1)];
end


%%
% segment by point differential
tie = find(abs(diff60(:,2))==0);
small = find(abs(diff60(:,2))<=5 & abs(diff60(:,2))>0);
medium = find(abs(diff60(:,2))<=10 & abs(diff60(:,2))>5);
large = find(abs(diff60(:,2))>10);

%%
Lfouls = [];
% large deficits
for gid = 1:length(large)
    id = games(large(gid));
    gmask=find(id==gameID);

    tm = time(gmask);
    fl1 = strfind(evt1(gmask),'foul');
    fl2 = strfind(evt2(gmask),'foul');
    flm1 = find(cellfun('isempty',fl1)==0);
    flm2 = find(cellfun('isempty',fl2)==0);
    
    Lfouls = [Lfouls tm(flm1)' tm(flm2)'];
    
end

%%
Mfouls = [];
% small deficits
for gid = 1:length(medium)
    id = games(medium(gid));
    gmask=find(id==gameID);

    tm = time(gmask);
    fl1 = strfind(evt1(gmask),'foul');
    fl2 = strfind(evt2(gmask),'foul');
    flm1 = find(cellfun('isempty',fl1)==0);
    flm2 = find(cellfun('isempty',fl2)==0);
    
    Mfouls = [Mfouls tm(flm1)' tm(flm2)'];
    
end

%%
Sfouls = [];
% small deficits
for gid = 1:length(small)
    id = games(small(gid));
    gmask=find(id==gameID);

    tm = time(gmask);
    fl1 = strfind(evt1(gmask),'foul');
    fl2 = strfind(evt2(gmask),'foul');
    flm1 = find(cellfun('isempty',fl1)==0);
    flm2 = find(cellfun('isempty',fl2)==0);
    
    Sfouls = [Sfouls tm(flm1)' tm(flm2)'];
    f = length(find([tm(flm1)' tm(flm2)']<120));
    Sfouls_team(gid,:) = [small(gid) f];
    
end
%%
Tfouls = [];
% small deficits
for gid = 1:length(tie)
    id = games(tie(gid));
    gmask=find(id==gameID);

    tm = time(gmask);
    fl1 = strfind(evt1(gmask),'foul');
    fl2 = strfind(evt2(gmask),'foul');
    flm1 = find(cellfun('isempty',fl1)==0);
    flm2 = find(cellfun('isempty',fl2)==0);
    
    Tfouls = [Tfouls tm(flm1)' tm(flm2)'];
    
end

%%
figure; 
subplot(1,4,1); 
[tbin tout] = hist(Tfouls);
bar(tout, tbin./length(tie));
subplot(1,4,2);
[sbin sout] = hist(Sfouls);
bar(sout, sbin./length(small));
subplot(1,4,3); 
[mbin mout] = hist(Mfouls);
bar(mout, mbin./length(medium));
subplot(1,4,4); 
[lbin lout] = hist(Lfouls);
bar(lout, lbin./length(large));

%%
% team with ~1min left in tie games
Tdiff60 = diff60(tie, 2);
Tdiff = diff(tie,2);
Tchanges = find([sign(Tdiff60) - sign(Tdiff)] ~= 0);


% trailing team with ~1min left in small deficit games
Sdiff60 = diff60(small,2);
Sdiff = diff(small,2);

% find teams that altered outcome
Schanges = find([sign(Sdiff60) - sign(Sdiff)] ~= 0);
Smask = small(Schanges);

% number of fouls for teams that altered outcome
[st Sindex_change] = ismember(Smask,Sfouls_team(:,1));
figure;hist(Sfouls_team(Sindex_change,2),max(Sfouls_team(Sindex_change,2)));
change = Sfouls_team(Sindex_change,2);

% number of fouls for teams that did NOT alter outcome
[st Sindex_same]=setdiff(Sfouls_team(:,1),Smask);
figure;hist(Sfouls_team(Sindex_same,2),max(Sfouls_team(Sindex_same,2)));
same = Sfouls_team(Sindex_same,2);

figure; 
subplot(1,3,1); qqplot(change, same);
subplot(1,3,2); qqplot(change);
subplot(1,3,3); qqplot(same);

%-------------------
Mdiff60 = diff60(medium,2);
Mdiff = diff(medium,2);
Mchanges = find([sign(Mdiff60) - sign(Mdiff)] ~= 0);
