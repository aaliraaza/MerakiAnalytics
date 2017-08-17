SELECT customerkey,B_NetEntCASINO_TransferIn, 
                   B_MicroGamingCASINO_TransferIn,
                   B_MicroGamingCASINO_Stake,
                   B_BlueprintOTHER_TransferOut
from proj_ltv.game_data_gros
where customerkey = 22040570 and groupkeydate >= '2016-07-09' and groupkeydate <= '2016-07-15'