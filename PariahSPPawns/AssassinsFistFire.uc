class AssassinsFistFire extends VGInstantFire;

var float		LastFireTime;

var	()	Sound				FiringSound;
var ()	Sound				WindDownSound;

var StocktonsFistAltBeam Beam;

function PostBeginPlay(){
	Super.PostBeginPlay();
}

function Destroyed(){
	Super.Destroyed();
	if(Beam != none) {
		Beam.Destroy();
		Beam = none;
	}
}


function InitEffects(){
    Super.InitEffects();
	if(Beam == none)
		Beam = Spawn(class'PariahSPPawns.StocktonsFistAltBeam', self);
	if(Beam != none) {
		Beam.SetRelativeLocation(vect(0, 0, 0) );
		Beam.bHidden = true;
		Beam.bPaused = true;
	}
}


function PlayAmbientSound(Sound aSound){}


simulated function bool CanTarget(Pawn P)
{
	if(P == none || P == Instigator)
		return false;

	if(P.IsA('MostlyDeadPawn') )
		return false;

    return (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team);
}

function EffectTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;//, HitLoc, HitNorm;
    local Actor Other;//, Target;
	local Material HitMat;

	X = Vector(Dir);
	End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

	if(Other == None)
    {
        HitLocation = End;
	}
	Beam.SetLocation(Start);
	Beam.mSpawnVecA = HitLocation;
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;//, HitLoc, HitNorm;
    local Actor Other;//, Target;
	local Material HitMat;
	local float damageAmount;//boneDist, //, closest;
	local Material.ESurfaceTypes HitSurfaceType;
	X = Vector(Dir);
	End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

	if ( Other != None && Other != Instigator )
    {
		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle')) {
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			}
			else {
				damageAmount = PersonDamage;

				if(InStr(GetMeshName(), "Keeper") >= 0)
					// keepers count as vehicles rather than people
					damageAmount = VehicleDamage;

				Other.TakeDamage(damageAmount, Instigator, HitLocation, Momentum*X, DamageType);
			}

			if(!Other.IsA('Pawn') && HitEffectClass != None && HitEffectProb >= FRand() ) {
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
				{
					Level.QuickDecal(HitLocation, HitNormal, Other, 50.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
			}
		}
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand() )
            {
				HitSurfaceType = EST_Default;
				if(Other.bStatic)
				{
					Level.QuickDecal(HitLocation, HitNormal, Other, 50.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
				}
            }
        }
	}
	else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
	}

	Beam.mSpawnVecA = HitLocation;

	if(Other != none && Other.IsA('Pawn') ) {
		// set pawn on fire
		if(Other.IsA('VGPawn') )
			VGPawn(Other).FireInstigator = Instigator;
	}

}


simulated function ModeTick(float dt)
{
	local float trueDelta;

	trueDelta = Level.TimeSeconds - LastHeatTime;

	Super.ModeTick(dt);
}

function StartFiring()
{
	GotoState( 'Firing' );
	Weapon.Ammo[0].bRegen=false;
}

simulated state Firing
{
    simulated function BeginState()
    {
		if(Beam != none) {
			Beam.bHidden = false;
			Beam.bPaused = false;
		}
	}

	function EndState()	{
		if(Beam != none) {
			Beam.bHidden = true;
			Beam.bPaused = true;
		}
	}

	function ModeDoFire()
	{
		Super.ModeDoFire();
	}

    simulated function ModeTick(float dt)
    {
		local float trueDelta;
		local Vector StartTrace;
		local Rotator R, Aim;
		local vector X, Y, Z;

		trueDelta = Level.TimeSeconds - LastHeatTime;

        if (Weapon.ThirdPersonActor != none){
		  R = Weapon.ThirdPersonActor.Rotation;
		}
		if(Weapon.bIndependantPitch)
		{
			R.Pitch += Weapon.RealPitch;
		}
		GetAxes( R, X, Y, Z );
		StartTrace = Weapon.GetFireStart( X, Y, Z );

		Aim = AdjustAim(StartTrace, AimError);

		//EffectTrace(StartTrace + vect(50,0,-50), Aim);

        EffectTrace(Weapon.Instigator.Location + vect(0,0,25), Aim);
        Super.ModeTick(dt);

	}
    function StopFiring()
    {
		GotoState('');
    }
}

simulated state Reload
{
	simulated function BeginState(){
		Weapon.PlayIdle();
	}

	function EndState()	{
		NextFireTime = Level.TimeSeconds;
	}

	event ModeDoFire()	{
		local AIController AIC;
		AIC = AIController(Instigator.Controller);
        if ( AIC != None )
		{
			AIC.StopFiring();
		}
	}

    simulated function ModeTick(float dt) {	}
}

simulated function bool AllowFire()
{
	return true;
}

defaultproperties
{
     TraceRange=6000.000000
     Momentum=500.000000
     TracerFreq=0.000000
     DamageType=Class'VehicleWeapons.VGAssaultDamage'
     HitEffectClass=Class'VehicleWeapons.VGFragHitEffects'
     VehicleDamage=25
     PersonDamage=10
     MaxHeatTime=5.000000
     MaxCoolTime=3.000000
     bAnimateThird=False
     AmmoPerFire=1
     RecoilPitch=300
     FireRate=0.150000
     RecoilTime=0.200000
     BotRefireRate=0.990000
     aimerror=500.000000
     MaxFireNoiseDist=2500.000000
     PreFireAnim="None"
     FireAnim="FireLoop"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="VGAssaultRifleFire"
     PreFireForce="PlayerPlasmaGunFire"
     SpreadStyle=SS_Line
     bModeExclusive=False
     bPawnRapidFireAnim=True
}
