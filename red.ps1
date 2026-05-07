# ============================================================
#  POKE-EXPLORER  —  A 2D Pokemon FireRed-style PS1 Game
#  Run with:  powershell -ExecutionPolicy Bypass -File PokéExplorer.ps1
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ── Tile constants ──────────────────────────────────────────
$T = @{ GRASS=0; PATH=1; WATER=2; TREE=3; WALL=4; TALL=5; SIGN=6; HOUSE=7; DOOR=8; GYM=9; CENTER=10 }

$TILE_COLOR = @{
    0  = [System.Drawing.Color]::FromArgb(72,168,72)
    1  = [System.Drawing.Color]::FromArgb(216,200,152)
    2  = [System.Drawing.Color]::FromArgb(56,120,216)
    3  = [System.Drawing.Color]::FromArgb(24,104,24)
    4  = [System.Drawing.Color]::FromArgb(96,96,96)
    5  = [System.Drawing.Color]::FromArgb(32,136,40)
    6  = [System.Drawing.Color]::FromArgb(200,168,88)
    7  = [System.Drawing.Color]::FromArgb(200,120,64)
    8  = [System.Drawing.Color]::FromArgb(168,80,32)
    9  = [System.Drawing.Color]::FromArgb(216,72,72)
    10 = [System.Drawing.Color]::FromArgb(248,248,248)
}

# ── Map data ────────────────────────────────────────────────
$MAP_PALLET = @(
    @(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4),
    @(4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,1,7,7,1,1,7,7,1,1,1,10,10,1,9,9,1,1,1,4),
    @(4,1,7,8,1,1,7,8,1,1,1,10,10,1,9,9,1,1,1,4),
    @(4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,1,1,1,1,1,1,6,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,4),
    @(4,1,1,1,0,5,5,5,5,5,5,5,5,5,0,1,1,1,1,4),
    @(4,1,1,1,0,5,5,5,5,5,5,5,5,5,0,1,1,1,1,4),
    @(4,1,1,1,0,5,5,5,5,5,5,5,5,5,0,1,1,1,1,4),
    @(4,1,1,1,0,5,5,5,5,5,5,5,5,5,0,1,1,1,1,4),
    @(4,1,1,1,0,0,0,0,0,1,0,0,0,0,0,1,1,1,1,4),
    @(4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,4),
    @(4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,1,3,3,3,1,1,1,1,1,1,1,1,3,3,3,1,1,1,4),
    @(4,1,3,3,3,1,1,1,1,1,1,1,1,3,3,3,1,1,1,4),
    @(4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4),
    @(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4)
)

$MAP_FOREST = @(
    @(3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,3,3,5,5,5,5,5,5,3,3,5,5,5,5,5,3),
    @(3,5,5,5,3,3,5,5,5,5,5,5,3,3,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,3,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,3,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,3,3,5,5,5,5,5,5,5,5,5,3,3,5,5,5,3),
    @(3,5,5,3,3,5,5,5,5,5,5,5,5,5,3,3,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,3,5,5,5,5,5,3,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,3,5,5,5,5,5,3,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,3),
    @(3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3)
)

# ── Pokemon data ─────────────────────────────────────────────
$POKEMON_DB = @(
    @{Name="Bulbasaur"; Emoji="🌱"; HP=45; Atk=49; Def=49; Type="Grass";
      Moves=@("Tackle","Vine Whip","Growl","Leech Seed")}
    @{Name="Charmander"; Emoji="🔥"; HP=39; Atk=52; Def=43; Type="Fire";
      Moves=@("Scratch","Ember","Growl","Smokescreen")}
    @{Name="Squirtle"; Emoji="💧"; HP=44; Atk=48; Def=65; Type="Water";
      Moves=@("Tackle","Water Gun","Tail Whip","Withdraw")}
    @{Name="Pidgey";   Emoji="🐦"; HP=40; Atk=45; Def=40; Type="Normal";
      Moves=@("Tackle","Gust","Sand Attack","Quick Attack")}
    @{Name="Rattata";  Emoji="🐭"; HP=30; Atk=56; Def=35; Type="Normal";
      Moves=@("Tackle","Quick Attack","Tail Whip","Hyper Fang")}
    @{Name="Caterpie"; Emoji="🐛"; HP=45; Atk=30; Def=35; Type="Bug";
      Moves=@("Tackle","String Shot","Tackle","String Shot")}
    @{Name="Pikachu";  Emoji="⚡"; HP=35; Atk=55; Def=30; Type="Electric";
      Moves=@("Tackle","Thunder Shock","Growl","Quick Attack")}
    @{Name="Geodude";  Emoji="🪨"; HP=40; Atk=80; Def=100; Type="Rock";
      Moves=@("Tackle","Rock Throw","Defense Curl","Magnitude")}
)

