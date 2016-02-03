//=============================================================================
// xDomPoint.
// For Double Domination (xDoubleDom) matches.
//=============================================================================
class xDomPoint extends DominationPoint;

var() localized String PointName; // display name of this control point
var() Sound ControlSound;	      // sound played when this control point changes hands
var() Name ControlEvent;          // any actors with tags matching this will be triggered when activity occurs on the control point

var(Material) Material DomCombiner[2];
var(Material) Material CRedState[2];
var(Material) Material CBlueState[2];
var(Material) Material CNeutralState[2];
var(Material) Material CDisableState[2];

var(Material) Shader   DomShader;
var(Material) Material SRedState;
var(Material) Material SBlueState;
var(Material) Material SNeutralState;
var(Material) Material SDisableState;

var(Material) bool     SSelfIllum;

var(Material) float    PulseSpeed;
var xDOMLetter         DomLetter;
var xDOMRing           DOMRing;
var transient byte     NoPulseAlpha;
var			  vector	EffectOffset;

var bool bForceUpdate;
var bool bSkipTouching;
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();      
   
    if ( Role == ROLE_Authority && !(Level.Game.IsA('xDoubleDom')||Level.Game.IsA('Assault')) && (Level.NetMode != NM_Client) )
		bHidden = true;
}

function string GetHumanName()
{
	return PointName;
}

function Touch(Actor Other)
{
    if ( Pawn(Other) == None || Pawn(Other).Health <= 0)
		return;	
    
    // is this domination point controllable right now?
    if (bControllable)
    {
        // touching pawn is now the controlling pawn for this domination point
        ControllingPawn = Pawn(Other);
	    
        // update the domination point's status
        UpdateStatus();
    }
}

function UnTouch(Actor Other)
{
    // is this domination point controllable right now?
    if (bControllable)
    {
        ControllingPawn = None;

        // update the domination point's status
        UpdateStatus();
    }
}

simulated function float Pulse( float x )
{
	if ( x < 0.5 )
	{
		return 2.0 * ( x * x * (3.0 - 2.0 * x) );
	}
	else
	{
		return 2.0 * (1.0 - ( x * x * (3.0 - 2.0 * x) ));
	}
}

simulated function Tick( float t )
{
    local float f;
    local float alpha;

    Super.Tick(t);

    if ( DomShader != None && PulseSpeed != 0.0)
    {
        if (bControllable)
        {
            f = Level.TimeSeconds * PulseSpeed;
	        f = f - int(f);
            alpha = 255.0;
	        ConstantColor(DomShader.SpecularityMask).Color.A = Pulse(f) * alpha;
        }
        else
        {
            ConstantColor(DomShader.SpecularityMask).Color.A = NoPulseAlpha;
        }
    }
}

simulated function PostNetReceive()
{
    if( !bControllable )
        SetShaderStatus(CDisableState[0],SDisableState,CDisableState[1]);
    else if ( ControllingTeam == None )
        SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
    else if ( ControllingTeam.TeamIndex == 0 )
        SetShaderStatus(CRedState[0],SRedState,CRedState[1]);
    else
        SetShaderStatus(CBlueState[0],SBlueState,CBlueState[1]);
}

simulated function SetShaderStatus( Material mat1, Material mat2, Material mat3 )
{
    if( DomCombiner[0] != None )
        Combiner(DomCombiner[0]).Material1 = mat1;
    if( DomCombiner[1] != None )
        Combiner(DomCombiner[1]).Material1 = mat3;
    if( DomShader != None )
    {
        if (SSelfIllum)
        {
            DomShader.SelfIllumination = mat2;
        }
        else if (PulseSpeed != 0.0)
        {
            DomShader.Specular = mat2;
        }
        else
        {
            DomShader.Diffuse = mat2;
        }
    }
}

