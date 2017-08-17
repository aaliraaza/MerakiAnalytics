set ref_days = 3;

select *
from
	(
  SELECT first_day_active,
		 a.customerkey,
  STDDEV_POP(B_NetEntCASINO_TransferIn) AS B_NetEntCASINO_TransferIn_Std,
  STDDEV_POP(B_MicroGamingCASINO_TransferIn) AS B_MicroGamingCASINO_TransferIn_Std,
  STDDEV_POP(B_MicroGamingCASINO_Stake) AS B_MicroGamingCASINO_Stake_Std,
  STDDEV_POP(B_BlueprintOTHER_TransferOut) AS B_BlueprintOTHER_TransferOut_Std
  from proj_ltv.game_data_gros as a
	  left join
	  (
	  select customerkey,min(groupkeydate) as first_day_active,date_add(min(groupkeydate),${hiveconf:ref_days}-1) as lastday
	  from proj_ltv.game_data_gros
	  group by customerkey
	  ) as b
	  on a.customerkey = b.customerkey 
  where a.groupkeydate >= b.first_day_active and a.groupkeydate <= b.lastday and first_day_active = '2016-07-09' 
  group by first_day_active,a.customerkey
	  ) as c
where B_NetEntCASINO_TransferIn_Avg > 0 or B_MicroGamingCASINO_TransferIn_Avg > 0 or 
      B_MicroGamingCASINO_Stake_Avg > 0 or B_BlueprintOTHER_TransferOut_Avg > 0;