$MOVE_POWER = @{
    "Tackle"=40; "Vine Whip"=45; "Ember"=40; "Scratch"=40
    "Water Gun"=40; "Gust"=40; "Quick Attack"=40; "Thunder Shock"=40
    "Rock Throw"=50; "Hyper Fang"=80; "String Shot"=0; "Growl"=0
    "Smokescreen"=0; "Tail Whip"=0; "Sand Attack"=0; "Withdraw"=0
    "Defense Curl"=0; "Leech Seed"=0; "Magnitude"=70
}

# ── Game state ───────────────────────────────────────────────
$GS = @{
    MapData    = $MAP_PALLET
    MapName    = "Pallet Town"
    PlayerX    = 9
    PlayerY    = 5
    PlayerDir  = "down"
    PlayerHP   = 40
    PlayerMaxHP= 40
    PlayerLevel= 5
    Money      = 500
    Badges     = 0
    Steps      = 0
    InBattle   = $false
    BattleLog  = @()
    BattleTurn = "player"
    EnemyPoke  = $null
    PlayerPoke = $null
    PlayerEXP  = 0
    Message    = "Welcome to Pallet Town! Use arrow keys to move."
    Inventory  = @{Potion=3; PokeBall=5; SuperPotion=1}
}

function New-Pokemon($template, $level) {
    $maxhp = [int]($template.HP * $level / 5) + 10
    @{
        Name   = $template.Name
        Emoji  = $template.Emoji
        HP     = $maxhp
        MaxHP  = $maxhp
        Atk    = [int]($template.Atk * $level / 50) + 5
        Def    = [int]($template.Def * $level / 50) + 5
        Level  = $level
        Type   = $template.Type
        Moves  = $template.Moves
        EXP    = $level * 10
    }
}

function Get-TilePassable($tile) {
    return ($tile -ne 4 -and $tile -ne 3 -and $tile -ne 2 -and $tile -ne 7 -and $tile -ne 9 -and $tile -ne 10)
}

function Move-Player($dx, $dy) {
    if ($GS.InBattle) { return }
    $nx = $GS.PlayerX + $dx
    $ny = $GS.PlayerY + $dy
    $map = $GS.MapData
    if ($ny -lt 0 -or $ny -ge $map.Count -or $nx -lt 0 -or $nx -ge $map[0].Count) { return }
    $tile = $map[$ny][$nx]

    # Map warp: bottom exit of Pallet → Forest
    if ($GS.MapName -eq "Pallet Town" -and $ny -ge 19) {
        $GS.MapData = $MAP_FOREST
        $GS.MapName = "Viridian Forest"
        $GS.PlayerY = 1
        $GS.PlayerX = 9
        $GS.Message = "Entered Viridian Forest! Wild Pokémon lurk in the tall grass!"
        return
    }
    if ($GS.MapName -eq "Viridian Forest" -and $ny -le 0) {
        $GS.MapData = $MAP_PALLET
        $GS.MapName = "Pallet Town"
        $GS.PlayerY = 18
        $GS.PlayerX = 9
        $GS.Message = "Returned to Pallet Town."
        return
    }

    if (-not (Get-TilePassable $tile)) {
        # Special interact: sign, door, pokecenter, gym
        if ($tile -eq 6) { $GS.Message = "SIGN: Route 1 → Viridian City. Watch out for tall grass!" }
        if ($tile -eq 8) { $GS.Message = "It's a house. The door is locked." }
        if ($tile -eq 10) { Heal-AtCenter }
        if ($tile -eq 9)  { $GS.Message = "GYM: The Gym Leader is waiting... (Badges: $($GS.Badges)/3)" }
        return
    }

    $GS.PlayerX = $nx
    $GS.PlayerY = $ny
    $GS.Steps++

    if ($dx -eq 1)  { $GS.PlayerDir = "right" }
    if ($dx -eq -1) { $GS.PlayerDir = "left" }
    if ($dy -eq 1)  { $GS.PlayerDir = "down" }
    if ($dy -eq -1) { $GS.PlayerDir = "up" }

    # Tall grass encounter
    if ($tile -eq 5) {
        if ((Get-Random -Maximum 100) -lt 18) {
            Start-Battle
        }
    }
}

