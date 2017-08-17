select groupkeydate , customerkey, 
       case when sum_net_hold-0.14*sum_net_hold-0.15*sum_net_hold-0.04*(total_stakes-wins) > 0 then sum_net_hold-0.14*sum_net_hold-0.15*sum_net_hold-0.04*(total_stakes-wins) else 0 end as TheoCLV
FROM
    ( 
   SELECT groupkeydate , customerkey,
           sum(case when gametypecode = 'Bingo' then cash_stakes*0.3 else cash_stakes*0.035 end) as sum_net_hold,
           sum(total_stakes) as total_stakes,
           sum(wins) as wins
    FROM 
    (
 	    select groupkeydate , customerkey, t2.gametypecode,
  		       sum( case when actiontypecode = 'Stake' and wallettypecode = 'BEDE_Cash' then amountbasecurrency else 0 end ) as cash_stakes,
               sum( case when actiontypecode = 'Stake' then amountbasecurrency else 0 END) as total_stakes,
               sum( case when actiontypecode = 'Win' then amountbasecurrency else 0 end ) as wins
	    from 	basedb.rapfactgamingactivitydigital t1 inner join proj_galedb.dimgames t2 on t1.gamecode = t2.gamecode
        where  actiontypecode in ('Stake','Win') and wallettypecode = 'BEDE_Cash'
        and groupkeydate >= '2016-04-01' and groupkeydate < '2016-04-03'
	    GROUP BY groupkeydate , customerkey, t2.gametypecode
  
    ) a
    group by groupkeydate,customerkey
    ) b;