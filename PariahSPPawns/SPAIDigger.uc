class SPAIDigger extends SPAIController;

function Restart()
{
    Super.Restart();
    Pawn.GotoState('Waiting');
    Focus = None;
}
function SpawnExclaimManager(){}
function initAIRole(){}
function SelectAction() {}
function Tick(float dT){}
function botTickPosition(StagePosition pos){}
function DamageAttitudeTo(Pawn Other, float Damage) {}

function StageOrder_Awaken() 
{
    Super.StageOrder_Awaken();
    Pawn.GotoState('Waiting');
}

function DrawHUDDebug(Canvas C)
{
    local vector screenPos;

    if (!bDebugLogging || Pawn == None)	return;

    screenPos = WorldToScreen( Pawn.Location 
                               + vect(0,0,1)*Pawn.CollisionHeight );
    if (screenPos.Z > 1.0) return;

    C.SetPos(screenPos.X, screenPos.y-24);
    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
    if(SPPawnDigger(Pawn).TargetPawn != None)
        C.DrawText( Pawn.GetStatename() @ VSize(Pawn.Location - SPPawnDigger(Pawn).TargetPawn.Location ) );
}

defaultproperties
{
}