function Heal-AtCenter {
    $GS.PlayerHP = $GS.PlayerMaxHP
    if ($GS.PlayerPoke) { $GS.PlayerPoke.HP = $GS.PlayerPoke.MaxHP }
    $GS.Message = "✨ POKEMON CENTER: Your Pokémon have been restored to full health!"
}

function Start-Battle {
    $pool = if ($GS.MapName -eq "Viridian Forest") {
        @($POKEMON_DB[3],$POKEMON_DB[4],$POKEMON_DB[5],$POKEMON_DB[6])
    } else {
        @($POKEMON_DB[3],$POKEMON_DB[4])
    }
    $template = $pool | Get-Random
    $lvl = [math]::Max(2, $GS.PlayerLevel + (Get-Random -Minimum -2 -Maximum 3))

    if (-not $GS.PlayerPoke) {
        $GS.PlayerPoke = New-Pokemon $POKEMON_DB[0] $GS.PlayerLevel
    }

    $GS.EnemyPoke  = New-Pokemon $template $lvl
    $GS.InBattle   = $true
    $GS.BattleTurn = "player"
    $GS.BattleLog  = @("A wild $($GS.EnemyPoke.Emoji) $($GS.EnemyPoke.Name) appeared! (Lv.$lvl)")
    $GS.Message    = "⚔️ BATTLE: $($GS.EnemyPoke.Name) appeared!"
}

function Do-PlayerAttack($moveName) {
    $pwr = $MOVE_POWER[$moveName]
    $enemy = $GS.EnemyPoke
    $player = $GS.PlayerPoke
    if ($pwr -gt 0) {
        $dmg = [math]::Max(1, [int](($player.Atk * $pwr / $enemy.Def / 5) + (Get-Random -Minimum 1 -Maximum 6)))
        $enemy.HP = [math]::Max(0, $enemy.HP - $dmg)
        $GS.BattleLog = @("$($player.Name) used $moveName!", "Dealt $dmg damage!")
    } else {
        $GS.BattleLog = @("$($player.Name) used $moveName!", "...")
    }

    if ($enemy.HP -le 0) {
        $exp = $enemy.Level * 5
        $GS.PlayerEXP += $exp
        $GS.Money += $enemy.Level * 8
        $GS.BattleLog += "$($enemy.Name) fainted! +$exp EXP"
        # Level up check
        if ($GS.PlayerEXP -ge $GS.PlayerLevel * 20) {
            $GS.PlayerLevel++
            $GS.PlayerMaxHP += 5
            $GS.PlayerHP = $GS.PlayerMaxHP
            if ($GS.PlayerPoke) {
                $GS.PlayerPoke.MaxHP += 5
                $GS.PlayerPoke.HP = $GS.PlayerPoke.MaxHP
                $GS.PlayerPoke.Atk += 2
                $GS.PlayerPoke.Level = $GS.PlayerLevel
            }
            $GS.BattleLog += "⬆️ Level Up! Now Lv.$($GS.PlayerLevel)!"
            # Badge milestone
            if ($GS.PlayerLevel -in @(10,20,30)) { $GS.Badges++; $GS.BattleLog += "🏅 Badge earned!" }
        }
        End-Battle
        return
    }
    # Enemy turn
    $GS.BattleTurn = "enemy"
    Do-EnemyAttack
}

