class FlameThrowerFire extends AltMuzzleFlash;

function Tick(float dt)
{
	local vector start, end;

	start = vect(150, -10, -10);
	end = vect(160, 10, 10);

	start = start >> Rotation;
	end = end >> Rotation;

	Emitters[0].StartVelocityRange.X.Min = start.X;
	Emitters[0].StartVelocityRange.Y.Min = start.Y;
	Emitters[0].StartVelocityRange.Z.Min = start.Z;

	Emitters[0].StartVelocityRange.X.Max = end.X;
	Emitters[0].StartVelocityRange.Y.Max = end.Y;
	Emitters[0].StartVelocityRange.Z.Max = end.Z;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter371
         MaxParticles=22
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         ColorScaleRepeats=2.000000
         FadeOutStartTime=0.200000
         FadeInEndTime=0.200000
         Texture=Texture'NoonTextures.Fire.firepoop'
         ColorScale(0)=(RelativeTime=4.900000,Color=(G=59,R=253))
         SizeScale(0)=(RelativeTime=3.000000,RelativeSize=1.100000)
         SubdivisionScale(0)=10.000000
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Max=0.125000),Y=(Max=0.500000))
         StartSizeRange=(X=(Min=30.000000,Max=45.000000),Y=(Min=50.000000,Max=75.000000),Z=(Min=75.000000,Max=75.000000))
         LifetimeRange=(Min=0.500000,Max=1.250000)
         StartVelocityRange=(X=(Min=150.000000,Max=160.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter371'
     bNoDelete=False
}
