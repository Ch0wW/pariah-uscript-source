class PlayerTurretDummyWeaponFire extends VGInstantFire;

var() int	MaxSpreadAngle;
var() sound FiringSound;

var() class<MuzzleFlash>	MuzFlashClass;

var	float LastFireTime;
var() vector TraceOffset;
var() float TraceDist;			//used as max acquire range

var PlayerTurret Turret;

var	float MaxRollSpeed;
var	float RollSpeed;
var	float SpinTime;		//how long has it been spinning up/down
var	float MaxSpinTime;	//time after spining up or down to fire or stop spinning
var	float CurrentRoll;

var() int BarrelWindUpAcc;
var() int BarrelWindDownAcc;

var int CurrentBarrel;	// which barrel we're currently firing from


simulated function bool AllowFire()
{
	return true;
}

function Destroyed()
{
	Super.Destroyed();
}

function InitEffects()
{
    Super.InitEffects();
}

function DoFireEffect()
{
}

auto state Idle
{
	event ModeDoFire() {}
	function ModeTick(float dt) {}
	function BeginState()
	{
	}
	function StartFiring()
	{
        Turret = PlayerTurretDummyWeapon(Weapon).Turret;
		GotoState('SpinUp');
	}
}

simulated function FireCommon(vector start, vector end, vector TracerStart, optional bool bFireTracer)
{
	local Actor	Other;
	local vector HitLocation, HitNormal, trajectory;
	local rotator TraceRot;
	local Material HitMat;
//	local Tracer T;

	if( Weapon.Role < ROLE_Authority )
		return;

    Other = Trace(HitLocation, HitNormal, End, Start, true, , HitMat );

	if( Other != none && Other != self && Other != Turret)
	{
		trajectory = Normal(HitLocation - start);
        if ( !Other.bWorldGeometry )
        {
			if(Other.IsA('VGVehicle'))
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*trajectory, DamageType);
			else
				Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*trajectory, DamageType);
        }
        else
        {
        	if( !Other.IsA('Pawn') && HitEffectClass != None )
				HitEffectClass.static.SpawnHitEffect( Other, HitLocation, HitNormal, , HitMat );
        }
	}
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

	TraceRot = rotator(HitLocation - TracerStart);

	//Tracer
//	if(bFireTracer) {
		Tracer(spawn(TracerClass,self,,TracerStart, TraceRot) );
//		log("... barrel = "$CurrentBarrel$"; tracer hit = "$HitLocation$", start = "$TracerStart$", rot = "$TraceRot$", Other = "$Other);
//		if(T != none)
//			T.SetLocation(TracerStart);
//	}

	//Muzzle flash
//	DoFireEffect( start, TraceRot );

	//Turret.PlayFiringSound();
}

simulated function vector GetTurretTarget()
{
	local vector start, end;
	local rotator TipRot, R;
	local Coords TipCoords;

	local vector HitLocation, HitNormal;
	local Material HitMat;

	if(Turret == none)
		return vect(0,0,0);

	TipCoords = Turret.GetBoneCoords('UpperMainDummy');
	TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );

	//Start does not start from top barrel, but from the very center
	R = TipRot;
	R.Roll = 0;
	start = TipCoords.Origin;// + (TraceOffset >> R);
	end = start + TraceDist * Vector(TipRot);

	Trace(HitLocation, HitNormal, End, Start, true, , HitMat );
	return HitLocation;
}

state Firing
{
	function BeginState()
	{
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
        Turret.SetAnimAction('Fire');

        Turret.StartFlash();
	}
	simulated function ModeTick(float dt)
	{
		Super.ModeTick(dt);
	}
	event ModeDoFire()
	{
		local vector start, end, tracerStart;
		local rotator TipRot, R;
		local Coords TipCoords;
		local Rotator RandDeltaRot;

		if(Turret == none)
			return;

		LastFireTime = Level.TimeSeconds;

		CurrentBarrel++;
		if(CurrentBarrel >= 2)
			CurrentBarrel = 0;

		if(Weapon.Role == ROLE_Authority)
        {
			RandDeltaRot.Yaw = MaxSpreadAngle * (2.0*FRand() - 1.0);
			RandDeltaRot.Pitch = MaxSpreadAngle * (2.0*FRand() - 1.0);
			RandDeltaRot.Roll = MaxSpreadAngle * (2.0*FRand() - 1.0);

			TipCoords = Turret.GetBoneCoords('UpperMainDummy');
//			log("tipcoord = "$TipCoords.Origin);

			TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );

			//Start does not start from top barrel, but from the very center
			R = TipRot;
			R.Roll = 0;
			start = TipCoords.Origin+vector(tipRot)*100;
			end = start + TraceDist*(vector(tipRot)+VRand()*FRand()*Spread);

			if(CurrentBarrel == 1)
				TipCoords = Turret.GetBoneCoords('FX1');
			else
				TipCoords = Turret.GetBoneCoords('FX2');

			TipRot = OrthoRotation( TipCoords.XAxis, TipCoords.YAxis, TipCoords.ZAxis );
			tracerStart = TipCoords.Origin; //+(TraceOffset>>TipRot);

			FireCommon(start, end, tracerStart, true);
		}

		NextFireTime += FireRate*Weapon.FireRateAtten;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
        if(bUseForceFeedback)
	        ClientPlayForceFeedback(FireForce); 
	}

	function StopFiring()
	{
        Turret.StopFlash();
		GotoState('SpinDown');
	}
}

state SpinUp
{
	event ModeDoFire() {}
	simulated function ModeTick(float dt)
	{
	}

	function StopFiring()
	{
		GotoState('SpinDown');
	}

Begin:
    Turret.SetAnimAction('FirePre');
	Sleep(0.5);
	CurrentBarrel = -1;
	GotoState('Firing');
}

state SpinDown
{
	event ModeDoFire() {}
	simulated function ModeTick(float dt)
	{
	}

	function StartFiring()
	{
        Turret = PlayerTurretDummyWeapon(Weapon).Turret;		
		GotoState('SpinUp');
	}

Begin:
    Turret.SetAnimAction('FireEnd');
	Sleep(0.5);
	GotoState('Idle');
}

defaultproperties
{
     BarrelWindUpAcc=200000
     BarrelWindDownAcc=200000
     CurrentBarrel=-1
     TraceDist=20000.000000
     MaxRollSpeed=200000.000000
     MaxSpinTime=0.300000
     FiringSound=Sound'SM-chapter03sounds.TurretOneSecondLoopB'
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     TraceOffset=(X=110.000000)
     Momentum=1000.000000
     TracerFreq=0.000000
     DamageType=Class'Engine.DamageType'
     HitEffectClass=Class'VehicleWeapons.VGTurretHitEffects'
     TracerClass=Class'VehicleGame.Tracer'
     VehicleDamage=15
     PersonDamage=15
     FireRate=0.100000
     Spread=0.010000
     FireAnim="'"
     FireForce="VGAssaultRifleFire"
}
