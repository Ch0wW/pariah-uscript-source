//-----------------------------------------------------------
// TitansFistRechargeStation
// Prof. Jesse LaChapelle Esquire
//
// NOTE: works on very specific shaders ONLY! The shader must
// have a constantcolour in the selfillumination channel.
//-----------------------------------------------------------
class TitansFistRechargeStation extends Actor placeable;

//The original emitter, to indicate when the player is charging
var() class<Emitter> ChargeEmitterClass;
var Emitter ChargeEmitter;
var() vector EmitterOffset;
//another emitter to indicate the machine is on
var class<emitter> ShroudOnClass;
var Emitter ShroudOnEmitter;

var class<emitter> ShroudOffEmitter;

//LD vars
var() float ChargeRadius;		// how close we need to be to the station to be charging
var() float RechargeFreq;		// frequences of recharging
var() int ChargeHealth;
var() int ChargeAmmo;
var() int ChargeRemaining;
var() float RemoveEffectsDelay;
var() Actor KillAfterFullDrain[10];
var() name AffectedActorTag;

var int InitialCharge;                    // the power the station had originally
var StaticMeshActor TheAffectedActor[30]; // the array of found actors to affect
var int NumDevices;                       // number of found affected actors
var Material SwapMat;                     // the material to set when the machine is off
var sound ChargeSound;                    // sound to play when the player is charging
var SPPlayerPawn ThePlayer;
var int ReChargeCount;
var bool bSchedDelete;

var array<Material>		NewMaterials;


const REMOVE_EFFECTS = 12;
const UPDATE_TIMER   = 13;

/*****************************************************************
 * InitFade
 *****************************************************************
 */
function InitFade() {
    //find the actor
	local StaticMeshActor Act;

	NumDevices=0;

    foreach AllActors(class'StaticMeshActor', Act, AffectedActorTag)
	{
		if ( Act!=None )
		{
			TheAffectedActor[NumDevices] = Act;

			// if the skins array isn't zero, assume we are running content cutdown
			// build which moves the materials from the static mesh into the actor's
			// skins array so we don't need/want to copy materials to skins (rj)
			//
			if ( Act.Skins.Length == 0 )
			{
				TheAffectedActor[NumDevices].CopyMaterialsToSkins();
			}
			NumDevices++;
			Log("Found Device "$NumDevices);
		}
		if (NumDevices>=30) break;
    }
}


/*****************************************************************
 * PostBeginPlay
 * Start up the timer that will constantly check for the nearby
 * player
 *****************************************************************
 */
function PostBeginPlay(){

    local Material tempMat, newMat;
	local float RRand;
	local int i;

    bHidden = true;
	RRand = FRand()*0.2 + rechargeFreq;
    SetMultiTimer(UPDATE_TIMER, RRand, true);
    InitFade();
	ChargeRemaining = 15;
    InitialCharge = ChargeRemaining;

	for(i = 0; i< NumDevices ; i++) {

        tempMat = TheAffectedActor[i].Skins[0];

        //make a copy
		newMat = Shader(Level.AllocateObject(Class'Shader'));
		NewMaterials[NewMaterials.Length + 1] = newMat;
        TheAffectedActor[i].Skins[0] = newMat;
		newMat = FadeColor(Level.AllocateObject(Class'FadeColor'));
		NewMaterials[NewMaterials.Length + 1] = newMat;
        Shader(TheAffectedActor[i].Skins[0]).SelfIllumination = newMat;
        Shader(TheAffectedActor[i].Skins[0]).Diffuse = shader(tempMat).Diffuse;
        Shader(TheAffectedActor[i].Skins[0]).SelfIlluminationMask = shader(tempMat).SelfIlluminationMask;

        FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).FadePeriod = 0.25;
        FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).FadePhase = Frand()*0.5;
        FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).Color2.B = 255;
        FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).Color2.R = 100;
        FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).Color2.G = 255;
    }

    ShroudOnEmitter = Spawn(ShroudOnClass,,,Location,Rotation);
}


/*****************************************************************
 * Update
 * Set to contantly check for the player pawn.
 * When it is found, it is given some energy, the details of which
 * are then handled by the pawn
 *****************************************************************
 */
