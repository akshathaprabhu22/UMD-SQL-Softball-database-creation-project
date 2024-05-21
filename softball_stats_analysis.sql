USE BUDT703_Project_0507_09

--BT1 : What are the average runs per batting category?
;WITH PlayerSummary AS (
  SELECT
    CASE
	  WHEN p.plyAVG < .200 THEN '<.200'
      WHEN p.plyAVG BETWEEN 0.200 AND 0.250 THEN '0.200-0.250'
      WHEN p.plyAVG BETWEEN 0.251 AND 0.300 THEN '0.251-0.300'
      WHEN p.plyAVG > 0.300 THEN '> 0.300'
    END AS [Batting Average Range],
    ROUND(AVG(CAST(p.plyR AS DECIMAL)),2) AS [Average Runs in Season]
  FROM [BUDT703_Project_0507_09.Player] p
  GROUP BY
    CASE
	  WHEN p.plyAVG < .200 THEN '<.200'
      WHEN p.plyAVG BETWEEN 0.200 AND 0.250 THEN '0.200-0.250'
      WHEN p.plyAVG BETWEEN 0.251 AND 0.300 THEN '0.251-0.300'
      WHEN p.plyAVG > 0.300 THEN '> 0.300'
    END
)
SELECT *
FROM PlayerSummary
ORDER BY 2 DESC


--BT2: What is the winning percentage in each state?

SELECT
    l.locState AS 'State',
    COUNT(g.gameResult) AS 'Number of Games Played',
    ROUND((CAST(SUM(CASE WHEN g.gameResult = 'W' THEN 1 ELSE 0 END) AS DECIMAL) / COUNT(g.gameResult)) *100, 2) AS 'Percentage of Games Won'
FROM
    dbo.[BUDT703_Project_0507_09.Location] l
JOIN
    dbo.[BUDT703_Project_0507_09.Has] h ON l.locId = h.locId
JOIN
    dbo.[BUDT703_Project_0507_09.Game] g ON h.gamId = g.gamId
GROUP BY
    l.locState
ORDER BY 2 DESC, l.locState


--BT3: What are the winning percentages against the top 10 tough teams?
SELECT o.[Opponent Name] AS 'Opponent Name', 
ROUND((COUNT(CASE WHEN g.gameResult = 'W' THEN 1 END) * 100.0) / COUNT(*) , 2) as 'Percentage Wins (%)'
FROM dbo.[BUDT703_Project_0507_09.Game] g
LEFT JOIN [BUDT703_Project_0507_09.Has] h ON g.gamId = h.gamId
INNER JOIN  [Top 10 tough teams] o ON h.oppId = o.oppId
GROUP BY o.[Opponent Name]
ORDER BY 'Percentage Wins (%)' ASC


--BT4: How many wins and losses per season?
SELECT
    s.ssnId AS 'Season', 
    COUNT(CASE WHEN g.gameResult = 'W' THEN 1 END) AS 'Total Wins',
    COUNT(CASE WHEN g.gameResult = 'L' THEN 1 END) AS 'Total Losses'
FROM
    dbo.[BUDT703_Project_0507_09.Game] g
JOIN
    dbo.[BUDT703_Project_0507_09.Season] s ON g.ssnId = s.ssnId 
GROUP BY
    s.ssnId

--BT5: What is the maximum win and loss margin per season?
Select
	ssnId,
	MAX(CASE WHEN g.gameResult = 'W' Then CAST(Left(gamscore,1) as numeric) - CAST(Right(gamscore,1) as numeric) End) as 'Margin of Win',
	MAX(CASE WHEN g.gameResult = 'L' Then CAST(Left(gamscore,1) as numeric) - CAST(Right(gamscore,1) as numeric) End) as 'Margin of Loss'
FROM dbo.[BUDT703_Project_0507_09.Game] g
GROUP BY ssnId
