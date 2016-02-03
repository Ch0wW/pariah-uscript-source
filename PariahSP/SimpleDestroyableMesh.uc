class SimpleDestroyableMesh extends GameplayDevices
	placeable;


var() int MaxHealth;
var int Health;
var int AccumulatedDamage;

// names of attach points that mark out opposite corners of cubes
// within which damage must occur for it to be counted against health
// - each box requires two entries
var() array<name>			HitBoxes;
var transient array<vector> HitBoxCorners;

struct DestroyEmitterDesc
{
	var() name AttachPoint;
	var() Vector SpawnLocation;
	var() Rotator SpawnRotation;
	var() class<Emitter> EmitterClass;
	var() class<xEmitter> xEmitterClass;
};

var(EventDestroy) name DestroyEvent;
var(EventDestroy) Sound DestroySound;
var(EventDestroy) editinline Array<DestroyEmitterDesc> DestroyEmitters;
var(EventDestroy) StaticMesh DestroyedMesh;
var(EventDestroy) bool	bRemoveMeshOnDestroy;
var(EventDestroy) float	DestroyEventDelay;
var(EventDestroy) bool  bCauseHurtOnDestruction;
var(EventDestroy) float DestructionHurtDamage;
var(EventDestroy) float DestructionHurtRadius;
var(EventDestroy) float DestructionHurtMomentum;
var(EventDestroy) class<DamageType> DestructionHurtDamageType;

var StaticMesh OriginalMesh;
var Pawn SavedInstigator;

var(EventDamage) name DamageEvent;
var(EventDamage) int DamageEventThresshold;
var(EventDamage) editinline array< class<DamageType> > ValidDamageTypes;
var(EventDamage) editinline Array<DestroyEmitterDesc> DamageEmitters;

struct ThresholdDamageEmitter
{
    var() int                   DamageThreshold;
    var() DestroyEmitterDesc    DamageEmitter;
    var bool                    bSpawned;
};
var(EventDamage) editinline Array<ThresholdDamageEmitter> ThresholdDamageEmitters;

var(Events) editconst const Name hReset;
var(Events) editconst const Name hDestroy;

var (Sound)     Sound       ImpactSound;
var (Sound)     float       ImpactSoundVolScale;

var bool bInvulnerable; // cmr hack for stockton fight

var float DrawScale3DX,DrawScale3DY,DrawScale3DZ;

var bool bGetBent;

replication
{
//	unreliable if(Role == ROLE_Authority)
//		GetBent;
	unreliable if(Role==ROLE_Authority)
		DrawScale3DX,DrawScale3DY,DrawScale3DZ;
	unreliable if((Role==ROLE_Authority && bGetBent) || (Role < ROLE_Authority && !bGetBent))
		bGetBent;

}

simulated event PostNetReceive()
{
	local Vector ds;

	if( DrawScale3DX!=DrawScale3D.x ||
		DrawScale3DY!=DrawScale3D.y ||
		DrawScale3DZ!=DrawScale3D.z )
	{
		ds.x=DrawScale3DX;
		ds.y=DrawScale3DY;
		ds.z=DrawScale3DZ;

		
		log("calling drawscale3d");
		SetDrawScale3D(ds);
	}

	if(bGetBent && Role < ROLE_Authority)
	{
		GetBent(None, None);
		bGetBent=false;
	}


}

function SetInvulnerable(bool b)
{
	if(b)
		curAction="Invulnerable";
	else
		curAction="No Action";

	bInvulnerable=b;
}

