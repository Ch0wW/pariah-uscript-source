class SPPawnDigger extends SPPawn
    native;

var()   int     Damage;
var()   int     DamageRadius;
var()   int     MomentumTransfer;
var()   float   TunnelSpeed;
var()   Float   LeapDistance;
var()   float   LeapSpeed;
var()   Sound   ExplodeSound;
var()   Sound   TunnelSound;   
var()   Sound   DigOutSound;
var()   Name    DigOutAnim;
var()   Name    DigInAnim;
var()   Sound   DigInSound;
var()   Name    FlyingAnim;
var()   class<Emitter>      TrailEmitterClass;
var()   class<Emitter>      DirtEmitterClass;
var()   class<Emitter> ExplodeEmitter, ExplosionDistortionClass;

var()   float testConstA, testConstB;

var class<DamageType> MyDamageType;
var     float       DetectionTimer; // check target every this many seconds
var     Emitter     TrailEmitter;
var     Emitter     DirtEmitter;
var     Pawn        TargetPawn;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function Destroyed()
{
    if( TrailEmitter !=None)
        TrailEmitter.Destroyed();
    if( DirtEmitter != None)
        DirtEmitter.Destroy();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    Controller.PawnDied( self );
    Blowup(Location);
}


function Touch(Actor Other)
{
    Blowup(Location);
}

function Bump(Actor Other)
{
    Blowup(Location);
}

simulated function HitWall( Vector HitNormal, Actor Wall )
{
    BlowUp(Location);
}

function AcquireTarget()
{
	local Pawn A;
	local float Dist, BestDist;

    TargetPawn = None;

    foreach VisibleCollidingActors(class'Pawn', A, 2500.0)
    {
        if ( A.IsHumanControlled())
	    {
	    	Dist = VSize(A.Location - Location);
	    	if (TargetPawn == None || Dist < BestDist)
	    	{
    			TargetPawn = A;
                Controller.Focus = TargetPawn;
    			BestDist = Dist;
            }
	    }
	}
}

simulated function BlowUp(Vector HitLocation)
{
    HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );

    if(ExplodeEmitter != None)
		spawn(ExplodeEmitter,self,,Location,Rotation);
	if(ExplosionDistortionClass != None)
		spawn(ExplosionDistortionClass,self,,Location,Rotation);

	if(ExplodeSound != None)
		PlaySound(ExplodeSound);

    if(controller != None)
        Controller.PawnDied(self);

    if( PlayerShadow != None )
        PlayerShadow.Destroy();

    Destroy();
}

/*auto */
state Waiting
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible;

    function Timer()
    {
        if(Controller == None)
            return;

        AcquireTarget();
        if (TargetPawn != None)
            GotoState('Tunelling');
    }

    function BeginState()
    {
        bHidden=True;
        bBlockZeroExtentTraces=false;
        TargetPawn = None;
        SetPhysics(PHYS_None);
        Velocity = vect(0,0,0);
        SetTimer(DetectionTimer, True);
        Timer();
    }
BEGIN:
   
}

state Tunelling
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible;

   
    simulated function Timer()
    {
        local vector NewLoc;
        local rotator TargetDirection;
        local float TargetDist;

        if (TargetPawn == None)
            GotoState('DigOut');

        if (Physics != PHYS_Walking)
		    return;

        NewLoc = TargetPawn.Location - Location;
        TargetDist = VSize(NewLoc);
        if (TargetDist < 2500.0)
        {
            NewLoc.Z = 0;
            Velocity = Normal(NewLoc) * TunnelSpeed;
            if (TargetDist < LeapDistance - 200)
            {
                GotoState('DigOut');
            }
            else
            {
                TargetDirection = Rotator(NewLoc);
                TargetDirection.Yaw -= 16384;
                TargetDirection.Roll = 0;
            }
         }
         else
         {
            GotoState('DigIn');
         }
    }

    function BeginState()
    {
        LeapDistance = class'TrajectoryCalculator'.static.GetMaxRange(self, class'Actor', LeapSpeed);
        
        if(TrailEmitterClass != none)
	    {
		    if(TrailEmitter == None)
            {   TrailEmitter = spawn(TrailEmitterClass,self);
                TrailEmitter.SetBase(self);
            }
            else
            {
                TrailEmitter.Start();
            }
	    }
        if(DirtEmitterClass != none)
	    {
            if(DirtEmitter == None)
            {
		        DirtEmitter = spawn(DirtEmitterClass,self);
                DirtEmitter.SetBase(self);
            }
            else
            {
                DirtEmitter.Start();
            }
	    }

	    if(TunnelSound != None)
            PlaySound(TunnelSound, , TransientSoundVolume, , 1000, , true);

        SetPhysics(PHYS_Walking);
    }

    function EndState()
    {
        if(TunnelSound != None)
            StopOwnedSound(TunnelSound);
        TrailEmitter.Stop();
    }

BEGIN:
    Timer();
    SetTimer(DetectionTimer / 2, true);
}

state DigOut
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible;

BEGIN:
    PlaySound(DigOutSound);
    Velocity = vect(0,0,0);
    SetRotation( rot(0,0,0) );
    
    bHidden=False;
    PlayAnim('up',,0);
    FinishAnim();
    DirtEmitter.Stop();
    bBlockZeroExtentTraces=true;

    GotoState('Fly');
}

