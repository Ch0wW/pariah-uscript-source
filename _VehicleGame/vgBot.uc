// vgBot is the VEHICLE-AWARE unreal bot
//	Changes the UnrealChampionship xBot to include run-over avoidance, adjustingaround cars, changing enemies as they leave cars etc)
class vgBot extends xBot
	native;

//AI memory variables
var float	LastNotifyRunOver; //The last time we were notified about being run over


//new function.. let bot know about being run over.
event NotifyRunOver(Pawn car) 
{
	local vector carDir;
	local vector X, Y, Z;
    
	if( Level.TimeSeconds < LastNotifyRunOver + 1.0f)
		return;
	LastNotifyRunOver = Level.TimeSeconds;
	carDir = car.Location - Pawn.Location;
	
	//if(frand() < 0.7) //only dodge half the time?
	//	return;

	GetAxes(Pawn.Rotation,X,Y,Z);
	if ( (carDir Dot Y) > 0 ) //left or right?
	{
		Y *= -1;
		TryToDuck(Y, true);
	}
	else
		TryToDuck(Y, false);
}


//overriding so that adjust will go around pawns with no controller
event bool NotifyBump(actor Other)
{
	local Pawn P;

	Disable('NotifyBump');
	P = Pawn(Other);
	if (P == None)	// || (P.Controller == None )
		return false;
	Squad.SetEnemy(self,P);
	if ( Enemy == P )
		return false;
	if ( CheckPathToGoalAround(P) )
		return false;
	
	if ( !AdjustAround(P) )
		CancelCampFor(P.Controller);
	return false;
}


//override to include Enemy's controller disappearing.
function bool LostContact(float MaxTime)
{
	if ( (Enemy != None) && (Enemy.Controller == None) )
		return true;
	else
		return Super.LostContact(MaxTime);
}

defaultproperties
{
}
