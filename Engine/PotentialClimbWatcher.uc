class PotentialClimbWatcher extends Info
	native;

simulated function Tick(float DeltaTime)
{
	local rotator PawnRot;
	local LadderVolume L;
	local bool bFound;

	if ( Owner == None || !Pawn(Owner).CanGrabLadder() )
	{
		destroy();
		return;
	}

	PawnRot = Owner.Rotation;
	PawnRot.Pitch = 0;
	ForEach Owner.TouchingActors(class'LadderVolume', L)
	{
		
		if ( L.Encompasses(Owner) )
		{
			//cmr -- always allow a climb
			if ( !(Owner.Velocity == Vect(0,0,0) ) && 
				( !L.IsAtTop(Pawn(Owner)) && (Normal(Owner.Velocity) Dot L.LookDir) > 0.9 ) ||
				( L.IsAtTop(Pawn(Owner)) && (Normal(Owner.Velocity) Dot L.LookDir) < 0.1 ) )
			{
				Pawn(Owner).ClimbLadder(L);
				destroy();
				return;
			}
			else
			{
				bFound = true;
			}
		}
	}

	if ( !bFound )
	{
		destroy();
	}
}

defaultproperties
{
}
