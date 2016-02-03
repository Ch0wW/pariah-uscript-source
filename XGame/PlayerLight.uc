//=============================================================================
// PlayerLight.
//=============================================================================
class PlayerLight extends ScaledSprite;

var() float ExtinguishTime;

singular function BaseChange();
 
simulated function Extinguish( Pawn AttachedTo ) // Needs to be re-entrant
{
    GotoState('Extinguishing');
}

state Extinguishing
{
    ignores Extinguish;
    
    simulated function Tick( float DeltaTime )
    {
        ExtinguishTime -= DeltaTime;
        
        if( ExtinguishTime < 0 )
        {
            Destroy();
            return;
        }
        
        SetDrawScale( default.DrawScale * ( ExtinguishTime / default.ExtinguishTime ) );
    }
}

defaultproperties
{
     ExtinguishTime=1.500000
     DrawScale=0.300000
     Mass=0.000000
     RemoteRole=ROLE_None
     Style=STY_Additive
     bStatic=False
     bStasis=False
     bShouldBaseAtStartup=False
}