function Do-EnemyAttack {
    $enemy  = $GS.EnemyPoke
    $player = $GS.PlayerPoke
    $move   = $enemy.Moves | Get-Random
    $pwr    = $MOVE_POWER[$move]
    if ($pwr -gt 0) {
        $dmg = [math]::Max(1, [int](($enemy.Atk * $pwr / $player.Def / 5) + (Get-Random -Minimum 1 -Maximum 4)))
        $player.HP = [math]::Max(0, $player.HP - $dmg)
        $GS.PlayerHP = $player.HP
        $GS.BattleLog += "Enemy $($enemy.Name) used $move! Dealt $dmg dmg."
    } else {
        $GS.BattleLog += "Enemy $($enemy.Name) used $move!"
    }
    if ($player.HP -le 0) {
        $GS.BattleLog += "💀 $($player.Name) fainted! Heading to Pokémon Center..."
        $GS.Money = [math]::Max(0, $GS.Money - 50)
        Heal-AtCenter
        End-Battle
    }
    $GS.BattleTurn = "player"
}

function Do-ThrowBall {
    $enemy = $GS.EnemyPoke
    if ($GS.Inventory.PokeBall -le 0) { $GS.BattleLog = @("No PokéBalls left!"); return }
    $GS.Inventory.PokeBall--
    $rate = [int](100 - ($enemy.HP / $enemy.MaxHP * 60))
    if ((Get-Random -Maximum 100) -lt $rate) {
        $GS.BattleLog = @("⬜⬛⬜ Gotcha! $($enemy.Name) was caught!", "+$($enemy.Level * 15) money!")
        $GS.Money += $enemy.Level * 15
        End-Battle
    } else {
        $GS.BattleLog = @("The ball missed... $($enemy.Name) broke free!")
        Do-EnemyAttack
    }
}

function Do-UsePotion {
    if ($GS.Inventory.Potion -le 0 -and $GS.Inventory.SuperPotion -le 0) {
        $GS.BattleLog = @("No potions left!"); return
    }
    $heal = 0
    if ($GS.Inventory.Potion -gt 0) { $GS.Inventory.Potion--; $heal = 20 }
    elseif ($GS.Inventory.SuperPotion -gt 0) { $GS.Inventory.SuperPotion--; $heal = 50 }
    $GS.PlayerPoke.HP = [math]::Min($GS.PlayerPoke.MaxHP, $GS.PlayerPoke.HP + $heal)
    $GS.PlayerHP = $GS.PlayerPoke.HP
    $GS.BattleLog = @("Used Potion! +$heal HP", "HP: $($GS.PlayerPoke.HP)/$($GS.PlayerPoke.MaxHP)")
    Do-EnemyAttack
}

function Do-Run {
    if ((Get-Random -Maximum 100) -lt 60) {
        $GS.BattleLog = @("Got away safely!")
        End-Battle
    } else {
        $GS.BattleLog = @("Can't escape!")
        Do-EnemyAttack
    }
}

function End-Battle {
    $GS.InBattle = $false
    $GS.EnemyPoke = $null
}

# ── Rendering ────────────────────────────────────────────────
$TS = 16
$VIEWPORT_W = 20
$VIEWPORT_H = 15
$CANVAS_W = $VIEWPORT_W * $TS   # 320
$CANVAS_H = $VIEWPORT_H * $TS   # 240

