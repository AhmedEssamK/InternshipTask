CREATE TABLE Teams (
    TeamID INT PRIMARY KEY,
    TeamName VARCHAR(255),
    FoundedYear INT,
    HomeCity VARCHAR(255),
    ManagerName VARCHAR(255),
    StadiumName VARCHAR(255),
    StadiumCapacity INT,
    Country VARCHAR(255)
);

CREATE TABLE Players (
    PlayerID INT PRIMARY KEY,
    TeamID INT,
    Name VARCHAR(100),
    Position VARCHAR(50),
    DateOfBirth DATE,
    Nationality VARCHAR(50),
    ContractUntil DATE,
    MarketValue INT,
	foreign key (teamid) references teams(teamID) on delete cascade

);


CREATE TABLE Matches (
    MatchID INT PRIMARY KEY,
    Date DATE,
    HomeTeamID INT,
    AwayTeamID INT,
    HomeTeamScore INT,
    AwayTeamScore INT,
    Stadium VARCHAR(100),
    Referee VARCHAR(100),
	foreign key (hometeamid) references teams(teamID) on delete cascade,
	foreign key (awayteamid) references teams(teamID) on delete cascade
);

CREATE TABLE PlayerStats (
    StatID INT PRIMARY KEY,
    PlayerID INT,
    MatchID INT,
    Goals INT,
    Assists INT,
    YellowCards INT,
    RedCards INT,
    MinutesPlayed INT,
    FOREIGN KEY (PlayerID) REFERENCES players(PlayerID) ON DELETE CASCADE,
    FOREIGN KEY (MatchID) REFERENCES matches(MatchID) ON DELETE CASCADE
);

CREATE TABLE TransferHistory (
    TransferID INT PRIMARY KEY,
    PlayerID INT,
    FromTeamID INT,
    ToTeamID INT,
    TransferDate DATE,
    TransferFee DECIMAL(10, 2),
    ContractDuration INT,
    FOREIGN KEY (PlayerID) REFERENCES players(PlayerID) ON DELETE CASCADE,
    FOREIGN KEY (FromTeamID) REFERENCES teams(TeamID) ON DELETE CASCADE,
    FOREIGN KEY (ToTeamID) REFERENCES teams(TeamID) ON DELETE CASCADE
)

	Alter table matches add constraint fk_hometeam foreign key (hometeamid) references teams(teamID) on delete cascade
	Alter table matches add constraint fk_awayteam foreign key (awayteamid) references teams(teamID) on delete cascade

Alter table transferhistory add constraint fk_player FOREIGN KEY (PlayerID) REFERENCES players(PlayerID) ON DELETE CASCADE

Alter table players add constraint fk_team foreign key (teamid) references teams(teamID) on delete cascade

SELECT * from transferhistory th where not exists( select * from players pl where th.playerid = pl.playerid)

SELECT * from players pl where not exists ( select * from playerstats ps where pl.playerid = ps.playerid) --34 players dont have stats

insert into PlayerStats (PlayerID, MatchID, Goals, Assists, YellowCards, RedCards, MinutesPlayed)
select PlayerID, NULL, NULL, NULL, NULL, NULL, NULL
from players
where PlayerID in (
    select PlayerID
    from players pl
    where not exists (
        select 1
        from PlayerStats ps
        where pl.PlayerID = ps.PlayerID
    )
); --tried adding nulls in stat ids


Insert into players (playerid, teamid, name, position, dateofbirth, nationality, contractuntil, marketvalue) VALUES
    (31, 6, Null, Null, Null, Null, '2024-2-24', 28000000) -- adding missing player after getting some info from data

Select * from teams where playerid = 366


Select matchid, sum(goals) as Totalgoals from playerstats group by matchid


Select pl.PlayerID, pl.name as PlayerName, t.teamname as CurrentTeam, sum(ps.goals) as TotalGoals , sum(ps.assists) as TotalAssists, avg(ps.minutesplayed) as AverageMinutesPlayed,
	CONCAT(floor(sum(ps.minutesplayed) / 90), ' matches ', sum(ps.minutesplayed) % 90, ' mins') as EstimatedMatchesPlayed,
	case when sum(ps.minutesplayed) > 300 then 1
	else 0
	end as PlayerOver300Min,
	case when DATE_PART('year', AGE(pl.dateofbirth)) between 25 and 30 then 1 
	else 0 
	end as AgeBetween25and30,
	max(CASE 
            when ps.goals >= 3 THEN 1 
            else 0 
        end)
     AS Scored3PlusGoalsInMatch,
	case
		when exists(
			Select 1
			from transferhistory th
			join teams tr ON th.fromteamid = tr.teamID OR th.toteamid = tr.teamID
			where tr.country = 'France' AND th.playerid = pl.playerid
	) then '1'
	when (t.country = 'France')
	then 'Youth'
	else '0'
	end as PlayedInFrance,
	(Select min(th.transferdate) from transferhistory th join teams tr ON th.fromteamid = tr.teamID OR th.toteamid = tr.teamID
			where tr.country = 'France' and th.playerid = pl.playerid)
	as DateJoinedFrenchTeam,
	case 
        when exists (
            select 1
            from matches m
            join teams tt on m.HomeTeamID = tt.TeamID or m.AwayTeamID = tt.TeamID
            where tt.Country = 'Italy' 
              and m.Stadium = tt.StadiumName
              and (m.HomeTeamID = (select teamid from teams where teamname = t.teamname)
                   OR m.AwayTeamID = (select teamid from teams where teamname = t.teamname))
              and exists (
                  select 1    
                  from playerstats ps_sub
                  where ps_sub.PlayerID = pl.PlayerID
                    and ps_sub.MatchID = m.MatchID
              )
        ) then 1 
        else 0 
    end as PlayedAMatchInItaly,
	case
		when exists(
			Select 1
			from transferhistory th
			join teams tr on th.fromteamid = tr.teamID or th.toteamid = tr.teamID
			Where tr.country = 'Italy' and th.playerid = pl.playerid
	) then '1'
	When (t.country = 'Italy')
	then 'Youth'
	else '0'
	end as PlayedInItaly,
	(Select min(th.transferdate) from transferhistory th join teams tr ON th.fromteamid = tr.teamID OR th.toteamid = tr.teamID
			Where tr.country = 'Italy' and th.playerid = pl.playerid)
	as DateJoinedItalyTeam,
	case 
        when exists (
            select 1
            from matches m
            join teams tt on m.HomeTeamID = tt.TeamID or m.AwayTeamID = tt.TeamID
            WHERE tt.Country = 'Italy' 
              and m.Stadium = tt.StadiumName
              and (m.HomeTeamID = (select teamid from teams where teamname = t.teamname)
                   OR m.AwayTeamID = (select teamid from teams where teamname = t.teamname))
              and exists (
                  select 1
                  from playerstats ps_sub
                  where ps_sub.PlayerID = pl.PlayerID
                    and ps_sub.MatchID = m.MatchID
              )
        ) then 1 
        else 0 
    end as PlayedAMatchInItaly
	from players pl 
	join teams t 
	on pl.teamid = t.teamid
	left join playerstats ps
	on pl.playerid = ps.playerid
	group by pl.PlayerID, pl.name, t.teamname, t.country

select * from transferhistory where playerid = 43




