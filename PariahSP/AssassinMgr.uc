//-----------------------------------------------------------
//
//-----------------------------------------------------------
class AssassinMgr extends Actor
placeable;

var int CombinedAttackCount;
var int iNumberOfAttacks;

var int iAttacksBetweenCharge;
var int iNumberOfAssassins;
var bool bSpawnedAssassins;
var bool bSpawnedBoss;
var bool bAllowedToAttack;

defaultproperties
{
     iAttacksBetweenCharge=3
     bAllowedToAttack=True
}