simulated function PostNetBeginPlay()
{
	local int i;
	local vector v;
	local rotator r;

	DrawScale3DX=DrawScale3D.x;
	DrawScale3DY=DrawScale3D.y;
	DrawScale3DZ=DrawScale3D.z;


	if(Role==ROLE_Authority)
	{
		Health = MaxHealth;
	}
	OriginalMesh = StaticMesh;


	// cache all the various attach points
	//
	SetDrawType( DT_StaticMesh );		// force this so we can get attach points

	HitBoxCorners.Length = HitBoxes.Length;
	for ( i = 0; i < HitBoxes.Length; i++ )
	{
		GetAttachPoint( HitBoxes[i], HitBoxCorners[i], r );
	}
	for(i = 0; i< DamageEmitters.Length; i++)
	{
		if( DamageEmitters[i].AttachPoint != '' && GetAttachPoint(DamageEmitters[i].Attachpoint, v, r))
		{
			DamageEmitters[i].SpawnLocation = v;
			DamageEmitters[i].SpawnRotation = r;
		}
	}
	for(i = 0; i< ThresholdDamageEmitters.Length; i++)
	{
		if( ThresholdDamageEmitters[i].DamageEmitter.AttachPoint != '' && GetAttachPoint(ThresholdDamageEmitters[i].DamageEmitter.Attachpoint, v, r))
		{
			ThresholdDamageEmitters[i].DamageEmitter.SpawnLocation = v;
			ThresholdDamageEmitters[i].DamageEmitter.SpawnRotation = r;
		}
	}
	for(i = 0; i< DestroyEmitters.Length; i++)
	{
		if( DestroyEmitters[i].AttachPoint != '' && GetAttachPoint(DestroyEmitters[i].Attachpoint, v, r))
		{
			DestroyEmitters[i].SpawnLocation = v;
			DestroyEmitters[i].SpawnRotation = r;
		}
	}

	Super.PostNetBeginPlay();

}

function Reset()
{
	Health = MaxHealth;
	AccumulatedDamage=0;
	SetStaticMesh(OriginalMesh);
	SetTimer(0, false);
	SavedInstigator = None;
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local int b, i, dmg;
	local vector p0, p1, hl, v;
	local rotator r;

	if(Health <= 0 || Role < ROLE_Authority) return;

	`log( "RJ: TakeDamage("@Damage@","@DamageType@",splash="@bSplashDamage );

	if ( ValidDamageTypes.Length > 0 )
	{
		for ( i = 0; i < ValidDamageTypes.Length; i++ )
		{
			if ( DamageType == ValidDamageTypes[i] )
			{
				break;
			}
		}
		if ( i == ValidDamageTypes.Length )
		{
			return;
		}
	}

	if ( HitBoxCorners.Length > 1 )
	{
		// get hit location in local space (assume no scaling)
		//
		hl = (HitLocation - Location) << Rotation;

		// check if damage occurred inside specified hit boxes
		//
		for ( b = 1; b < HitBoxCorners.Length; b += 2 )
		{
			p0 = HitBoxCorners[b-1];
			p1 = HitBoxCorners[b];

			`log( "RJ: checking HL="@hl@" against p0="@p0@",p1="@p1 );

			if ( p0.X < p1.X )
			{
				if ( hl.X < p0.X || hl.X > p1.X )
					continue;
			}
			else
			{
				if ( hl.X > p0.X || hl.X < p1.X )
					continue;
			}
			if ( p0.Y < p1.Y )
			{
				if ( hl.Y < p0.Y || hl.Y > p1.Y )
					continue;
			}
			else
			{
				if ( hl.Y > p0.Y || hl.Y < p1.Y )
					continue;
			}
			if ( p0.Z < p1.Z )
			{
				if ( hl.Z < p0.Z || hl.Z > p1.Z )
					continue;
			}
			else
			{
				if ( hl.Z > p0.Z || hl.Z < p1.Z )
					continue;
			}

			// it must be inside box
			break;
		}
		if ( b >= HitBoxCorners.Length )
		{
			// hit location wasn't in any boxes
			//
			return;
		}
	}

	if(!bInvulnerable)
	{
		Health-=Damage;
		AccumulatedDamage+=Damage;
	}

	if(Health <= 0)
	{
		GetBent(EventInstigator,ProjOwner);
	}
	else 
	{
        if(DamageEventThresshold > 0 && AccumulatedDamage > DamageEventThresshold)
        {
		    for(i = 0; i< DamageEmitters.Length; i++)
		    {
			    // attach points were cached
			    v = DamageEmitters[i].SpawnLocation;
			    r = DamageEmitters[i].SpawnRotation;

			    if(DamageEmitters[i].EmitterClass != None)
				    spawn(DamageEmitters[i].EmitterClass,,,Location+(v>>Rotation), Rotation+r);

			    if(DamageEmitters[i].xEmitterClass != None)
				    spawn(DamageEmitters[i].xEmitterClass,,,Location+(v>>Rotation), Rotation+r);

		    }
		    AccumulatedDamage = 0;
		    if ( DamageEvent != '' )
		    {
			    TriggerEvent(DamageEvent, self, EventInstigator);
		    }
        }

        // go through threshold emitters to see if we should spawn any of them
        //
        dmg = MaxHealth - Health;
		for(i = 0; i< ThresholdDamageEmitters.Length; i++)
		{
            if ( !ThresholdDamageEmitters[i].bSpawned && dmg > ThresholdDamageEmitters[i].DamageThreshold )
            {
                `log( "RJ: triggering threshold emitter"@i@"since"@dmg@">"@ThresholdDamageEmitters[i].DamageThreshold );

			    // attach points were cached
			    v = ThresholdDamageEmitters[i].DamageEmitter.SpawnLocation;
			    r = ThresholdDamageEmitters[i].DamageEmitter.SpawnRotation;

			    if(ThresholdDamageEmitters[i].DamageEmitter.EmitterClass != None)
				    spawn(ThresholdDamageEmitters[i].DamageEmitter.EmitterClass,,,Location+(v>>Rotation), Rotation+r);

			    if(ThresholdDamageEmitters[i].DamageEmitter.xEmitterClass != None)
				    spawn(ThresholdDamageEmitters[i].DamageEmitter.xEmitterClass,,,Location+(v>>Rotation), Rotation+r);
        
                ThresholdDamageEmitters[i].bSpawned = true;
            }
		}
	}
}


function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	local int i;
	local Vector v;
	local Rotator r; 


	Health = 0;
    if ( bCauseHurtOnDestruction && ROLE == Role_Authority )
    {
        `log( "RJ: calling HurtRadius("@DestructionHurtDamage@","@DestructionHurtRadius@","@DestructionHurtDamageType@","@DestructionHurtMomentum@")" );
        HurtRadius(DestructionHurtDamage, DestructionHurtRadius, DestructionHurtDamageType, DestructionHurtMomentum, Location, ProjOwner );
    }

	if(DestroySound != None)
	{
		PlaySound(DestroySound);
	}
	if(DestroyEvent != '' && Role == ROLE_Authority)
	{
		if(DestroyEventDelay==0.0)
			TriggerEvent(DestroyEvent, self, instigator);
		else
		{
			SavedInstigator = instigator;
			SetTimer(DestroyEventDelay, false);
		}
	}

	for(i = 0; i< DestroyEmitters.Length; i++)
	{
		// attach points were cached
		//
		v = DestroyEmitters[i].SpawnLocation;
		r = DestroyEmitters[i].SpawnRotation;

		if(DestroyEmitters[i].EmitterClass != None)
			spawn(DestroyEmitters[i].EmitterClass,,,Location+(v>>Rotation), Rotation+r);

		if(DestroyEmitters[i].xEmitterClass != None)
			spawn(DestroyEmitters[i].xEmitterClass,,,Location+(v>>Rotation), Rotation+r);

	}
	
	if(bRemoveMeshOnDestroy && DestroyedMesh == None)
	{
	    Destroy();
	}
	else
	{
		if ( DrawType != DT_StaticMesh )
		{
			SetDrawType( DT_StaticMesh );
		}
		SetStaticMesh(DestroyedMesh);

		// make sure we use the skins from the new mesh
		Skins.Length = 0;
		if(Role == ROLE_Authority)
			bGetBent = true;
	}
}

function Timer()
{
	TriggerEvent(DestroyEvent, self, SavedInstigator);
}


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hReset:
		Reset();

		break;
	case hDestroy:
		GetBent(instigator);
		break;
	}

}

