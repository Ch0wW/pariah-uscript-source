class TriggeredPlaySound extends Triggers;

var()		sound	Sound;
var()		float	Volume;
var()		float	Pitch;
var()		bool	bAttenuate;


event Trigger( Actor Other, Pawn EventInstigator )
{
	// play appropriate sound
	if ( Sound != None )
		PlaySound(Sound,SLOT_None,Volume,true,,Pitch,bAttenuate);	
}

defaultproperties
{
     Volume=1.000000
     Pitch=1.000000
     bAttenuate=True
}