function Draw-Game($g) {
    $map = $GS.MapData
    $camX = [math]::Max(0, [math]::Min($GS.PlayerX - [int]($VIEWPORT_W/2), $map[0].Count - $VIEWPORT_W))
    $camY = [math]::Max(0, [math]::Min($GS.PlayerY - [int]($VIEWPORT_H/2), $map.Count - $VIEWPORT_H))

    # Draw tiles
    for ($ty = 0; $ty -lt $VIEWPORT_H; $ty++) {
        for ($tx = 0; $tx -lt $VIEWPORT_W; $tx++) {
            $mx = $camX + $tx; $my = $camY + $ty
            if ($my -ge $map.Count -or $mx -ge $map[0].Count) { continue }
            $tile = $map[$my][$mx]
            $col  = $TILE_COLOR[$tile]
            $b    = [System.Drawing.SolidBrush]::new($col)
            $g.FillRectangle($b, $tx*$TS, $ty*$TS, $TS, $TS)
            $b.Dispose()

            # Tile decorations
            $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(30,0,0,0), 0.5)
            $g.DrawRectangle($pen, $tx*$TS, $ty*$TS, $TS-1, $TS-1)
            $pen.Dispose()

            if ($tile -eq 3) {
                # Tree crown
                $tb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(16,80,16))
                $g.FillEllipse($tb, $tx*$TS+1, $ty*$TS, $TS-2, $TS-2)
                $tb.Dispose()
            }
            if ($tile -eq 5) {
                # Tall grass blades
                $gb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(20,100,24))
                $g.FillRectangle($gb, $tx*$TS+3, $ty*$TS+2, 3, 10)
                $g.FillRectangle($gb, $tx*$TS+9, $ty*$TS+3, 3, 9)
                $gb.Dispose()
            }
            if ($tile -eq 2) {
                # Water shimmer
                $wb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80,160,255))
                $g.FillRectangle($wb, $tx*$TS+2, $ty*$TS+4, 5, 3)
                $g.FillRectangle($wb, $tx*$TS+9, $ty*$TS+9, 5, 3)
                $wb.Dispose()
            }
            if ($tile -eq 10) {
                # Pokecenter cross
                $rb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220,50,50))
                $g.FillRectangle($rb, $tx*$TS+6, $ty*$TS+3, 4, 10)
                $g.FillRectangle($rb, $tx*$TS+3, $ty*$TS+6, 10, 4)
                $rb.Dispose()
            }
            if ($tile -eq 9) {
                # Gym symbol
                $gy = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(200,30,30))
                $g.FillRectangle($gy, $tx*$TS+4, $ty*$TS+4, 8, 8)
                $gy.Dispose()
                $font = [System.Drawing.Font]::new("Arial", 6, [System.Drawing.FontStyle]::Bold)
                $g.DrawString("G", $font, [System.Drawing.Brushes]::White, ($tx*$TS+5), ($ty*$TS+5))
                $font.Dispose()
            }
        }
    }

    # Draw player
    $px = ($GS.PlayerX - $camX) * $TS
    $py = ($GS.PlayerY - $camY) * $TS
    # Shadow
    $sb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60,0,0,0))
    $g.FillEllipse($sb, $px+2, $py+11, 12, 5)
    $sb.Dispose()
    # Body
    $pb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(220,80,80))
    $g.FillRectangle($pb, $px+4, $py+6, 8, 9)
    $pb.Dispose()
    # Head
    $hb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255,210,160))
    $g.FillEllipse($hb, $px+3, $py+1, 10, 10)
    $hb.Dispose()
    # Hat
    $hatb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255,40,40))
    $g.FillRectangle($hatb, $px+3, $py+1, 10, 4)
    $hatb.Dispose()
    # Direction indicator
    $db = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80,255,255,255))
    switch ($GS.PlayerDir) {
        "down"  { $g.FillRectangle($db, $px+5, $py+14, 6, 2) }
        "up"    { $g.FillRectangle($db, $px+5, $py, 6, 2) }
        "left"  { $g.FillRectangle($db, $px, $py+5, 2, 6) }
        "right" { $g.FillRectangle($db, $px+14, $py+5, 2, 6) }
    }
    $db.Dispose()

    # HUD bar
    $hudb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(180,0,0,40))
    $g.FillRectangle($hudb, 0, 0, $CANVAS_W, 14)
    $hudb.Dispose()
    $font = [System.Drawing.Font]::new("Courier New", 7, [System.Drawing.FontStyle]::Bold)
    $hudText = "$($GS.MapName)  |  Lv.$($GS.PlayerLevel)  HP:$($GS.PlayerHP)/$($GS.PlayerMaxHP)  💰$($GS.Money)  🏅$($GS.Badges)/3  Steps:$($GS.Steps)"
    $g.DrawString($hudText, $font, [System.Drawing.Brushes]::White, 3, 2)
    $font.Dispose()

    # Message bar
    $msgb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(200,0,0,40))
    $g.FillRectangle($msgb, 0, $CANVAS_H-24, $CANVAS_W, 24)
    $msgb.Dispose()
    $mfont = [System.Drawing.Font]::new("Courier New", 7)
    $msg = $GS.Message
    if ($msg.Length -gt 55) { $msg = $msg.Substring(0,52) + "..." }
    $g.DrawString($msg, $mfont, [System.Drawing.Brushes]::White, 3, ($CANVAS_H-21))
    $mfont.Dispose()
}

