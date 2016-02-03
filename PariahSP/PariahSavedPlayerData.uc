class PariahSavedPlayerData extends SavedPlayerData
    native;

struct native VGWeaponInfo
{
    var string  WeaponClassName;
    var int     WECLevel;
    var int     AmmoAmount;
    var int     RemainingMagAmmo;
    var int     MagAmount;
};

var int                 HasSavedData[2];
var int                 WECCount[2];
var int                 Health[2];
var float               ShieldStrength[2];
var float               DashTime[2];
var array<VGWeaponInfo> WeaponsP1;
var array<VGWeaponInfo> WeaponsP2;
var int                 CurWeaponIndex[2];
var int                 GamePadIndex[2];


simulated private function VGPawn GetPawn(VehiclePlayer vp)
{
    local Pawn   p;
    local VGPawn vgp;
    
    if(vp == None)
    {
        return(None);
    }
    
    p = vp.Pawn;

    if(p == None)
    {
        p = vp.MatineePawn;
        if(p == None)
        {
            return(None);
        }
    }

    if(p.IsA('VGPawn'))
    {
        vgp = VGPawn(p);
    }
    else if(p.IsA('VGVehicle'))
    {
        vgp = VGVehicle(p).Driver;
    }
    
    return(vgp);
}

simulated function Update(GameInfo game, int numPlayers)
{
    local VehiclePlayer spc;
    local VGPawn        pawn;
    local int           index;

    `log( "RJ: UpdateGameProfile("@game@") called" );

    for(index = 0; index < numPlayers; ++index)
    {
        HasSavedData[index] = 0;
        
        spc = GetSPCByIndex(game.Level, index);
        if(spc == None)
        {
            continue;
        }
        
        // HasSavedData[index] == 1 means that we are in the game but dead
        ++HasSavedData[index];
        
        GamePadIndex[index] = spc.Player.GamePadIndex;
                
        WECCount[index] = spc.WECCount;

        pawn = GetPawn(spc);
        if(pawn == None)
        {
            continue;
        }

        // HasSavedData[index] == 2 means that we are in the game with a pawn and have inventory
        ++HasSavedData[index];

        Health[index]           = pawn.Health;
        ShieldStrength[index]   = pawn.ShieldStrength;
        DashTime[index]         = pawn.DashTime;

        // go through the inventory looking for weapons and save them out
        //
        if(index == 0)
        {
            SaveWeapons(spc, WeaponsP1, CurWeaponIndex[index]);
        }
        else
        {
            SaveWeapons(spc, WeaponsP2, CurWeaponIndex[index]);
        }
            
        `log( "RJ: updated game profile index = "$index );
    }
    `log( "RJ: updated game profile" );
    LogSavedData(numPlayers);
}

simulated function CloneFirstPlayer(VehiclePlayer Target, GameInfo game)
{
    local VehiclePlayer Source;
    local VGWeapon Weapon;
    local VGWeapon SourceWeapon;
    local Inventory inv;
    local VGPawn sourcePawn;
    local VGPawn TargetPawn;

    log("** CloneFirstPlayer for fresh coop join!");

    Source = GetSPCByIndex(game.Level, 0);
    sourcePawn = GetPawn(Source);
    TargetPawn = GetPawn(Target);
    
    if(sourcePawn == None || TargetPawn == None)
    {
        warn("CloneFirstPlayer failure: sourcePawn="$sourcePawn$" TargetPawn="$TargetPawn);
        return;
    }

    Target.WECCount = Source.WECCount;
    TargetPawn.Health = sourcePawn.Health;
    TargetPawn.ShieldStrength = sourcePawn.ShieldStrength;
    TargetPawn.DashTime = sourcePawn.DashTime;

    for ( inv = sourcePawn.Inventory; inv != None; inv = inv.Inventory )
    {
        SourceWeapon = VGWeapon( inv );
        if ( SourceWeapon == None )
        {
            continue;
        }

        TargetPawn.GiveWeaponByClass( SourceWeapon.class );
        Weapon = VGWeapon( TargetPawn.FindInventoryType( SourceWeapon.class ) );
        Weapon.SetWecLevel(SourceWeapon.WecLevel);
        Weapon.Ammo[0].AmmoAmount = SourceWeapon.Ammo[0].AmmoAmount;
        if(SourceWeapon.Ammo[0].IsA('AmmoClip'))
        {
            AmmoClip(Weapon.Ammo[0]).RemainingMagAmmo = AmmoClip(SourceWeapon.Ammo[0]).RemainingMagAmmo;
            AmmoClip(Weapon.Ammo[0]).MagAmount = AmmoClip(SourceWeapon.Ammo[0]).MagAmount;
        }
    }
}

simulated function bool SetupInventory(PlayerController PC, GameInfo game, int numPlayers)
{
    local VehiclePlayer spc;
    local int index;
    local VGPawn pawn;

    spc = VehiclePlayer(PC);
    pawn = GetPawn(spc);
    
    if(pawn == None)
    {
        warn("pawn is none in SetupInventory for pc="$pc);
        assert(false);
        return(false);
    }
    
    if(spc == GetSPCByIndex(game.Level, 0))
    {
        index = 0;
    }
    else
    {
        index = 1;
    }

    log("LoadGameProfile"@PC@game@index@numPlayers);
    
    if(index == 1 && (numPlayers == 1 || HasSavedData[index] == 0))
    {
        // profile didn't have coop player last save, use the first player!
        CloneFirstPlayer(VehiclePlayer(PC), game);
        return(true);
    }

    if(HasSavedData[index] == 0)
    {
        Log("No saved data, not applying");
        return(false);
    }

    if(HasSavedData[index] == 1)
    {
        // pawn was dead while saving, restore inv from gameinfo
        return(game.RestoreRespawnState(pawn));
    }
    else
    {
        `log( "RJ: loading game profile into"@spc@index );
        LogSavedData(numPlayers);

        spc.WECCount = WECCount[index];
        
        if
        ( 
            spc.StartSpot != None &&
            spc.StartSpot.IsA('PlayerStart') &&
            PlayerStart(spc.StartSpot).bPrimaryStart &&
            pawn.Health == game.Level.PrimaryStartHealth &&
            game.Level.PrimaryStartHealth < pawn.HealthMax 
        )
        {
            log("Not setting player health from profile, levelinfo is authority."); // sjs - shameful.
        }
        else
        {
            pawn.Health = Health[index];
        }
        
        pawn.ShieldStrength = ShieldStrength[index];
        pawn.DashTime = DashTime[index];
        if(index == 0)
        {
            LoadWeapons(spc, WeaponsP1, CurWeaponIndex[index]);
        }
        else
        {
            LoadWeapons(spc, WeaponsP2, CurWeaponIndex[index]);
        }
    }
    return(true);
}

