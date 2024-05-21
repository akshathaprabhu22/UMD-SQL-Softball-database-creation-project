USE BUDT703_Project_0507_09


DROP VIEW IF EXISTS [Win Loss Margin]

GO    
CREATE VIEW [Win Loss Margin] AS
SELECT
SsnId,
MAX(CASE WHEN g.gameResult = 'W' Then CAST(Left(gamscore,1) as numeric) - CAST(Right(gamscore,1) as numeric) End) as 'Margin of Win',
MAX(CASE WHEN g.gameResult = 'L' Then CAST(Left(gamscore,1) as numeric) - CAST(Right(gamscore,1) as numeric) End) as 'Margin of Loss'
from dbo.[BUDT703_Project_0507_09.Game] g
group by ssnId

GO
SELECT * FROM [Win Loss Margin]