function Draw-Battle($g) {
    $enemy  = $GS.EnemyPoke
    $player = $GS.PlayerPoke

    # Sky & ground
    $skyb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(184,216,248))
    $g.FillRectangle($skyb, 0, 0, $CANVAS_W, $CANVAS_H)
    $skyb.Dispose()
    $grb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(136,184,72))
    $g.FillRectangle($grb, 0, 100, $CANVAS_W, $CANVAS_H-100)
    $grb.Dispose()

    # Enemy platform
    $epb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(104,160,48))
    $g.FillEllipse($epb, 170, 45, 100, 20)
    $epb.Dispose()

    # Player platform
    $ppb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80,128,32))
    $g.FillEllipse($ppb, 20, 115, 120, 24)
    $ppb.Dispose()

    # Enemy sprite (big emoji-style block)
    $efont = [System.Drawing.Font]::new("Segoe UI Emoji", 28)
    $g.DrawString($enemy.Emoji, $efont, [System.Drawing.Brushes]::Black, 185, 10)
    $efont.Dispose()

    # Player sprite
    $pfont = [System.Drawing.Font]::new("Segoe UI Emoji", 24)
    $g.DrawString($player.Emoji, $pfont, [System.Drawing.Brushes]::Black, 40, 90)
    $pfont.Dispose()

    # Enemy HP box
    $hpb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240,240,208))
    $g.FillRectangle($hpb, 5, 5, 155, 45)
    $g.DrawRectangle([System.Drawing.Pens]::DarkGray, 5, 5, 155, 45)
    $hpb.Dispose()
    $nf = [System.Drawing.Font]::new("Courier New", 8, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("$($enemy.Name)  Lv.$($enemy.Level)", $nf, [System.Drawing.Brushes]::Black, 8, 8)
    $nf.Dispose()
    $pct = [math]::Max(0, $enemy.HP / $enemy.MaxHP)
    $hpCol = if ($pct -gt 0.5) { [System.Drawing.Color]::FromArgb(72,216,72) }
             elseif ($pct -gt 0.2) { [System.Drawing.Color]::FromArgb(248,216,0) }
             else { [System.Drawing.Color]::FromArgb(248,40,0) }
    $g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::Gray), 8, 25, 100, 8)
    $g.FillRectangle([System.Drawing.SolidBrush]::new($hpCol), 8, 25, [int](100*$pct), 8)
    $hpf = [System.Drawing.Font]::new("Courier New", 7)
    $g.DrawString("HP: $($enemy.HP)/$($enemy.MaxHP)", $hpf, [System.Drawing.Brushes]::DarkGray, 8, 35)
    $hpf.Dispose()

    # Player HP box
    $phb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(240,240,208))
    $g.FillRectangle($phb, 160, 105, 155, 45)
    $g.DrawRectangle([System.Drawing.Pens]::DarkGray, 160, 105, 155, 45)
    $phb.Dispose()
    $pnf = [System.Drawing.Font]::new("Courier New", 8, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("$($player.Name)  Lv.$($player.Level)", $pnf, [System.Drawing.Brushes]::Black, 163, 108)
    $pnf.Dispose()
    $ppct = [math]::Max(0, $player.HP / $player.MaxHP)
    $phpCol = if ($ppct -gt 0.5) { [System.Drawing.Color]::FromArgb(72,216,72) }
              elseif ($ppct -gt 0.2) { [System.Drawing.Color]::FromArgb(248,216,0) }
              else { [System.Drawing.Color]::FromArgb(248,40,0) }
    $g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::Gray), 163, 125, 100, 8)
    $g.FillRectangle([System.Drawing.SolidBrush]::new($phpCol), 163, 125, [int](100*$ppct), 8)
    $phpf = [System.Drawing.Font]::new("Courier New", 7)
    $g.DrawString("HP: $($player.HP)/$($player.MaxHP)", $phpf, [System.Drawing.Brushes]::DarkGray, 163, 135)
    $phpf.Dispose()

    # Battle log panel
    $blb = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235,225,200))
    $g.FillRectangle($blb, 0, 155, $CANVAS_W, 85)
    $g.DrawRectangle([System.Drawing.Pens]::DarkGray, 0, 155, $CANVAS_W, 85)
    $blb.Dispose()

    $lf = [System.Drawing.Font]::new("Courier New", 8)
    $y = 158
    foreach ($line in $GS.BattleLog | Select-Object -Last 4) {
        $g.DrawString($line, $lf, [System.Drawing.Brushes]::Black, 5, $y)
        $y += 14
    }
    $lf.Dispose()

    # Action buttons hint
    if ($GS.BattleTurn -eq "player") {
        $bf = [System.Drawing.Font]::new("Courier New", 7)
        $g.DrawString("[1-4] Attack   [B] Ball   [H] Heal   [R] Run", $bf, [System.Drawing.Brushes]::DarkBlue, 5, 222)
        $bf.Dispose()
    }
}

