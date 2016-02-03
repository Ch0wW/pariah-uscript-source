//=============================================================================
//=============================================================================
class HavokDropShip extends HavokActor
	placeable;

struct ShipEmitterDesc
{
	var() name AttachPoint;
	var() class<Emitter> EmitterClass;
	var() class<xEmitter> xEmitterClass;
};

var() editinline Array<ShipEmitterDesc> Emitters;

var() class<Emitter> SmokeEmitterClass;
var() class<Emitter> SmokebEmitterClass;

var array<Emitter>		LiveEmitters;
var array<xEmitter>		LivexEmitters;
var() vector			SmokeStart;
var() vector			SmokebStart;
var	() class<Actor>		ExplosionBurstClass;
var	() class<Actor>		ExplosionBurst2Class;
var	() class<Actor>		SmallExploClass;
var Emitter				Smoke1, Smoke2;
var() int				Health;

//Dying
var bool				bDying;
var float				ShipBlowupTimer;
var() float				ShipBlowupTime;
var bool				bExplosion1Done;
var bool				bExplosion2Done;
var float				Explosion1Time;
var float				Explosion2Time;
var(Events) name		OnDeathEvent;

var		MuzzleFlash			MuzFlash;
var	()	class<MuzzleFlash>	MuzFlashClass;
var	()	class<Actor>	ChunkClass;

var() class<DropShipChunks>  SMeshClass[10];

var	()	sound			EXPLSound;
var	()	sound			EXPL2Sound;
var	()	sound			ShipBlowupSound;

//debug
var array<vector> AttachmentPositions;
var array<rotator> AttachmentRotations;


simulated function PostBeginPlay()
{
	local Rotator AttachmentRot;
	local vector AttachmentPos;
	local int i;
	local Emitter e;
	local vector SpawnLoc;

	Super.PostBeginPlay(); 

	for(i=0;i<Emitters.Length;i++)
	{
		if(GetAttachPoint(Emitters[i].Attachpoint, AttachmentPos, AttachmentRot))
		{
			if(Emitters[i].EmitterClass != None)
			{
				SpawnLoc = Location+(AttachmentPos >> Rotation);
				
				//e = spawn( Emitters[i].EmitterClass, self, , SpawnLoc, AttachmentRot );
				e = spawn( Emitters[i].EmitterClass, self );
				AttachTo( e, AttachmentPos, AttachmentRot );
				LiveEmitters[LiveEmitters.Length] = e;
				
				//Note: The CoordinateSystem is set to PTCS_Relative, which means the (X,Y,Z) = (0,0,0)
				//		position for the particles is the position of the emitter actor
				//debug
				AttachmentPositions[AttachmentPositions.Length] = AttachmentPos;
				AttachmentRotations[AttachmentRotations.Length] = AttachmentRot;
			}

		}
	}

	SetTimer(5.0,True);
}


function AttachTo(Actor A, vector offset, rotator rotation)
{
	A.SetBase(self);
	A.SetRelativeLocation(offset);
	A.SetRelativeRotation(rotation);
}


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	if( bDying )
		return;
		
	Health -= Damage;

	if( Health < 0 )
	{
		EmitSmokeAtHitPoint( HitLocation );
		bDying = true;
	}

	Super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
}


simulated function Tick( float dt )
{
	if( bDying ) 
	{
		ShipBlowupTimer += dt;
		 
		if ( !bExplosion1Done && (ShipBlowupTimer >= Explosion1Time) ) 
		{
			bExplosion1Done = true;
			if( ExplosionBurstClass != None )
			{	
				log( "Drop ship Explosion 1 !!!" );
				spawn( ExplosionBurstClass, , , Location );
				if( Level != None && Level.GetLocalPlayerController() != None )
					Level.GetLocalPlayerController().PlaySound( EXPLSound,, TransientSoundVolume );
			}
		}

		if ( !bExplosion2Done && (ShipBlowupTimer >= Explosion2Time) ) 
		{
			bExplosion2Done = true;
			if( ExplosionBurstClass != None )
			{	
				log( "Drop ship Explosion 2 !!!" );
				spawn( ExplosionBurstClass, , , Location );
				if( Level != None && Level.GetLocalPlayerController() != None )
					Level.GetLocalPlayerController().PlaySound( EXPL2Sound,, TransientSoundVolume );	
			}		
			PlaySound( EXPL2Sound,, TransientSoundVolume );
		}
		
		if ( ShipBlowupTimer >= ShipBlowupTime )
		{
			//log("ship explosion");
			BlowUpShip();
		}		
	}
}


