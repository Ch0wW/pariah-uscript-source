class SPOpponentFactory extends OpponentFactory;

var() class<VGVehicle>		VehicleClass;
var() class<VehicleWeapon>	Weapons[3];
var() Name					VehicleTag;
var Array<VGVehicle>		FactoryVehicles;

function postPossessConfigure( Controller C ) {
	if( VehicleClass != None) {
		SpawnVehicleFor( C );
	}
}

function SpawnVehicleFor(Controller C)
{
	local VGVehicle Vehicle;
	//local int i,count;
	
    VGPawn(C.Pawn).bNoEncroachHack = true;
	Vehicle = spawn(VehicleClass,self,,Location,Rotation);
    VGPawn(C.Pawn).bNoEncroachHack = false;

	if(Vehicle==None) {
		log("SPOpponentFactory "$self$" Failed to Spawn Vehicle");
		return;
	}
    if(VehicleTag != '')
        Vehicle.Tag = VehicleTag;

	//for(i=0;i<3;i++)
	//{
	//	if(Weapons[i]!=None)
	//	{
	//		Vehicle.GiveWeaponByClass(Weapons[i]);
	//		count++;
	//	}
	//}

	//if(count==0)
	//{
	//	Vehicle.GiveWeapon("VehicleWeapons.Puncher");
	//}

	Vehicle.CheckCurrentWeapon();
	///////
	//Vehicle.TryToDrive( driver );

	Vehicle.Driver = VGPawn(C.Pawn);
    C.Possess( Vehicle );
	Vehicle.BeginControlOfVehicle(C);
	Vehicle.Weapon.BringUp();
	Vehicle.Driver.Unpossessed();
	Vehicle.Driver.SetDrivenVehicle(Vehicle);
	
	FactoryVehicles.Length = FactoryVehicles.Length + 1;
	FactoryVehicles[FactoryVehicles.Length - 1] = Vehicle;
}

function DestroyAllOpponents()
{
	local int i;
	
	// we are destroying the vehicles explicitly here in case it has flipped and the controller is no longer
	// driving it --- we still want to destroy it in this case.
	
	for(i = 0; i < FactoryVehicles.Length; ++i)
	{
		if(FactoryVehicles[i] != None)
		{
			if(FactoryVehicles[i].Driver == None || !FactoryVehicles[i].Driver.IsA('SPPlayerPawn'))
			{
				FactoryVehicles[i].TakeDamage(1500, FactoryVehicles[i], FactoryVehicles[i].Location, Vect(0,0,0), class'Crushed'); 
			}
		}
	}
	FactoryVehicles.Length = 0;
	
	Super.DestroyAllOpponents();
}

defaultproperties
{
}
