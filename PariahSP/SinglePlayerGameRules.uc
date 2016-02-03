class SinglePlayerGameRules extends GameRules;

/*
function int NetDamage( int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	//original damage is the original damage passed to TakeDamage();
	if( (instigatedBy!=None && instigatedBy.Controller!=None && instigatedBy.Controller.IsA('PlayerController')) &&
		(injured!=None && injured.Controller!=None && injured.Controller.IsA('DriveController')) )
	{
		Damage*=2;

	}
	
	return Super.NetDamage(OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
}
*/

defaultproperties
{
}
