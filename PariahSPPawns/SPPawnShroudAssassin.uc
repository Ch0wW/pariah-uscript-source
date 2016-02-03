class SPPawnShroudAssassin extends SPPawnShroud;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx
#exec OBJ LOAD FILE=..\Textures\DavidTextures.utx

// these materials are used for controlling the distortion effect
var Material			Distortion;
var ConstantColor		NoDistortion;
var Combiner			ControllableDistortion;

// these materials are used for controlling the skin fading
//
var array<Material>		SavedOpacity;
var array<Shader>		NewShaders;

var bool				bCloaking;
var bool				bCloakingActive;
var float				TransitionTimeLeft;


var sound CloakOnSound;
var sound CloakOffSound;
var sound CloakImpactSound;
var sound ShockwaveSound;
var sound ChargeUpSound;

//Stuff for the assassin to do the charge up attack
var class<Emitter>  HelperChargeEmitterClass;
var class<Emitter>  ChargeEmitterClass;
var class<Emitter>  ShockWaveEmitter;
var Emitter         ChargeEmitter;
var private bool    bChargingPawn;

const TransitionTime = 2.0;

var SinglePlayer.AssassinCloakMode			CloakingMode;

var bool bNearInvinsible;

// blades
//
const LeftBlade = 0;
const LeftBladeEmitter = 1;
const RightBlade = 2;
const RightBladeEmitter = 3;

var StaticMesh		BladeMesh;
var class<Actor>	BladeEmitter;
var Actor			BladeActors[4];

event PostBeginPlay()
{
	local int			s;
	local Shader		shader;

	// create a constant color that results in no distortion
	// - the alpha channel of this color is used to control the
	//   blending between this color and the Distortion material
	//   as well as the fading of the regular skins
	//
	NoDistortion = ConstantColor(Level.AllocateObject(class'ConstantColor'));
	NoDistortion.Color.R = 128;
	NoDistortion.Color.G = 128;
	NoDistortion.Color.B = 255;
	NoDistortion.Color.A = 255;	// 255 will be no distortion, 0 will be full distortion

	// create the combiner that combines the distortion material with the constant color
	// NoDistortion material
	//
	ControllableDistortion = Combiner(Level.AllocateObject(class'Combiner'));
	ControllableDistortion.Material1 = Distortion;
	ControllableDistortion.Material2 = NoDistortion;
	ControllableDistortion.Mask = NoDistortion;
	ControllableDistortion.CombineOperation = CO_AlphaBlend_With_Mask;
	ControllableDistortion.AlphaOperation = AO_Use_Alpha_From_Material1;

	if ( Skins.Length == 0 )
	{
		CopyMaterialsToSkins();
	}

	// create the skins that are used to fade out the pawn's normal skins
	//
	for ( s = 0; s < Skins.Length; s++ )
	{
		// - if the corresponding skin is a shader, we need to make a copy of it and
		//   we can then adjust the opacity channel when we need to fade
		// - if it isn't a shader create one and use the existing material as diffuse channel
		//   and we can then adjust the opacity channel when we need to fade
		//
		if ( Skins[s].IsA('Shader') )
		{
			shader = Shader(Level.AllocateObject(Class'Shader'));
			shader.Set( Shader(Skins[s]) );
		}
		else
		{
			shader = Shader(Level.AllocateObject(Class'Shader'));
			shader.Diffuse = Skins[s];
		}
		NewShaders[NewShaders.Length + 1] = shader;
		SetSkin( s, shader );
	}

	TransitionTimeLeft = TransitionTime;

	AddBlades();

	CloakControl( SinglePlayer(Level.Game).AssassinCloakingMode );
}

simulated function Destroyed()
{
	local int i;

	Level.FreeObject(NoDistortion);
	Level.FreeObject(ControllableDistortion);
	for(i = 0; i < NewShaders.Length; ++i)
	{
		Level.FreeObject(NewShaders[i]);
	}
	RemoveBlades();
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying( DamageType, HitLoc );
	RemoveBlades();
}

function CloakControl( SinglePlayer.AssassinCloakMode mode )
{
	CloakingMode = mode;

	switch ( CloakingMode )
	{
	case ACM_CloakingAI:
		// leave it in whatever state it currently is
		break;
	case ACM_CloakingOff:
		RealDeCloak();
		break;
	case ACM_CloakingOn:
		RealCloak();
		break;
	}
}