// this will only be called if this actor's physics is PHYS_Havok and the impact is greater than it's HParam's ImpactThresold 
//
simulated event HImpact(actor other, vector pos, vector ImpactVel, vector ImpactNorm, Material HitMaterial)
{
	local float Vol;

    if ( ImpactSound != None )
    {
	    Vol = VSize(ImpactVel);
        if ( ImpactSoundVolScale > 0 )
        {
            Vol /= ImpactSoundVolScale;
        }
	    PlaySound(ImpactSound,,Vol);
    }
}

defaultproperties
{
     MaxHealth=200
     DestructionHurtDamage=200.000000
     DestructionHurtRadius=512.000000
     DestructionHurtMomentum=500.000000
     DrawScale3DX=1.000000
     DrawScale3DY=1.000000
     DrawScale3DZ=1.000000
     hReset="Reset"
     hDestroy="Destroy"
     DestructionHurtDamageType=Class'Engine.DamageType'
     bCanCrushPawns=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     StaticMesh=StaticMesh'DavidPrefabs.Blocks.Cylinder'
     DrawType=DT_StaticMesh
     bWorldGeometry=True
     bAcceptsProjectors=False
     bHasHandlers=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bBlockKarma=True
     bNetNotify=True
     bEdShouldSnap=True
}