function UpdateStatus(optional TeamInfo ForcedTeam)
{
	local Actor A;
	local TeamInfo NewTeam;
    local PlayerController PC;
    local Pawn P;

    if ( !bSkipTouching && bControllable && (ControllingPawn == None) )
    {
        // check if any pawn currently touching
		ForEach TouchingActors(class'Pawn', P)
        {
            if (P.Health > 0)
            {
                ControllingPawn = P;
			    break;
            }
        }
	}
	
    // nothing to do if there is already a controlling team but no controlling pawn
    if (ControllingTeam != None && ControllingPawn == None && !bForceUpdate)
        return;

	bForceUpdate = False;
	// who is the current controlling team of this domination point?
    if (ControllingPawn == None)
		NewTeam = None;
	else
        NewTeam = ControllingPawn.Controller.PlayerReplicationInfo.Team;

	if(ForcedTeam!=None)
		NewTeam=ForcedTeam;

	// do nothing if there is no change in the controlling team (and there is a controlling team)
    if ((NewTeam == ControllingTeam) && (NewTeam != None))
		return;

	UpdateAIStatus(NewTeam);
    
	// otherwise we have a new controlling team, or the domination point is being re-enabled
    ControllingTeam = NewTeam;
    
    if (ControllingTeam != None)
	{
        PC = Level.GetLocalPlayerController();
        if (PC != None)
        {
            if (ControllingPawn.Controller == PC)
            {
                Level.Game.EvaluateHint('DomPointTaken', None);
            }
            else if (PC.SameTeamAs(ControllingPawn.Controller))
            {
                Level.Game.EvaluateHint('TeammateTookPoint', None);
            }
            else
            {
                Level.Game.EvaluateHint('EnemyTookPoint', None);
            }
        }
		PlayAlarm();
	}

	if (ControllingTeam == None)
	{
       // goes dark while untouchable (disabled) after a score
        if (!bControllable) 
		{			
            LightType = LT_None;
            SetShaderStatus(CDisableState[0],SDisableState,CDisableState[1]);
            if (DomLetter != None)
                DomLetter.bHidden = true;
            if (DomRing != None)
                DomRing.bHidden = true;
        }
        // goes back to white when neutral again
        else if (bControllable) 
		{            			
            // change light emission properties
			LightHue = 255;
            LightBrightness = 128;
		    LightSaturation = 255;
            LightType = LT_SubtlePulse;
            SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
            if (DomLetter != None)
            {
                DomLetter.bHidden = false;
                DomLetter.SetSkin(0,class'xDomLetter'.Default.NeutralShader);
                DomLetter.NewShader = class'xDomLetter'.Default.NeutralShader;
            }
            if (DomRing != None)
            {
                DomRing.bHidden = false;
                DomRing.SetSkin(0,class'xDomRing'.Default.NeutralShader);
                DomRing.NewShader = class'xDomRing'.Default.NeutralShader;
            }
		}
	}	
	else
	{     
        if ((ControllingPawn!=None && ControllingPawn.Controller.PlayerReplicationInfo.Team.TeamIndex == 0) || (ForcedTeam!=None && ForcedTeam.TeamIndex==0))
		{
            // red team controls it now
            LightType = LT_SubtlePulse;
            LightHue = 0;
            LightBrightness = 255;
			LightSaturation = 128;
            SetShaderStatus(CRedState[0],SRedState,CRedState[1]);
            if (DomLetter != None)
            {
                DomLetter.bHidden = false;
                DomLetter.SetSkin(0, class'xDomLetter'.Default.RedTeamShader);
                DomLetter.NewShader = class'xDomLetter'.Default.RedTeamShader;
            }
            if (DomRing != None)
            {
                DomRing.bHidden = false;
                DomRing.SetSkin(0, class'xDomRing'.Default.RedTeamShader);
                DomRing.NewShader = class'xDomRing'.Default.RedTeamShader;
            }
		}
		else
		{
            // blue team controls it now            
            LightType = LT_SubtlePulse;
            LightHue = 170;
            LightBrightness = 255;
			LightSaturation = 128;
            SetShaderStatus(CBlueState[0],SBlueState,CBlueState[1]);
            if (DomLetter != None)
            {
                DomLetter.bHidden = false;
                DomLetter.SetSkin(0, class'xDomLetter'.Default.BlueTeamShader);
                DomLetter.NewShader = class'xDomLetter'.Default.BlueTeamShader;
            }
            if (DomRing != None)
            {
                DomRing.bHidden = false;
                DomRing.SetSkin(0, class'xDomRing'.Default.BlueTeamShader);
                DomRing.NewShader = class'xDomRing'.Default.BlueTeamShader;
            }
		}
	}
    
    // send the event to trigger related actors
    if(ControlEvent != '')
		foreach AllActors(class'Actor', A, ControlEvent)
			A.Trigger(self, ControllingPawn);
}

