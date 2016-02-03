class SPAIRocketLauncher extends SPAIController;

function vector GetTweakedFireSpot( Actor target ) {
    return target.Location + vect(0,0,-1) * target.CollisionHeight;
}

defaultproperties
{
     AssignedWeapon="VehicleWeapons.BotRocketLauncher"
     MinNumShots=1
     MaxNumShots=1
     NumShotsUntilReload=1
     MinShotPeriod=3.000000
     MaxShotPeriod=3.500000
     ReloadAnim="Rocket_Reload"
     PopUpClass=Class'PariahSPPawns.SPAIPopUpRocketLauncher'
     Skill=7.000000
}