simulated function LogWeapons(array<VGWeaponInfo> Weapons, int curWeaponIndex)
{
    local int w;
    
    log(">>>LogWeapons!");
        
    for( w = 0; w < Weapons.Length; w++ )
    {
        if ( w == curWeaponIndex )
        {
            `log(" LogSavedData... Weapon"@w@")"@Weapons[w].WeaponClassName@"at WEC level"@Weapons[w].WECLevel@"- default" );
        }
        else
        {
            `log(" LogSavedData... Weapon"@w@")"@Weapons[w].WeaponClassName@"at WEC level"@Weapons[w].WECLevel );
        }
    }
}

simulated function LogSavedData(int numPlayers)
{
    local int index;

    for(index = 0; index < numPlayers; ++index)
    {
        if(HasSavedData[index] == 0)
        {
            continue;
        }
        `log(" LogSavedData... index="$index);
        `log(" LogSavedData... WECCount="$WECCount[index]);
        `log(" LogSavedData... Health="$Health[index]);
        `log(" LogSavedData... Shield="$ShieldStrength[index]);
        `log(" LogSavedData... Dash="$DashTime[index]);

        if(index == 0)
        {
            LogWeapons(WeaponsP1, CurWeaponIndex[index]);
        }
        else
        {
            LogWeapons(WeaponsP2, CurWeaponIndex[index]);
        }
    }

    Super.LogSavedData(numPlayers);
}

simulated function VehiclePlayer GetSPCByIndex(LevelInfo Level, int ordinal)
{
    local Controller C;
    local Array<VehiclePlayer> PCs;
    local int i, j;
    local VehiclePlayer tmp;

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if ( (VehiclePlayer(C) != None) && (Viewport(PlayerController(C).Player) != None) )
        {
            PCs[PCs.Length] = VehiclePlayer(C);
        }
    }
    
    for (i=0; i<PCs.Length-1; i++)
    {
        for (j=i+1; j<PCs.Length; j++)
        {
            if( PCs[i].Player.SplitIndex > PCs[j].Player.SplitIndex )
            {
                tmp = PCs[i];
                PCs[i] = PCs[j];
                PCs[j] = tmp;
            }
        }
    }
    return PCs[ordinal];
}

simulated function SaveWeapons(VehiclePlayer spc, out array<VGWeaponInfo> Weapons, out int curWeapIndex)
{
    local Inventory inv;
    local VGWeapon  pw;
    local int       w;
    local VGPawn    pawn;

    curWeapIndex = -1;
    Weapons.Length = 0;
    
    pawn = GetPawn(spc);
        
    if(pawn == None)
    {
        return;
    }
    
    for ( inv = pawn.Inventory; inv != None; inv = inv.Inventory )
    {
        `log( "RJ: checking inventory item"@inv );
        pw = VGWeapon( inv );
        if ( pw != None )
        {
            `log( "RJ: found personal weapon"@pw );
            w = Weapons.Length;
            Weapons.Length = w + 1;
            Weapons[w].WeaponClassName = string(pw.Class);
            Weapons[w].WECLevel = pw.WECLevel;
            Weapons[w].AmmoAmount = pw.Ammo[0].AmmoAmount;
            if(pw.Ammo[0].IsA('AmmoClip'))
            {
                Weapons[w].RemainingMagAmmo = AmmoClip(pw.Ammo[0]).RemainingMagAmmo;
                Weapons[w].MagAmount = AmmoClip(pw.Ammo[0]).MagAmount;
            }
            if ( pw == pawn.Weapon )
            {
                curWeapIndex = w;
            }
        }
    }
}

simulated function LoadWeapons(VehiclePlayer spc, array<VGWeaponInfo> Weapons, int curWeapIndex)
{
    local int       w;
    local VGWeapon  pw, pwCur;
    local class<VGWeapon> weaponClass;
    local VGPawn pawn;

    pawn = GetPawn(spc);
    
    for( w = 0; w < Weapons.Length; w++ )
    {
        weaponClass = class<VGWeapon>(DynamicLoadObject(Weapons[w].WeaponClassName, class'class'));
        pawn.GiveWeaponByClass( weaponClass );
        pw = VGWeapon( pawn.FindInventoryType( weaponClass ) );
        if ( pw != None )
        {
            pw.SetWECLevel( Weapons[w].WECLevel );
            pw.Ammo[0].AmmoAmount = Weapons[w].AmmoAmount;
            if(pw.Ammo[0].IsA('AmmoClip'))
            {
                AmmoClip(pw.Ammo[0]).RemainingMagAmmo = Weapons[w].RemainingMagAmmo;
                AmmoClip(pw.Ammo[0]).MagAmount = Weapons[w].MagAmount;
            }
            if ( w == curWeapIndex )
            {
                pwCur = pw;
            }
        }
        else
        {
            warn( "RJ: weapon of type"@Weapons[w].WeaponClassName@" wasn't created properly" );
        }
    }
    if ( pwCur != None )
    {
        spc.SwitchWeapon( pwCur.InventoryGroup );
        pwCur.Ammo[0].CheckOutOfAmmo();
    }
}

defaultproperties
{
}