function UpdateAIStatus(TeamInfo NewTeam)
{
	local int OldIndex;
    
	// for AI, update DefenderTeamIndex
    OldIndex = DefenderTeamIndex;
	if ( NewTeam == None )
	    DefenderTeamIndex = 255; // ie. "no team" since 0 is a valid team
	else
		DefenderTeamIndex = NewTeam.TeamIndex;
    
    if ( bControllable && (OldIndex != DefenderTeamIndex) )
		TeamGame(Level.Game).FindNewObjectives(self);

}

function ResetPoint(bool enabled)
{
	if ( !bControllable && enabled )
		TeamGame(Level.Game).FindNewObjectives(self);

    bControllable = enabled;
    ControllingPawn = None;
    ControllingTeam = None;
    UpdateStatus();
}

function PlayAlarm()
{
	SetTimer(5.0, false);
	AmbientSound = ControlSound;
}

function Timer()
{
	AmbientSound = None;

    // don't call super here since we don't want it incrementing score!
}

function bool BetterObjectiveThan(GameObjective Best, byte DesiredTeamNum, byte RequesterTeamNum)
{
	if ( (Best == None) || (DefenderTeamIndex == DesiredTeamNum) )
		return true;
	return false;
}

simulated function String GetPointName()
{
    return PointName;
}

defaultproperties
{
     PulseSpeed=1.000000
     ControlSound=Sound'Chapter_4b_Sounds.alarm.AlarmD'
     DomCombiner(0)=Combiner'PariahGameTypeTextures.Extra.DomACombiner'
     CRedState(0)=Texture'PariahGameTypeTextures.SolidColours.Red_SOLID'
     CBlueState(0)=Texture'PariahGameTypeTextures.SolidColours.Blue_SOLID'
     CNeutralState(0)=Texture'PariahGameTypeTextures.SolidColours.White_SOLID'
     CDisableState(0)=Texture'PariahGameTypeTextures.SolidColours.Black_SOLID'
     DomShader=Shader'PariahGameTypeTextures.Extra.PulseAShader'
     SRedState=Texture'PariahGameTypeTextures.Extra.redgrid'
     SBlueState=Texture'PariahGameTypeTextures.Extra.bluegrid'
     SNeutralState=Texture'PariahGameTypeTextures.Extra.greygrid'
     SDisableState=Texture'PariahGameTypeTextures.Extra.greygrid'
     EffectOffset=(Z=60.000000)
     bControllable=True
     DestructionMessage=""
     DefenderTeamIndex=255
     bTeamControlled=True
     DrawScale=0.600000
     SoundRadius=255.000000
     CollisionRadius=60.000000
     CollisionHeight=40.000000
     StaticMesh=StaticMesh'VehicleGamePickupMeshes.Assault.AssaultPointBase'
     PrePivot=(Z=70.000000)
     DrawType=DT_StaticMesh
     SoundVolume=255
     bStatic=False
     bHidden=False
     bAlwaysRelevant=True
     bCollideActors=True
     bUseCylinderCollision=True
     bNetNotify=True
}
