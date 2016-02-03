//=============================================================================
// xDomLetter.
//=============================================================================
class xDomLetter extends Decoration
    abstract;


var() Material  NewShader;
var() Material  RedTeamShader;
var() Material  BlueTeamShader;
var() Material  NeutralShader;
var() Material  RedTouchedShader;
var() Material  BlueTouchedShader;


replication
{
    reliable if (Role == ROLE_Authority)
        NewShader;
}

simulated event PostNetReceive()
{
    if (NewShader != None)
    {
        SetSkin(0,NewShader);
    }
}

defaultproperties
{
     RedTeamShader=Shader'VehicleGamePickupsTex.Ammo.ammo_explosive_shader'
     BlueTeamShader=Shader'VehicleGamePickupsTex.Ammo.ammo_energy_shader'
     NeutralShader=Shader'VehicleGamePickupsTex.Ammo.assault_neutral_shader'
     RedTouchedShader=Shader'VehicleGamePickupsTex.Ammo.assault_flashing_red_shader'
     BlueTouchedShader=Shader'VehicleGamePickupsTex.Ammo.assault_flashing_blue_shader'
     bReplicateMovement=False
     bNetNotify=True
}
