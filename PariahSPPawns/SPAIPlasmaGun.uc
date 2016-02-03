class SPAIPlasmaGun extends SPAIController;

function SendBulletMiss(Pawn Enemy, Vector offset)
{
    Enemy.NotifyBulletMiss(Enemy.Location + offset, 1);
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.BotPlasmaGun"
     MinNumShots=2
     MaxNumShots=3
     NumShotsUntilReload=10
     MaxShotPeriod=2.000000
     MaxSecondsOfLOS=4.000000
     sweepTimerPeriod=0.500000
     ReloadAnim="Plasma_Reload"
     PopUpClass=Class'PariahSPPawns.SPAIPopUpPlasmaGun'
     bPlayWizzSnd=True
     Skill=1.000000
}