event Tick( float dt )
{
	local float		f;
	local int		s;

	Super.Tick( dt );

	if ( bCloakingActive )
	{
		if ( bCloaking )
		{
			if ( TransitionTimeLeft > 0 )
			{
				TransitionTimeLeft = FClamp( TransitionTimeLeft - dt, 0, TransitionTime );
			}
		}
		else
		{
			if ( TransitionTimeLeft < TransitionTime )
			{
				TransitionTimeLeft = FClamp( TransitionTimeLeft + dt, 0, TransitionTime );
			}
			// if we have fully uncloaked, turn off postfx and return skins to normal
			//
			if ( TransitionTimeLeft >= TransitionTime )
			{
				`log( "RJ: Fully uncloaked, turn off postfx" );
				bHasPostFXSkins = false;
				bForceSWSkinning = false;
				bCloakingActive = false;
				SetSkin( 0, Skins[0] );		// nop to make sure cached render data is cleared

				for ( s = 0; s < Skins.Length; s++ )
				{
					Shader(Skins[s]).Opacity = SavedOpacity[s];
				}

				AddBlades();
			}
		}
		f = TransitionTime;
		f = TransitionTimeLeft / f;
		NoDistortion.Color.A = 255 * f;
	}
}

function Cloak()
{
	if ( CloakingMode == ACM_CloakingAI )
	{
    	if (!bCloakingActive){
        	PlaySound(CloakOnSound,,1,,2500);
    	}
		RealCloak();
	}
}

private function RealCloak()
{
	local int		s;

	if ( !bCloaking )
	{
		`log( "RJ: initiating cloaking, turn on postfx" );

		// set things up to transition to the cloak effect
		//
		bHasPostFXSkins = true;
		bForceSWSkinning = true;
		bCloakingActive = true;
		bCloaking = true;
		SetSkin( 0, Skins[0] );		// nop to make sure cached render data is cleared

		SavedOpacity. Length = Skins.Length;
		for ( s = 0; s < Skins.Length; s++ )
		{
			SavedOpacity[s] = Shader(Skins[s]).Opacity;
			Shader(Skins[s]).Opacity = NoDistortion;
		}

		RemoveBlades();
	}
}

function DeCloak()
{
	if ( CloakingMode == ACM_CloakingAI )
	{
       	if (bCloakingActive){
//        	PlaySound(CloakOffSound);
        	PlaySound(CloakOffSound,,1,,2500);
    	}
		RealDeCloak();
	}
}

private function RealDeCloak()
{
	if ( bCloaking )
	{
		bCloaking = false;
	}
}

event GetPostFXSkins( out array<Material> PostFXSkins )
{
    local int i;

    for( i = 0 ; i < PostFXSkins.Length ; i++ )
    {
		PostFXSkins[i] = ControllableDistortion;
    }
}

function AddBlades()
{
	local int	bl, ba;
	local Name	bone;

	bone = 'BladeL';
	ba = 0;
	for ( bl = 0; bl < 2; bl++ )
	{
		if ( BladeActors[ba] == None )
		{
			BladeActors[ba] = Spawn(class'Effects',self,,Location);
			BladeActors[ba].SetDrawType( DT_StaticMesh );
			BladeActors[ba].SetStaticMesh( BladeMesh );
			if( !AttachToBone(BladeActors[ba],bone) )
			{
				log( "Couldn't attach"@BladeMesh@"to"@bone, 'Error' );
				BladeActors[ba].Destroy();
				BladeActors[ba] = None;
				return;
			}
		}
		ba++;
		if ( BladeActors[ba] == None )
		{
			BladeActors[ba] = Spawn(BladeEmitter,self,,Location);
			if( !AttachToBone(BladeActors[ba],bone) )
			{
				log( "Couldn't attach"@BladeEmitter@"to"@bone, 'Error' );
				BladeActors[ba].Destroy();
				BladeActors[ba] = None;
				return;
			}
		}
		ba++;

		bone = 'bladeR';
	}
}

function RemoveBlades()
{
	local int ba;

	for ( ba = 0; ba < 4; ba++ )
	{
		if ( BladeActors[ba] != None )
		{
			DetachFromBone( BladeActors[ba] );
			BladeActors[ba].Destroy();
			BladeActors[ba] = None;
		}
	}
}

/*****************************************************************
 * TakeDamage
 * Overridden to provide some invinsibility functionality while cloaked
 * and to ensure that titan's fist adds momentum to the pawn
 *****************************************************************
 */
function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
                        Vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
    local vector realMomentum;
    local int realDamage;

    realDamage = Damage;
    if (bCloakingActive == true || bNearInvinsible == true){
        //If the damage is from Titans fist then you take damage
        //so that notifications make it to the AI
        if ( DamageType == class'TitansFistDamage'){
            //consider the original momentum, but ensure that it is not zero
            realMomentum = (Momentum + vect(10,10,10)) * 100;
            realDamage = 1;
        } else {
            realDamage = 0;
        }
        if (!InstigatedBy.Controller.SameTeamAs(self.Controller)){
            PlaySound(CloakImpactSound);
        }
    }

    super.TakeDamage(realDamage, InstigatedBy, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
}


function SetInvinsible(bool OnOff){
    bNearInvinsible = OnOff;
}

/*****************************************************************
 * SpawnChargeUpBeam
 * Create effects that show you are charing up
 *****************************************************************
 */
function SpawnChargeUpBeam(){
    if (ChargeEmitter == None){
       ChargeEmitter = Spawn(ChargeEmitterClass);
       ChargeEmitter.SetBase(self);
       ChargeEmitter.SetRelativeLocation(vect(0,0,50));
    }
}


/*****************************************************************
 * SpawnHelperBeam
 * Shoot a beam at your boss
 *****************************************************************
 */
function SpawnHelperBeam(){
    if (ChargeEmitter == None){
       ChargeEmitter = Spawn(HelperChargeEmitterClass);
       ChargeEmitter.SetBase(self);
       AmbientSound = ChargeUpSound;
       ChargeEmitter.SetRelativeLocation(vect(48,-11,35));
    }
}


/*****************************************************************
 * EndChargeUpBeam
 * The attack in over, do something else
 *****************************************************************
 */
function EndChargeUpBeam(){
    if (ChargeEmitter!= none){
        ChargeEmitter.Destroy();
        AmbientSound = none;
    }
}

/*****************************************************************
 * SpawnBeamEffect
 *****************************************************************
 */
function SpawnExplosion(int Size)
{
	//local float VirusRadius;
//	local VirusPowerEffect chargeEffect;
  /*
	if(Role == ROLE_Authority) {
		chargeEffect = Spawn(class'VirusPowerEffect');
		if(chargeEffect != none) {
			chargeEffect.fMaxChargeTime = float(2);
			chargeEffect.Charge();
			chargeEffect.SetLocation(Instigator.Location);
			chargeEffect.chargeScale = float(10); //float(150);
			chargeEffect.bSelfDestruct = true;
		}
	}
	*/
	Spawn(ShockWaveEmitter);
    PlaySound(ShockwaveSound,,1,,2500);
	HurtRadius(float(75), float(3000) ,class'VehicleWeapons.VirusPowerDamage', 10000, Location);

}

/*****************************************************************
 * Died
 *****************************************************************
 */
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation){
    super.Died(Killer, damageType, HitLocation);
    EndChargeupBeam();
    bChargingPawn = false;
}

defaultproperties
{
     Distortion=TexPanner'RonsTextures.Distort.AssDistortPanner'
     CloakOnSound=Sound'BossFightSounds.Assassin.AssassinCloakOn'
     CloakOffSound=Sound'BossFightSounds.Assassin.AssassinCloakOff'
     CloakImpactSound=Sound'BossFightSounds.Assassin.AssassinShieldImpact'
     ShockwaveSound=ProceduralSound'BossFightSounds.Assassin.AssassinShockwave'
     ChargeUpSound=Sound'BossFightSounds.Assassin.AssassinChargeUp'
     BladeMesh=StaticMesh'PariahCharacterMeshes.Shroud.blade2'
     HelperChargeEmitterClass=Class'VehicleEffects.AssassinLightning'
     ChargeEmitterClass=Class'VehicleEffects.AssassinDraw'
     ShockWaveEmitter=Class'VehicleEffects.AssassinShockwave'
     BladeEmitter=Class'VehicleEffects.shroudblade_fire'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAssassin'
     ExclamationClass=Class'PariahSPPawns.SPAssassinExclaim'
     disposition=D_Cautious
     bMayMelee=False
     bMayFallDown=False
     CharIdleAnim="F_Assasin_Ready"
     SoundGroupClass=Class'VehicleGame.PariahSoundGroupAssassin'
     Health=75
     GroundSpeed=700.000000
     IdleWeaponAnim="F_Assasin_Ready"
     ControllerClass=Class'PariahSPPawns.SPAIAssassin'
     race=R_Shroud
     TransientSoundVolume=1.000000
     TransientSoundRadius=128.000000
     Mesh=SkeletalMesh'PariahFemaleAnimations_SP.ShroudAssasin_Female'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem137
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem137'
     Skins(0)=Shader'PariahCharacterTextures.ShroudAssasin.assasom_body_shader'
     Skins(1)=Texture'PariahCharacterTextures.ShroudAssasin.shroudassasin_head'
     SoundVolume=128
     bNeedSWSkinning=True
}
