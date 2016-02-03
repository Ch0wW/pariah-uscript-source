class GameplayDevices extends Actor;

var (Havok)		bool		bCanCrushPawns;
var (Havok)		float		CrushSpeed;
var string curAction;
var bool bAllowHudDebug;

function DrawHudDebug(Canvas C, Vector Center)
{
    local vector screenPos;
	local string CurrentState;

	if(!bAllowHudDebug || VSize(Center - Location) > 3000) return;

    screenPos = C.WorldToScreen( Location
                               + vect(0,0,1)*(CollisionHeight / 2) );
    if (screenPos.Z > 1.0) return;

	currentState = "State: "$GetStateName();

    C.SetPos(screenPos.X - 8*Len(currentState)/2, screenPos.y-24);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    C.DrawText( currentState );

    C.SetPos(screenPos.X - 8*Len(curAction)/2, screenPos.y-12);
    C.DrawText( curAction );

}

defaultproperties
{
     CrushSpeed=300.000000
     curAction="No Action"
}
