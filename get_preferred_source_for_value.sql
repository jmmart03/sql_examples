--this query returns the top entrypoint value for a given user
--each user can self-select from a number of entrypoints, so we want to see what each user prefers over the past year

with user_totals as (
	select
		p.username
		,p.entrypoint_name
		,count(p.login_id) as 'logins'
		,row_number() over (partition by p.account order by count(p.login_id) desc) as 'rn'
	from tower..fact_logins p
	where 
		p.login_date>=dateadd(year,-1,getdate())
	group by
		p.username
		,p.entrypoint_name
)

select
	*
from user_totals
where rn=1