simulated function Update(){

    local SPPlayerPawn tempPawn;
    local float PercentRemaining;
    local Weapon titWeapon;
	local int i;
    local bool bCharging;

	ReChargeCount++;
	if (ReChargeCount>30 && ChargeRemaining<15)
	{
		ReChargeCount=0;
		ChargeRemaining++;
        PercentRemaining = float(ChargeRemaining) / float(InitialCharge);
		UpdateDevices(PercentRemaining);
	}

    if (ChargeRemaining > 0)
    {
        foreach RadiusActors(class'SPPlayerPawn', tempPawn, ChargeRadius)
		{
			if (Abs(tempPawn.Location.Z - Location.Z) <=200 )
			{
				titWeapon = Weapon(tempPawn.FindInventoryType(class'PlayerTitansFist'));
				if (titWeapon != none && titWeapon.Ammo[0] !=None)
				{
   				   	if (titWeapon.Ammo[0].AddAmmo(ChargeAmmo))
                    {
                        bCharging = true;
                    }
				}

                if(tempPawn.Health < tempPawn.HealthMax)
                {
                    tempPawn.GiveHealth(ChargeHealth, tempPawn.HealthMax);
                    bCharging = true;
                }
            }
        }

        if(bCharging)
        {
            ChargeRemaining -= 1;
            PercentRemaining = float(ChargeRemaining) / float(InitialCharge);
		    UpdateDevices(PercentRemaining);
        }

        if(ChargeRemaining <= 0)
        {
			for(i=0 ; i<10 ;i++)
			{
				if (KillAfterFullDrain[i]!=None) KillAfterFullDrain[i].Destroy();
			}
        }
    }

    //add or delete effects appropriately
    if (bCharging == true){
        SetMultiTimer(REMOVE_EFFECTS, 0, false);  //turn off timer if you want to restart the effects
        bSchedDelete = false;
        AmbientSound = ChargeSound;
        if (ChargeEmitterClass != none && ChargeEmitter == None){
            ChargeEmitter = Spawn(ChargeEmitterClass,,,Location + EmitterOffset);
        }
    }  else {
        AmbientSound = none;
        //if the station still has some power than remove the effects after a second
        //or two, otherwise delete them immediately so the player knows its over
        if (!bSchedDelete && chargeRemaining > 0){
            SetMultiTimer(REMOVE_EFFECTS, RemoveEffectsDelay, false);
            bSchedDelete = true;
        } else if (chargeRemaining == 0){
            DeleteEffects();
        }
    }
}

/*****************************************************************
 * DeleteEffects
 * As the name suggests it removes the effects from the station
 *****************************************************************
 */
function DeleteEffects(){
    bSchedDelete = false;
    if (ChargeEmitter != none){
        ChargeEmitter.Destroy();
        Spawn(ShroudOffEmitter);
    }

}


/*****************************************************************
 * MultiTimer
 *****************************************************************
 */
function MultiTimer(int ID){
    switch(ID){
        case UPDATE_TIMER:
            Update();
            break;
        case REMOVE_EFFECTS:
            DeleteEffects();
            break;
        default:
            super.MultiTimer(ID);
    }
}

function UpdateDevices(float PercentRemaining)
{
	local int i;

	for(i = 0; i< NumDevices ; i++)
	{
		if (TheAffectedActor[i]!=None &&
			Shader(TheAffectedActor[i].Skins[0])!=None &&
			FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination) != None)
		{
			FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).Color2.G = 255 * PercentRemaining;
			FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).Color2.B = 255 * PercentRemaining;
			FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).Color2.R = 100 * PercentRemaining;
			FadeColor(Shader(TheAffectedActor[i].Skins[0]).SelfIllumination).FadePeriod = PercentRemaining * 0.25;
		}

		//you have just run out of energy
		if (ChargeRemaining == 0){
       		TheAffectedActor[i].SetSkin(1,SwapMat);
       		if (ShroudOnEmitter != none){
    		  ShroudOnEmitter.Destroy();
       		}
		}
	}
}


simulated function Destroyed()
{
	local int i;

	for(i = 0; i < NewMaterials.Length; ++i)
	{
		Level.FreeObject(NewMaterials[i]);
	}
}

//-----------------------------------------------------------
// defaultproperties
//-----------------------------------------------------------

defaultproperties
{
     ChargeHealth=2
     ChargeAmmo=5
     ChargeRemaining=15
     chargeRadius=400.000000
     rechargeFreq=0.500000
     RemoveEffectsDelay=1.500000
     SwapMat=Shader'CS_ShroudTextures.controlpanel.cpstaticOFFshader'
     ChargeSound=Sound'DC_MiscAmbience.Emitters.MasonRechargeLoop'
     ChargeEmitterClass=Class'VehicleEffects.ShroudEnergyDrain'
     ShroudOnClass=Class'VehicleEffects.ShroudDeviceOn'
     ShroudOffEmitter=Class'VehicleEffects.ShroudEnergyDrainOff'
     bSchedDelete=True
     CollisionRadius=400.000000
     CollisionHeight=50.000000
     bCollideActors=True
     bProjTarget=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bUseCylinderCollision=True
     bDirectional=True
}
