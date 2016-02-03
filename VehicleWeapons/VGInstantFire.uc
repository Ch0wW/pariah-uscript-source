class VGInstantFire extends VGWeaponFire;

var class<DamageType> DamageType;
var (Damage) int TracesPerFire;
//XJ no range but specific damage is necessary
//var int DamageMin, DamageMax;
//moved to VGWeaponFire;
//var int	VehicleDamage, PersonDamage;
var class<VGHitEffectBase> HitEffectClass;
var (Damage) float TraceRange;
var (Damage) float Momentum;
var float HitEffectProb;
var class<Actor> TracerClass;
var	()	float		TracerFreq;

//--------Frag rifle only---------
const RAD1 = 0.25;	//radius of the center area in % of spread
const RAD2 = 0.35;	//radius of the ring area in % of spread
const INRAD1 = 0.65;	//number of projectiles in center area in %
const INRAD2 = 0.25;	//number of projectiles in center area in %
//--------------------------------

function float MaxRange()
{
	return 9000;
}

function DoFireEffect()
{
    local Vector StartTrace, Delta;
    local Rotator R, Aim;
    local int t, i, k;
    local int TraceCount;
	local vector X, Y, Z;
	local int nRad1, nRad2; //Frag rifle spread area delimiters (xmatt)

	// Instigator.MakeNoise(1.0);
	MakeFireNoise();

    // the to-hit trace always starts right in front of the eye
	if (Weapon.ThirdPersonActor != none)
	{
	   R = Weapon.ThirdPersonActor.Rotation;
	}
	if(Weapon.bIndependantPitch) 
	{
		R.Pitch += Weapon.RealPitch;
	}
	GetAxes( R, X, Y, Z );
	StartTrace = Weapon.GetFireStart( X, Y, Z );
	
    Aim = AdjustAim(StartTrace, AimError);

    TraceCount = TracesPerFire;

	switch (SpreadStyle)
	{
	case SS_RadBased:
		i = 0;
		k = int( 4 * FRand() ) % 4 ; //randomize which quadran gets filled in first
		nRad1 = int(INRAD1 * TraceCount);
		//log( "nRad1=" $ nRad1 );
		nRad2 = int(INRAD2 * TraceCount);
		//log( "nRad2=" $ nRad2 );
		//log( "spread=" $ Spread );
		for (t = 0; t < TraceCount; t++)
		{
			//log( "--------------" );
			R = Aim;
			//[-1.0, 1.0]
			Delta.X = 0;
			Delta.Y = FRand();
			Delta.Z = FRand();
			if( i < nRad1 )
			{
				//[-50%*spread, 50%*spread] about center
				Delta.Y *= RAD1*Spread;
				Delta.Z *= RAD1*Spread;
				//place point in the next quadran
				switch (k)
				{
				case 1:
					Delta.Y *= -1;
					break;
				case 2:
					Delta.Y *= -1;
					Delta.Z *= -1;
					break;
				case 3:
					Delta.Z *= -1;
					break;
				}
				//log( "d=" $ Delta $ "(1)" );
			}
			else if( i < nRad1 + nRad2 )
			{
				//[-RAD2%*spread, RAD2%*spread]
				Delta.Y = Delta.Y * RAD2 * Spread;
				Delta.Z = Delta.Z * RAD2 * Spread;

				//translate just out of the center circle
				Delta.Y += RAD1*Spread;
				Delta.Z += RAD1*Spread;

				//place point in the next quadran
				switch (k)
				{
				case 1:
					Delta.Y *= -1;
					break;
				case 2:
					Delta.Y *= -1;
					Delta.Z *= -1;
					break;
				case 3:
					Delta.Z *= -1;
					break;
				}
				//log( "d=" $ Delta $ "(2)");
			}
			else
			{
				//Put in left over of the spread
				Delta.Y = Delta.Y * (1.0-RAD1-RAD2) * Spread;
				Delta.Z = Delta.Z * (1.0-RAD1-RAD2) * Spread;

				//Translate just out of the ring
				Delta.Y += (RAD1+RAD2)*Spread;
				Delta.Z += (RAD1+RAD2)*Spread;

				//Place point in the next quadran
				switch (k)
				{
				case 1:
					Delta.Y *= -1;
					break;
				case 2:
					Delta.Y *= -1;
					Delta.Z *= -1;
					break;
				case 3:
					Delta.Z *= -1;
					break;
				}
				//log( "d=" $ Delta $ "(3)" );
			}
			//log( "Aim= " $ vector(R) );
			//Scale by spread (Spread here is vectorial spread)
			//Transform the delta by the aim direction
			Delta = Delta >> Aim;

			//Then add the delta rotation to the aim rotation
			R = rotator(vector(R) + Delta);
			//log( "Delta= " $ rotator(Delta) );
			i++;
			k++;
			k = k % 4;
			DoTrace(StartTrace, R);
		}

		break;

		//For the frag rifle, the projectiles should show a normal distribution about
		//a mean of zero. (xmatt)
	case SS_Bell:
		for (t = 0; t < TraceCount; t++)
		{
			R = Aim;
			//Use a degree 3 polynome (asymmetric)
			Delta.X = 2.f * (FRand()-0.5);
			Delta.Y = 2.f * (FRand()-0.5);
			Delta.Z = 2.f * (FRand()-0.5);
			Delta.X *= Delta.X * Delta.X * Delta.X * Delta.X;
			Delta.Y *= Delta.Y * Delta.Y * Delta.Y * Delta.Y;
			Delta.Z *= Delta.Z * Delta.Z * Delta.Z * Delta.Z;

			//Uniform spread in both axis
			Delta *= Spread;

			//Scale by spread (Spread here is vectorial spread)
			R = rotator(vector(R) + Delta);
			DoTrace(StartTrace, R);
		}

		break;

	case SS_Random:
		for (t = 0; t < TraceCount; t++)
		{
			R = Aim;
			R = rotator(vector(R) + VRand()*FRand()*Spread);
			DoTrace(StartTrace, R);
		}

		break;

	case SS_Line:
		for (t = 0; t < TraceCount; t++)
		{
			R = Aim;
			R.Yaw += Spread*(t - float(TraceCount-1)/2.0);
			DoTrace(StartTrace, R);
		}

		break;
	}
	Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    //local int Damage;
    local bool bDoReflect;
    local int ReflectNum;
	local Material HitMat;

    if(Weapon.Role < ROLE_Authority)
    {
        return;
    }

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective /*&& Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25)*/)
            {
                bDoReflect = true;
                HitNormal = Vect(0,0,0);
            }
            else
            {
                if(Other.bProjTarget || !Other.bWorldGeometry)
                {
					if(Other.IsA('VGVehicle'))
						Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
					else
						Other.TakeDamage(PersonDamage, Instigator, HitLocation, Momentum*X, DamageType);

        	    	if(Other.IsA('StaticMeshActor') && HitEffectClass != None && HitEffectProb >= FRand())
		    			HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
                    //Damage = (DamageMin + Rand(DamageMax - DamageMin));
                    //Damage = Ceil(Damage * DamageAtten);
                    //log("Damage="$Damage);
                    //Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);

                    HitNormal = Vect(0,0,0);
                }
                else
                {
					//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
                    if (HitEffectClass != None && HitEffectProb >= FRand() )
                    {
                        HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);
                    }
                }
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);
		if(TracerFreq > FRand())
		{
			FireTracer(Start, Dir, HitLocation, HitNormal, ReflectNum);
		}

        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
}

function FireTracer(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	spawn(TracerClass,Owner,,Start, Dir);
}


simulated state Reload
{
	simulated function bool AllowFire()
	{
	    return false;
	}
	
	event ModeDoFire()
	{
		local AIController AIC;
		AIC = AIController(Instigator.Controller);
        if ( AIC != None )
		{
			AIC.StopFiring();
		}
	}
}

defaultproperties
{
     TracesPerFire=1
     TraceRange=15000.000000
     Momentum=1.000000
     HitEffectProb=1.000000
     TracerFreq=1.000000
     aimerror=200.000000
     AutoAim=0.950000
}
