/*
	Approximate flying area for a dropship which keeps a list of vgpawns that are in it
	Assumptions:
		- only one shit monitors that area
	xmatt
*/
class DropShipArea extends Actor
	native
	placeable;

#exec Texture Import File=textures\DropShipAreaIcon.tga Name=DropshipIcon Mips=Off MASKED=1

var() float				Radius;
var() float				Height;
var array<VGPawn>		Detected;
var VGPawn				Targetted; //the pawn that the dropship turret is targetting

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


function PostBeginPlay()
{
	SetCollisionSize( Radius, Height );
	SetTimer(1.0,false);
}


simulated function Timer()
{
	local VGPawn P;
	
	ForEach CollidingActors( class'VGPawn', P, Radius, Location )
	{
		if( P.Race != R_Guard )
			Touch(P);
	}
}


simulated function bool AnEnemyIsIn()
{
	RemoveDeadReferences();
	return (Detected.Length != 0);
}


simulated function Pawn SetATarget()
{
	local int i;
	
	if( Detected.Length == 0 )
		return None;

	for( i=0; i < Detected.Length; i++ )
	{
		if( Detected[i] == Level.GetLocalPlayerController() )
		{
			Targetted = Detected[i];
			return Detected[i];
		}
	}
	
	Targetted = Detected[0];
	return Detected[0];
}


simulated function bool IsPlayerIn()
{
	local int i;
	
	RemoveDeadReferences();
	for( i=0; i < Detected.Length; i++ )
	{
		if( Detected[i].Controller.IsA('SinglePlayerController') )
			return true;
	}
	return false;
}


event Touch( Actor A )
{
	local VGPawn P;
	P = VGPawn(A);
	if( P != None && (P.Race != R_Guard) )
	{
		log("dropship area detected vgpawn " $ A );
		Detected[Detected.Length] = P;
	}
}


event UnTouch( Actor A )
{
	local int i, num;
	local VGPawn P;
	P = VGPawn(A);
	if( P == None || (P.Race == R_Guard) )
		return;

	num = Detected.Length;
	for( i=0; i < num; i++ )
	{
		if( Detected[i] == P )
		{
			if( Targetted == P )
				Targetted = None;

			log("Removed a pawn from the dropship area detected list");
			Detected.Remove(i,1);
			
			return;
		}
	}
}


simulated function RemoveDeadReferences()
{
	local int i, num;

	//Remove dead references
	num = Detected.Length;
	i = 0;
	while( i < Detected.Length )
	{
		if( Detected[i] == None || (Detected[i].Health <= 0) )
		{
			Detected.Remove(i,1);
			if( Detected.Length == 0 )
				break;
		}
		else
		{
			i++;
		}
	}
}

defaultproperties
{
     Radius=4000.000000
     Height=10000.000000
     DrawScale=2.000000
     Texture=Texture'VehicleGame.DropshipIcon'
     Tag="DropShipArea2"
     bHidden=True
     bCollideActors=True
}
