class ACTION_PlayAnim extends ScriptedAction;

const SCRIPTED_ANIM = 30;
var(Action) name    BaseAnim;
var(Action) float   BlendInTime;
var(Action) float   BlendOutTime;
var(Action) float   AnimRate;
var(Action) byte    AnimIterations;
var(Action) bool    bLoopAnim;
var(Action) float   StartFrame;
var(Action) int     Channel;
var(Action) float   BlendAmmount;
var(Display) const enum EBone
{
    RB_Spine1,
    RB_Spine2,
    RB_Head,
	RB_Root,
} BaseBone;

function bool InitActionFor(ScriptedController C)
{
	// play appropriate animation
	C.AnimsRemaining = AnimIterations;
	if ( PawnPlayBaseAnim(C,true) )
		C.CurrentAnimation = self;
	return false;	
}

function SetCurrentAnimationFor(ScriptedController C)
{
	if ( C.Pawn.IsAnimating(Channel) )
		C.CurrentAnimation = self;
	else
		C.CurrentAnimation = None;
}

function bool PawnPlayBaseAnim(ScriptedController C, bool bFirstPlay)
{
	if ( BaseAnim == '' )
		return false;
	
	C.bControlAnimations = true;
	if ( bFirstPlay )
    {
        if( Channel == 0)
            C.Pawn.bWaitForAnim = true;
        else
            C.Pawn.AnimBlendParams(Channel, BlendAmmount, 0.0, 0.0, getBone(C, BaseBone));
        C.Pawn.PlayAnim(BaseAnim,AnimRate,BlendInTime, Channel);
    }
	else if ( bLoopAnim || (C.AnimsRemaining-- > 0) )
    {
        C.Pawn.LoopAnim(BaseAnim,AnimRate, , Channel);
    }
	else
    {
        return false;
    }
		
	if( StartFrame > 0.0 )
		C.Pawn.SetAnimFrame( StartFrame, 0, 1);
				
	return true;
}

function CleanUp(ScriptedController C)
{
    log("CLEANUP");
    if( Channel !=0 )
    {
        C.Pawn.AnimBlendToAlpha(Channel, 0, 0.1);
    }
}

function string GetActionString()
{
	return ActionString@BaseAnim;
}

function name getBone(ScriptedController C, EBone type)
{
    switch(type)
    {
    case RB_Spine1:
        return C.Pawn.SpineBone1;
        break;
    case RB_Spine2:
        return C.Pawn.SpineBone2;
        break;
    case RB_Head:
        return C.Pawn.HeadBone;
        break;
    case RB_Root:
        return C.Pawn.RootBone;
        break;
    }
}

defaultproperties
{
     BlendInTime=0.200000
     BlendOutTime=0.200000
     AnimRate=1.000000
     BlendAmmount=1.000000
     BaseBone=RB_Root
     ActionString="play animation"
     bValidForTrigger=False
}
