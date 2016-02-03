class VGHavokWaspMP extends VGHavokRaycastVehicle
	placeable;

//ini load out info
//var config	string	BigWeapon1;
var config	string	SmallWeapon1;
//var config	string	SmallWeapon2;

simulated function InitializeVehicle()
{
	Super.InitializeVehicle();
	GiveWeapon(SmallWeapon1);
}

simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.CaboomDistort',,,Location);
	spawn(class'VehicleEffects.CaboomExplosion',,,Location);
	spawn(class'VehicleEffects.DavidVehicleExplosionTiresWasp',,,Location);

}

defaultproperties
{
     TiretrackParameterScale=50.000000
     MaxSpeedFullSteeringAngle=4000.000000
     OptRPM=4000.000000
     MaxRPM=8000.000000
     MaxTorque=1000.000000
     TorqueFactorAtMinRPM=1.500000
     TorqueFactorAtMaxRPM=0.900000
     ResistanceFactorAtMinRPM=0.100000
     ResistanceFactorAtOptRPM=0.250000
     ResistanceFactorAtMaxRPM=0.750000
     ClutchSlipRPM=500.000000
     DownshiftRPM=800.000000
     UpshiftRPM=2600.000000
     PrimaryTransmissionRatio=8.000000
     ReverseGearRatio=1.400000
     MinTimeToLockWheels=0.100000
     FrontalArea=10000.000000
     DragCoefficient=0.300000
     LiftCoefficient=-0.200000
     InAirSpinDampingTime=5.100000
     InAirNormalSpinDamping=12.000000
     InAirCollisionSpinDamping=16.000000
     NormalSpinDamping=4.000000
     CollisionSpinDamping=8.000000
     MinSpeedForExtraLinearDamping=3000.000000
     ExtraLinearDampingRate=0.010000
     TorquePitchFactor=0.600000
     TorqueYawFactor=0.600000
     ExtraSteerTorqueFactor=0.000000
     HitImpulseScale=5.000000
     HitImpulseRadialScale=0.850000
     MaxHitImpulse=270000.000000
     HitImpulseSpinScale=0.050000
     HitImpulseLinearDamping=0.100000
     FlipDropHeight=250.000000
     Wheels(0)=(Radius=44.000000,Width=42.000000,Mass=9.000000,Friction=0.900000,ViscosityFriction=0.050000,MaxBrakingTorque=8000.000000,HardpointCS=(X=104.424004,Y=-95.000000,Z=-25.000000),DirectionCS=(Z=-1.000000),Length=15.000000,Strength=55.000000,DampingCompression=1.300000,DampingRelaxation=1.300000,TorqueRatio=0.300000,SuspensionIndex=1,Mesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspTire')
     Wheels(1)=(Radius=44.000000,Width=42.000000,Mass=9.000000,Friction=0.900000,ViscosityFriction=0.050000,MaxBrakingTorque=8000.000000,HardpointCS=(X=104.424004,Y=95.000000,Z=-25.000000),DirectionCS=(Z=-1.000000),Length=15.000000,Strength=55.000000,DampingCompression=1.300000,DampingRelaxation=1.300000,TorqueRatio=0.300000,FlipMeshInY=True,NegateSuspOffsetY=True,SuspensionIndex=2,Mesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspTire')
     Wheels(2)=(Axle=1,Radius=46.000000,Width=60.000000,Mass=11.000000,Friction=0.550000,ViscosityFriction=0.050000,MaxBrakingTorque=6000.000000,HardpointCS=(X=-120.525002,Z=-25.000000),DirectionCS=(Z=-1.000000),Length=15.000000,Strength=55.000000,DampingCompression=1.900000,DampingRelaxation=1.900000,TorqueRatio=0.400000,SteeringLocked=True,UsedByHandbrake=True,Mesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspTireRear')
     Begin Object Class=TireEffectInfo Name=TireEffectInfo124
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=15.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirt'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo124'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo125
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtB'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo125'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo126
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         SurfaceTypes(1)=EST_Wet
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireWater'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo126'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo127
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDust'
     End Object
     TireEffects(3)=TireEffectInfo'VehicleVehicles.TireEffectInfo127'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo128
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Metal
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtC'
     End Object
     TireEffects(4)=TireEffectInfo'VehicleVehicles.TireEffectInfo128'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo129
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Metal
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(5)=TireEffectInfo'VehicleVehicles.TireEffectInfo129'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo130
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=100.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Plant
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(6)=TireEffectInfo'VehicleVehicles.TireEffectInfo130'
     Suspensions(0)=(DecoPieces=((Base=SPL_Wheel,TargetOffset=(X=-37.226002,Z=0.683000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionRear')))
     Suspensions(1)=(DecoPieces=((BaseOffset=(X=104.714996,Y=-24.374001,Z=-32.264999),Target=SPL_Wheel,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionBase01'),(BaseOffset=(X=104.714996,Y=-29.235001,Z=9.626000),Target=SPL_Wheel,TargetOffset=(Y=-26.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionSpring01')))
     Suspensions(2)=(DecoPieces=((BaseOffset=(X=104.714996,Y=-24.374001,Z=-32.264999),Target=SPL_Wheel,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionBase02'),(BaseOffset=(X=104.714996,Y=-29.235001,Z=9.626000),Target=SPL_Wheel,TargetOffset=(Y=-26.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionSpring02')))
     Tiretracks(0)=(Surfaces=(EST_Metal,EST_Rock,EST_Plant,EST_Dirt),MinSkidEnergy=1.000000,MaxSkidEnergy=1000.000000,Material=Texture'PariahVehicleTextures.Shared.TireTreadColour')
     GearRatios(0)=1.400000
     GearRatios(1)=1.000000
     GearRatios(2)=0.600000
     ExtraGravity=(Z=-250.000000)
     ShiftUpSoundVolume=246
     ShiftDownSoundVolume=153
     WeaponMounts=1
     MaxSteerAngle=7000.000000
     ChassisMass=500.000000
     ChassisFriction=1.100000
     TailLightSeparation=32.188999
     HeadLightProjectorDistance=800.000000
     HeadLightReattachDistance=50.000000
     ShadowDrawScale=2.000000
     campitch=-2000.000000
     camdist=600.000000
     camheight=200.000000
     LookAngleForMaxSteer=8192.000000
     HitSoundMinImpactThreshold=100.000000
     HitSoundMaxImpactThreshold=1000.000000
     EngineSoundPitchScale=1500.000000
     ReverseSoundPitchScale=-800.000000
     ReverseSoundMinVelocity=500.000000
     TireSlipSoundMinSlipVel=100.000000
     TireSlipSoundMaxSlipVel=700.000000
     TireImpactSoundMinImpactThreshold=100.000000
     TireImpactSoundMaxImpactThreshold=500.000000
     MinRamSpeed=500.000000
     RammingDamage=50.000000
     RammingDamageMultiplier=2.000000
     RammingTimeout=3.000000
     ExitBrakeTime=0.100000
     ShadowTexture=Texture'PariahVehicleEffectsTextures.GroundShadows.WaspShadow'
     EnterVehicleSound=Sound'NewVehicleSounds.Wasp.WaspEngineStartA'
     ExitVehicleSound=Sound'NewVehicleSounds.Wasp.WaspEngineStopA'
     EngineSound=Sound'NewVehicleSounds.Wasp.WaspEngineIdleA'
     HitSound=Sound'NewVehicleSounds.Dozer.DozerImpactA'
     DeathSound=Sound'NewVehicleSounds.explosions.VehicleExplosionB'
     ReverseSound=Sound'NewVehicleSounds.Wasp.WaspEngineIdleA'
     TireSlipSound=Sound'NewVehicleSounds.TireSpin.TireSpinGravelC'
     TireImpactSound=Sound'PariahVehicleSounds.Vehicle_Bump.22-Bumps_Road'
     DrivingAnim="Wasp_Driver"
     DrivingAnimR="Wasp_SteerR"
     DrivingAnimL="Wasp_SteerL"
     WeaponMountName(0)="WP1"
     DriverPointName="PointDriver"
     DriverEntryAnims(0)="Wasp_Driver_InLeft"
     DriverEntryAnims(1)="Wasp_Driver_InRight"
     DriverExitAnim="Wasp_Driver_OutLeft"
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo139
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspHandlebar'
         AttachPoints(0)="PointHandlebar"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Yaw=-4551))
     End Object
     DamageableParts(5)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo139'
     DriverEntryNames(0)="PointDriverLeft"
     DriverEntryNames(1)="PointDriverRight"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo19
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=100.000000)
         StartVelocityRange=(RangeBase=(X=(Min=200.000000,Max=500.000000),Y=(Min=200.000000,Max=500.000000),Z=(Min=50.000000,Max=200.000000)),RangeScale=(X=(Min=5.000000,Max=1.000000),Y=(Min=5.000000,Max=1.000000),Z=(Min=5.000000,Max=1.000000)))
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(0)=(OnWhenCarEmpty=True,Location=(X=110.000000,Z=30.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo19'))
     PreLoadClasses(0)="VehicleWeapons.Puncher"
     ExitPos(0)=(X=40.000000,Y=-180.000000)
     LightOffset=(X=171.000000,Z=5.000000)
     TailLightOffset=(X=-175.000000,Z=37.000000)
     VehicleName="Wasp"
     VehicleType=VT_Wheeled
     TailLightBrakeSaturation=200
     TailLightBrakeBrightness=150
     TailLightBackupBrightness=0
     TailLightDrivingSaturation=0
     TailLightDrivingBrightness=0
     HeadLightHue=40
     HeadLightBrightness=130
     EngineSoundVolume=195
     DeathSoundVolume=255
     ReverseSoundPitch=15
     ReverseSoundVolume=195
     EngineSoundScaler=ESS_VehicleSpeed
     TireSlipSoundMaxVolume=132
     bEnableHeadLightEmitter=False
     bEnableShadow=True
     HealthMax=300.000000
     CollisionRadius=150.000000
     CollisionHeight=150.000000
     StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspChassisMP'
     Begin Object Class=HavokParams Name=HavokParams25
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
         ImpactThreshold=0.000000
     End Object
     HParams=HavokParams'VehicleVehicles.HavokParams25'
}
