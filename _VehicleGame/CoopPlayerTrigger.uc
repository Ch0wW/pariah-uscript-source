class CoopPlayerTrigger extends Triggers;

#exec Texture Import File=Textures\CoopTrigger.pcx Name=S_CoopTrigger Mips=Off

var() Name  OptionalNavPoint;
var() float DistanceThreshold;

event Trigger( Actor Other, Pawn EventInstigator )
{
    local Controller C;

	if ( Level.NetMode == NM_DedicatedServer )
		return;

    if(!Level.IsCoopSession() || EventInstigator.Controller == None || !EventInstigator.Controller.IsA('PlayerController'))
    {
        return;
    }

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( (PlayerController(C) != None) && (Viewport(PlayerController(C).Player) != None) && C != EventInstigator.Controller )
		{
		    if(PlayerController(C).Pawn != None && PlayerController(C).Pawn.Health > 0 && !PlayerController(C).IsInState('Dead'))
		    {
		        MoveUp(PlayerController(EventInstigator.Controller), PlayerController(C));
			}
		}
	}
}

function MoveUp(PlayerController Target, PlayerController Other)
{
    local NavigationPoint NP;
    
    if(DistanceThreshold > 0.0 && VSize(Target.Pawn.Location - Other.Pawn.Location) < DistanceThreshold)
    {
        return;
    }
   
    if(OptionalNavPoint != 'None')
    {
        foreach AllActors( class 'NavigationPoint', NP )
        {
            if(NP.Tag == OptionalNavPoint)
            {
                if(Other.Pawn.SetLocation(NP.Location))
                {
                    Other.Pawn.SetRotation(NP.Rotation);
                    return;
                }
            }
        }
    }
    
    // fallback behaviour
    Level.Game.QueueBringForward(Target, Other);
}

defaultproperties
{
     Texture=Texture'VehicleGame.S_CoopTrigger'
}
