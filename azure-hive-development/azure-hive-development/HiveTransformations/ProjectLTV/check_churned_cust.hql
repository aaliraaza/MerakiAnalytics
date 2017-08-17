set ref_ndays_churn = 3;
set elaboration_ref_day = '2016-04-10';

-- order by customerkey and date and number the records

with ord_d as ( 

    select  customerkey, cast(groupkeydate as Date) as Day, TheoCLV, row_number()  
    over (partition by customerkey order by CAST (groupkeydate as Date))  rown
    from 
        (

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
                and groupkeydate >= '2016-04-01' and groupkeydate < '2016-04-10'
	            GROUP BY groupkeydate , customerkey, t2.gametypecode
  
                ) a
            group by groupkeydate,customerkey
            ) b

        ) c
    order by customerkey,Day

), 
 elaboration_last_day_act_diff as ( 

    select customerkey, datediff(${hiveconf:elaboration_ref_day},max(day)) as diff_last_vs_ref_day
    from ord_d
    group by customerkey
    order by customerkey

), churned_info as (

    select customerkey, max(reactivated) as currentReactivation
    from proj_ltv.costumer_base_status    
    group by customerkey

)


--check new costumers and add records to status if any


--insert totally new customers  (0 clv, 0 reactivated)
INSERT INTO TABLE proj_ltv.customer_base_status PARTITION (groupkeydate)

select t1.customerkey, null as churn_date , 0 as reactivated, 0 as cum_theo_clv, 
       min(Day) as last_day_activity, min(Day) as Fist_Day_Activity 
from
     ord_d  t1

where t1.customerkey not in (   
                               select  customerkey 
                                from proj_ltv.customer_base_status                                    
                          )
group by t1.customerkey
order by t1.customerkey


-- insert already churned customers (0 clv, old_reactivated_number +1)  (churned and not current active)
INSERT INTO TABLE proj_ltv.customer_base_status PARTITION (groupkeydate)

select t1.customerkey, null as churn_date , (t2.currentReactivation + 1) as reactivated, 0 as cum_theo_clv, 
       min(Day) as last_day_activity, min(Day) as Fist_Day_Activity 
from
     ord_d  t1 inner join churned_info t2

where t1.customerkey in (   select customerkey
                            from proj_ltv.costumer_base_status a inner join churned_info b   
                            on a.customerkey = b.customerkey   and a.reactivated = b.currentReactivation
                           where churn_date is not null 
                          )

group by t1.customerkey
order by t1.customerkey



-- where pmod(count(distinct day), 2) = 0 


-- datediff calculation
select  t6.cum_theo_clv as prec_CLV, t6.reactivated prec_Reactivated, t6.groupkeydate as prec_Last_Day_Activity, 
        t3.customerkey, t4.TheoCLV as Curr_CLV, t3.rown, t4.rown,
        t3.Day as SuccDate3 , t4.Day as CurrDate4, 
        datediff( t3.Day , t4.Day ) as Succ_Curr_DaysDiff,
        datediff( t3.Day , ${hiveconf:elaboration_ref_day} ) as DaysDiff_curr_vs_elab_ref_day,
        t5.diff_last_vs_ref_day as Last_Day_vs_Elab_ref_diff,
        datediff( t3.Day , t6.groupkeydate ) as Succ_vs_Last_Act_DaysDiff,
        case when datediff( t3.Day , t4.Day ) > ${hiveconf:ref_ndays_churn} then 1 else 0 end as churned
from    
        ord_d as t3 
        left join ord_d as t4 on t3.customerkey = t4.customerkey and ((t3.rown=t4.rown+1) or (t3.rown=t4.rown))  
        left join elaboration_last_day_act_diff as t5 on t3.customerkey = t5.customerkey
        left join
        (
        select *
        from proj_ltv.customer_base_status
        where churn_date is null  
        ) as t6   on t3.customerkey = t6.customerkey
       
group by t3.customerkey, t3.Day , t3.rown, t4.rown , t3.TheoCLV
-- having count(distinct day)>5
order by t3.customerkey, t3.rown, t4.rown 


--delete active customer
--add new costumer_base_status records


-- update last elaboration date in a support table 
--UPDATE proj_ltv.support_data SET last_elaboration_day = cast('2016-04-05' as Date);



--nvl( min(t4.Day) , cast(${hiveconf:ref_day} as Date) ) as CurrDate, 
--datediff( nvl( min(t4.Day) , cast(${hiveconf:ref_day} as Date) ) ,  t3.Day ) as DaysDiff,
--select
--,SUM(c) OVER(PARTITION BY customerid ORDER BY calendar ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Stakes
--from(
--customerid
--select case when a>= 31 then 1 else 0 end as c
--from ....
--) 