# ── Build the Form ────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text = "🎮 Poké-Explorer  —  PowerShell Edition"
$form.Size = [System.Drawing.Size]::new(340, 290)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::Black
$form.StartPosition = "CenterScreen"

$pb = New-Object System.Windows.Forms.PictureBox
$pb.Size = [System.Drawing.Size]::new($CANVAS_W, $CANVAS_H)
$pb.Location = [System.Drawing.Point]::new(4, 4)
$pb.BackColor = [System.Drawing.Color]::Black
$form.Controls.Add($pb)

$bmp    = New-Object System.Drawing.Bitmap($CANVAS_W, $CANVAS_H)
$pb.Image = $bmp

function Redraw {
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    if ($GS.InBattle) { Draw-Battle $g } else { Draw-Game $g }
    $g.Dispose()
    $pb.Invalidate()
}

# Choose starter on load
$GS.PlayerPoke = New-Pokemon $POKEMON_DB[0] $GS.PlayerLevel

# Key handler
$form.add_KeyDown({
    param($s, $e)
    if (-not $GS.InBattle) {
        switch ($e.KeyCode) {
            "Up"    { Move-Player  0 -1 }
            "Down"  { Move-Player  0  1 }
            "Left"  { Move-Player -1  0 }
            "Right" { Move-Player  1  0 }
            "W"     { Move-Player  0 -1 }
            "S"     { Move-Player  0  1 }
            "A"     { Move-Player -1  0 }
            "D"     { Move-Player  1  0 }
        }
    } else {
        # Battle input: 1-4 = moves, B = ball, H = heal, R = run
        if ($GS.BattleTurn -eq "player") {
            $moves = $GS.PlayerPoke.Moves
            switch ($e.KeyCode) {
                "D1"    { Do-PlayerAttack $moves[0] }
                "D2"    { Do-PlayerAttack $moves[1] }
                "D3"    { Do-PlayerAttack $moves[2] }
                "D4"    { Do-PlayerAttack $moves[3] }
                "NumPad1" { Do-PlayerAttack $moves[0] }
                "NumPad2" { Do-PlayerAttack $moves[1] }
                "NumPad3" { Do-PlayerAttack $moves[2] }
                "NumPad4" { Do-PlayerAttack $moves[3] }
                "B"     { Do-ThrowBall }
                "H"     { Do-UsePotion }
                "R"     { Do-Run }
            }
        }
    }
    Redraw
})
$form.KeyPreview = $true

# Timer for smooth redraws
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 50
$timer.add_Tick({ Redraw })
$timer.Start()

Redraw
[void]$form.ShowDialog()
$timer.Stop()
