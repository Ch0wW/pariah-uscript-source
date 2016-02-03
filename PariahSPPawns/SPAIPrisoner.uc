class SPAIPrisoner extends SPAIController;

#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var SPAIRolePrisoner PrisonerRole;


function Restart()
{
    Super.Restart();
    PrisonerRole = SPAIRolePrisoner(myAIRole);
	PrisonerRole.myBot = self;
}


function bool ShouldAcquireEnemy( Pawn potentialEnemy, bool bCanSeePotEnemy )
{
	if(VSize(PotentialEnemy.Location - Pawn.Location) < 1500 || Level.TimeSeconds - getLastHitTime() < 1.0)
		return Super.ShouldAcquireEnemy(potentialEnemy, bCanSeePotEnemy);
	else
		return False;
}

defaultproperties
{
     MeleeRange=5000.000000
     MeleeAnim="Prisoner_Melee01"
}