simulated function EmitSmokeAtHitPoint( vector FinalHitLocation )
{
	Smoke1 = spawn( SmokeEmitterClass, self,, FinalHitLocation, );
	Smoke1.SetBase( self );

	Smoke2 = spawn( SmokebEmitterClass, self, ,FinalHitLocation, );
	Smoke2.SetBase( self );

	spawn( SmallExploClass, , , FinalHitLocation );

	//First explosion happens randomly within the period [0, 0.5*ShipBlowupTime ]
	Explosion1Time = (0.5 * FRand()) * ShipBlowupTime;
	
	//First explosion happens randomly within the period [0.5*ShipBlowupTime, 0.8*ShipBlowupTime ]
	Explosion2Time = (0.5 + 0.3 * FRand()) * ShipBlowupTime;
	
	//log( "Drop ship explosion 1 time = " $ Explosion1Time );
	//log( "Drop ship explosion 2 time = " $ Explosion2Time );	
}


simulated function BlowUpShip()
{
	local int i;
	local DropShipChunks SM;

	//Send a death event out
	if( OnDeathEvent != '' )
		TriggerEvent( OnDeathEvent, self, None );

	if( Level != None && Level.GetLocalPlayerController() != None )
		Level.GetLocalPlayerController().PlaySound( ShipBlowupSound,, TransientSoundVolume );
	
	if( ExplosionBurst2Class != None )
		spawn( ExplosionBurst2Class, , , Location );

	if ( Smoke1 != None )
		Smoke1.Kill();
	
	if ( Smoke2 != None )
		Smoke2.Kill();
		
	for( i=0; i<10; i++ )
	{
		SM = Spawn( SMeshClass[i],Self );

		if ( SM!=None )
			SM.SetLocation( Location + SM.ELoc );
	}

	for( i=0; i<LiveEmitters.Length; i++ )
		if ( LiveEmitters[i]!=None )
			LiveEmitters[i].Destroy();
			
	Destroy();
}

defaultproperties
{
     Health=2000
     ShipBlowupTime=1.100000
     EXPLSound=Sound'Sounds_Library.Weapon_Sounds.73-longer_dynamite_blast5'
     EXPL2Sound=Sound'Sounds_Library.Weapon_Sounds.91-fireball1'
     ShipBlowupSound=Sound'Sounds_Library.Weapon_Sounds.73-longer_dynamite_blast5'
     SmokeEmitterClass=Class'VehicleEffects.ShipDamageSmoke'
     ExplosionBurstClass=Class'VehicleEffects.ShipBurst'
     ExplosionBurst2Class=Class'VehicleEffects.Ship2ndBurst'
     SmallExploClass=Class'VehicleEffects.LobBurst'
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     ChunkClass=Class'VehicleEffects.DropShipChunks'
     SMeshClass(0)=Class'VehicleEffects.DSChunk_a'
     SMeshClass(1)=Class'VehicleEffects.DSChunk_b'
     SMeshClass(2)=Class'VehicleEffects.DSChunk_c'
     SMeshClass(3)=Class'VehicleEffects.DSChunk_d'
     SMeshClass(4)=Class'VehicleEffects.DSChunk_e'
     SMeshClass(5)=Class'VehicleEffects.DSChunk_f'
     SMeshClass(6)=Class'VehicleEffects.DSChunk_g'
     SMeshClass(7)=Class'VehicleEffects.DSChunk_h'
     SMeshClass(8)=Class'VehicleEffects.DSChunk_i'
     SMeshClass(9)=Class'VehicleEffects.DropShipChunks'
     Emitters(0)=(AttachPoint="PEmitter01",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(1)=(AttachPoint="PEmitter02",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(2)=(AttachPoint="ThrusterFrontLeft",EmitterClass=Class'VehicleEffects.shipthruster_Side')
     Emitters(3)=(AttachPoint="ThrusterFrontRight",EmitterClass=Class'VehicleEffects.shipthruster_Side')
     SmokeStart=(X=40.000000,Y=800.000000,Z=-100.000000)
     SmokebStart=(X=240.000000,Y=-750.000000,Z=-100.000000)
     TransientSoundVolume=2.000000
     StaticMesh=StaticMesh'PariahDropShipMeshes.ZipLineDropShipMeshes.DropShip_ZipLine'
     Begin Object Class=HavokParams Name=VGHavokDebrisHParams
         Mass=40.000000
         LinearDamping=0.300000
         AngularDamping=0.300000
         StartEnabled=True
         Restitution=1.000000
         ImpactThreshold=100000.000000
     End Object
     HParams=HavokParams'VehicleEffects.VGHavokDebrisHParams'
     Physics=PHYS_None
     bNoDelete=False
}