state Fly
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible;

    event Landed(vector HitNormal)
    {
        GotoState('DigIn');
    }

    function Rotator FindLeapDir(vector startLoc, vector targetLoc, out float Speed)
    {
        local float outThetaLow;
	    local float outThetaHigh; 
	    local float outInterceptTimeLow;
	    local float outInterceptTimeHigh; 
        local float Theta;
	    local int NumSolutions;
	    local Rotator LeapRotation;
        local float d, g;
        
        d = VSize(targetLoc - startLoc);
        g = class'TrajectoryCalculator'.static.GetGravityConstant( self, class'Actor' );
        Speed = Sqrt(d*g) + 100;
        Speed = Clamp(Speed, 750, LeapSpeed);
        
        // set leap parameters
	    LeapRotation = rotator(TargetPawn.Location - Location); // rotation to aim directly at target

	    NumSolutions = class'TrajectoryCalculator'.static.GetInverseTrajectory(
			    self,
			    class'Actor',
			    Speed, 
			    startLoc, 
			    targetLoc, 
			    outThetaLow, 
			    outThetaHigh, 
			    outInterceptTimeLow, 
			    outInterceptTimeHigh );

        if(NumSolutions == 0)
        {
            NumSolutions = class'TrajectoryCalculator'.static.GetInverseTrajectory(
			    self,
			    class'Actor',
			    Speed, 
			    startLoc, 
			    startLoc + Normal(targetLoc - startLoc)*(VSize(targetLoc - startLoc)-100), 
			    outThetaLow, 
			    outThetaHigh, 
			    outInterceptTimeLow, 
			    outInterceptTimeHigh );

            log("NoSolutions, redo:"@VSize(targetLoc - startLoc)@LeapDistance - 100@NumSolutions);
            
            return FindLeapDir(startLoc, startLoc + Normal(targetLoc - startLoc)*(LeapDistance - 100), Speed );
        }

        if(d > 800)
            Theta = outThetaLow;
        else
            Theta = outThetaHigh;

	    // modify the leap pitch
	    if( Theta < 0 )
		    LeapRotation.Pitch =  class'TrajectoryCalculator'.static.RadianToRotation(-Theta);
	    else
		    LeapRotation.Pitch = 65535 - class'TrajectoryCalculator'.static.RadianToRotation(Theta);

        /*
        class'TrajectoryCalculator'.static.VerifyTrajectory( 
			self, 
			class'Actor', 
			Speed, 
			startLoc, 
			targetLoc, 
			TargetPawn, 
			outThetaLow,,,,true
			);

        class'TrajectoryCalculator'.static.VerifyTrajectory( 
			self, 
			class'Actor', 
			Speed, 
			startLoc, 
			targetLoc, 
			TargetPawn, 
			outThetaHigh,,,,true
			);
        */

        return LeapRotation;
    }

    simulated function Fly()
    {
        local Rotator flyDir;
        local float speed;

        SetPhysics(PHYS_Falling);
        flyDir = FindLeapDir(Location, TargetPawn.Location, speed);
        Velocity = Vector( flyDir ) * speed;
    }

    simulated function Tick(float dT)
    {
        Super.Tick(dT);
        SetRotation( Rotator(Velocity) );
    }

BEGIN:
    LoopAnim('Fly');
    Fly();
}

state DigIn
{
ignores SeePlayer, HearNoise, KilledBy, EnemyNotVisible;

BEGIN:
    Velocity = vect(0,0,0);
    Controller.Focus = None;
    SetRotation( rot(0,0,0) );
    DesiredRotation = rot(0,0,0);
    
    bBlockZeroExtentTraces=false;
    PlayAnim('down',0.5,0);
    DirtEmitter.Start();
    FinishAnim();
    DirtEmitter.Stop();
    bHidden=True;

    Sleep(2.0);
    GotoState('Waiting');
}

defaultproperties
{
     Damage=21
     DamageRadius=250
     MomentumTransfer=5000
     TunnelSpeed=800.000000
     LeapSpeed=1200.000000
     DetectionTimer=0.500000
     ExplodeSound=Sound'WeaponSounds.Misc.explosion3'
     TunnelSound=Sound'GeneralAmbience.firefx12'
     DigOutSound=Sound'PariahGameSounds.Mines.LaserMineTrip'
     DigInSound=Sound'PariahGameSounds.Mines.LaserMineTrip'
     TrailEmitterClass=Class'VehicleEffects.DavidTireDustB'
     DirtEmitterClass=Class'VehicleEffects.DavidTireDirt'
     ExplodeEmitter=Class'VehicleEffects.GrenadeExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.ParticleRocketExplosionSmallDistort'
     MyDamageType=Class'VehicleWeapons.VGRocketLauncherDamage'
     bRagdollCorpses=False
     Health=20
     ControllerClass=Class'PariahSPPawns.SPAIDigger'
     race=R_Guard
     bPhysicsAnimUpdate=False
     CollisionHeight=60.000000
     Mesh=SkeletalMesh'PariahDiggers.Digger'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem102
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem102'
     Skins(0)=Shader'PariahWeaponTextures.Diggers.Digger01'
     Skins(1)=Shader'PariahWeaponTextures.Diggers.Digger01'
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
     bHidden=True
     bBlockZeroExtentTraces=False
     bRotateToDesired=False
}
