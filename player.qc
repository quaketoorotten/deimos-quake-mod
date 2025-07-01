
void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6 

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6 

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run;

void()	player_stand1 =[	$axstnd1,	player_stand1	]
{
	self.weaponframe=0;
	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	if (self.weapon == IT_AXE)
	{
		if (self.walkframe >= 12)
			self.walkframe = 0;
		self.frame = $axstnd1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 5)
			self.walkframe = 0;
		self.frame = $stand1 + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;	
};

void()	player_run =[	$rockrun1,	player_run	]
{
	self.weaponframe = 0;
	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_stand1();
		return;
	}

	if (self.weapon == IT_AXE)
	{
		if (self.walkframe == 6)
			self.walkframe = 0;
		self.frame = 0 + self.walkframe;
	}
	else
	{
		if (self.walkframe == 6)
			self.walkframe = 0;
		self.frame = self.frame + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;
};

void()	player_shot1 =	[94, player_shot2	] {self.weaponframe=1; 
self.effects = self.effects | EF_MUZZLEFLASH;};
void()	player_shot2 =	[95, player_shot3	] {self.weaponframe=2; };
void()	player_shot3 =	[96, player_shot4	] {self.weaponframe=3; self.nextthink = time + 0.12;};
void()	player_shot4 =	[97, player_shot5	] {self.weaponframe=4; self.nextthink = time + 0.12;};
void()	player_shot5 =	[98, player_shot6	] {self.weaponframe=5; self.nextthink = time + 0.12;};
void()	player_shot6 =	[99,  player_run	      ] {self.weaponframe=6; self.nextthink = time + 0.12;};

void()	player_sshot1 =	[100, player_sshot2	] {self.weaponframe=1; self.nextthink = time + 0.105;
self.effects = self.effects | EF_MUZZLEFLASH;};
void()	player_sshot2 =	[101, player_sshot3	] {self.weaponframe=2; self.nextthink = time + 0.105;};
void()	player_sshot3 =	[102, player_sshot4	] {self.weaponframe=3; self.nextthink = time + 0.105;};
void()	player_sshot4 =	[103, player_sshot5	] {self.weaponframe=4; self.nextthink = time + 0.105;};
void()	player_sshot5 =	[104, player_sshot6	] {self.weaponframe=5; self.nextthink = time + 0.105;};
void()	player_sshot6 =	[105, player_sshot7	] {self.weaponframe=6; self.nextthink = time + 0.105;};
void()	player_sshot7 =	[106, player_sshot8	] {self.weaponframe=7; self.nextthink = time + 0.105;};
void()	player_sshot8 =	[107, player_sshot9	] {self.weaponframe=8; self.nextthink = time + 0.105;};
void()	player_sshot9 =	[108, player_sshot10	] {self.weaponframe=9; self.nextthink = time + 0.105;};
void()	player_sshot10 =	[109, player_sshot11	] {self.weaponframe=10; self.nextthink = time + 0.105;};
void()	player_sshot11 =	[110, player_run	] {self.weaponframe=11; self.nextthink = time + 0.105;};

void()	player_axe1 =	[87, player_axe2	] {self.weaponframe=1;};
void()	player_axe2 =	[88, player_axe3	] {self.weaponframe=2;};
void()	player_axe3 =	[89, player_axe4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axe4 =	[90, player_axe5	] {self.weaponframe=4;};
void()	player_axe5 =	[91, player_axe6	] {self.weaponframe=5;};
void()	player_axe6 =	[92, player_run	] {self.weaponframe=6;};

//============================================================================

void() plas_cooldown1 = [112 , plas_cooldown2]{self.weaponframe=5; 
sound (self, 5, "weapons/hyperdn.wav", 1, ATTN_NORM);};
void() plas_cooldown2 = [112 , plas_cooldown3] { self.weaponframe=6;};
void() plas_cooldown3 = [113 , plas_cooldown4] { self.weaponframe=7;};
void() plas_cooldown4 = [113 , plas_cooldown5] { self.weaponframe=7;};
void() plas_cooldown5 = [113 , plas_cooldown6] { self.weaponframe=7; 
sound (self, 5, "weapons/hyperup.wav", 1, ATTN_NORM);};
void() plas_cooldown6 = [113 , player_run    ] { self.weaponframe=8;};

void() player_zero_FX = { self.effects = 0; };

void() player_plas1   =[110 , player_plas1   ]
{
	if (!self.button0) 
	{
		player_run(); 
		return;
	}

	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;

	if (mod(self.weaponframe, 2) != 0)
	{
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.frame = 110;
	}
	else 
		self.frame = 111;

	SuperDamageSound();
	W_FirePlasma ();
	self.nextthink = time + 0.2;
};

void() player_nail1   =[110 , player_nail1   ]
{
	if (!self.button0)
	{
		self.weaponframe = 0; 
		player_run (); 
		return;
	}

	self.weaponframe = self.weaponframe + 1;

	if (self.weaponframe == 5)
		self.weaponframe = 1;
	
	if (mod(self.weaponframe, 2) != 0)
	{
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.frame = 110;
	}
	else 
		self.frame = 111;

	SuperDamageSound();
	W_FireMachinegun ();
	self.nextthink = time + 0.09;
};

void() player_chngstop1   =[112 , player_chngstop2   ] {self.weaponframe=26; sound (self, 5, "weapons/chngnd1a.wav", 1, ATTN_NORM);};
void() player_chngstop2   =[112 , player_chngstop3   ] {self.weaponframe=27; };
void() player_chngstop3   =[112 , player_chngstop4   ] {self.weaponframe=28; };
void() player_chngstop4   =[113 , player_chngstop5   ] {self.weaponframe=29; };
void() player_chngstop5   =[113 , player_chngstop6   ] {self.weaponframe=30; };
void() player_chngstop6   =[113 , player_run         ] {self.weaponframe=31; 
	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}
};

// i've gone insane i guess///

float player_chaingunfireframes[] =
{
	0, 1, 0, 0, 0, 5, 0, 0, 8, 0, 0, 11, 0, 13, 0, 15, 0, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0
};

void() player_chngstart1   = [110 , player_chngstart1  ]
{	
	if (!self.button0) 
	{
		player_run(); 
		return;
	}
	
	self.weaponframe = self.weaponframe + 1;
	self.shotcount = self.shotcount + 1;

	if (self.weaponframe > 25)
	{
		self.shotcount = 20;
		self.weaponframe = 20;
	}

	if (mod(self.weaponframe, 2) != 0)
		self.frame = 110;
	else 
		self.frame = 111;

	if(self.weaponframe == player_chaingunfireframes[self.shotcount])
	{	
		W_FireChaingun ();
		SuperDamageSound();
	
		self.effects = self.effects | EF_MUZZLEFLASH;
	}

	if (self.weaponframe == 5)
		sound (self, 5, "weapons/chngnu1a.wav", 1, ATTN_NORM);

	if (self.weaponframe > 14)
		sound (self, 5, "weapons/chngnl1a.wav", 1, ATTN_NORM);
	
	if (self.spinspeed <= 2 && self.weaponframe > 23)
		self.spinspeed += 0.25;

	self.nextthink = time + 0.1;
};

//============================================================================


void() player_rocket1   =[133, player_rocket2  ] {self.weaponframe=1;
self.effects = self.effects | EF_MUZZLEFLASH;};
void() player_rocket2   =[134, player_rocket3  ] {self.weaponframe=2; self.nextthink = time + 0.02;};
void() player_rocket3   =[135, player_rocket4  ] {self.weaponframe=3; self.nextthink = time + 0.102;};
void() player_rocket4   =[136, player_rocket5  ] {self.weaponframe=4; self.nextthink = time + 0.102;};
void() player_rocket5   =[137, player_rocket6  ] {self.weaponframe=5; self.nextthink = time + 0.1;};
void() player_rocket6   =[138, player_run  ] {self.weaponframe=6; self.nextthink = time + 0.1;};
void(float num_bubbles) DeathBubbles;

void() player_bfg1   =[114 , player_bfg2   ] {self.weaponframe=1;self.nextthink = time + 0.105;}
void() player_bfg2   =[115 , player_bfg3   ] {self.weaponframe=2;self.nextthink = time + 0.105;}
void() player_bfg3   =[116 , player_bfg4   ] {self.weaponframe=3;self.nextthink = time + 0.105;}
void() player_bfg4   =[117 , player_bfg5   ] {self.weaponframe=4;self.nextthink = time + 0.105;}
void() player_bfg5   =[118 , player_bfg6   ] {self.weaponframe=5;self.nextthink = time + 0.105;}
void() player_bfg6   =[119 , player_bfg7   ] {self.weaponframe=6;self.nextthink = time + 0.105;}
void() player_bfg7   =[120 , player_bfg8   ] {self.weaponframe=7;self.nextthink = time + 0.105;}
void() player_bfg8   =[121 , player_bfg9   ] {self.weaponframe=8;self.nextthink = time + 0.105;  W_FireBFG();};
void() player_bfg9    =[122 , player_bfg10   ] {self.weaponframe=9;self.nextthink = time + 0.105; self.punchangle_x = -12; };
void() player_bfg10   =[123, player_bfg11   ] {self.weaponframe=10; self.effects = 0; self.nextthink = time + 0.105;};
void() player_bfg11   =[124, player_bfg12   ] {self.weaponframe=11;self.nextthink = time + 0.105; };
void() player_bfg12   =[125, player_bfg13   ] {self.weaponframe=12;self.nextthink = time + 0.105;};
void() player_bfg13   =[126, player_bfg14   ] {self.weaponframe=13;self.nextthink = time + 0.105;};
void() player_bfg14   =[127, player_bfg15   ] {self.weaponframe=14;self.nextthink = time + 0.105;};
void() player_bfg15   =[128, player_bfg16  ] {self.weaponframe=15;self.nextthink = time + 0.05;};
void() player_bfg16   =[129, player_bfg17  ] {self.weaponframe=16;self.nextthink = time + 0.105;};
void() player_bfg17   =[130, player_bfg18  ] {self.weaponframe=17;self.nextthink = time + 0.105;};
void() player_bfg18   =[131, player_bfg19  ] {self.weaponframe=18;self.nextthink = time + 0.105;};
void() player_bfg19   =[132, player_run ] {self.weaponframe=19;self.nextthink = time + 0.105;};

void() PainSound =
{
local float		rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

// water pain sounds
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}

// slime pain sounds
	if (self.watertype == CONTENT_SLIME)
	{
// FIX ME	put in some steam here
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

// ax pain sound
	if (self.axhitme == 1)
	{
		self.axhitme = 0;
		sound (self, CHAN_VOICE, "player/punch.wav", 1, ATTN_NORM);
		return;
	}
	

	rs = rint((random() * 5) + 1);

	self.noise = "";
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	return;
};

void()	player_pain1 =	[	35,	player_pain2	] {PainSound();};
void()	player_pain2 =	[	36,	player_pain3	] {};
void()	player_pain3 =	[	37,	player_pain4	] {};
void()	player_pain4 =	[	38,	player_pain5	] {};
void()	player_pain5 =	[	39,	player_pain6	] {};
void()	player_pain6 =	[	40,	player_run	] 	{};

void()	player_axpain1 =	[	29,	player_axpain2	] {PainSound();};
void()	player_axpain2 =	[	30,	player_axpain3	] {};
void()	player_axpain3 =	[	31,	player_axpain4	] {};
void()	player_axpain4 =	[	32,	player_axpain5	] {};
void()	player_axpain5 =	[	33,	player_axpain6	] {};
void()	player_axpain6 =	[	34,	player_run	] {};

void(entity attacker, float damage) player_pain =
{
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames

	if (self.weapon == IT_AXE)
		player_axpain1 ();
	else
		player_pain1 ();
};

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_die_ax1;

void() DeathBubblesSpawn =
{
local entity	bubble;
	if (self.owner.waterlevel != 3)
		return;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


void() DeathSound =
{
local float		rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
};

void(string gibname, float dm) ThrowHeadClient =
{
	setmodel (self, gibname);
	setsize (self, '-16 -16 -16', '16 16 56');

	self.velocity = self.velocity + VelocityForDamage(dm);
	self.velocity = ClipGibVelocity(self.velocity);
		
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.solid = SOLID_NOT;
	self.avelocity = crandom() * '0 600 0';
	self.origin_z = self.origin_z + 4;
	self.frame = 0;
	self.flags = 0;
};


void() GibPlayer =
{
	ThrowHeadClient ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDie =
{
	stuffcmd(self, "v_cshift 0 0 0 0\n");
	sound (self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
	local	float	i;
	
	self.items = self.items - (self.items & IT_INVISIBILITY);
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = modelindex_player;	// don't use eyes

	if (deathmatch || coop)
		DropBackpack();
	
	self.weaponmodel="";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
	{
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
	
	if (self.weapon == IT_AXE)
	{
		player_die_ax1 ();
		return;
	}
	
	i = cvar("temp1");
	if (!i)
		i = 1 + floor(random()*6);
	
	if (i == 1)
		player_diea1();
	else if (i == 2)
		player_dieb1();
	else
		player_diec1();

};

void() set_suicide_frame =
{	// used by klill command and diconnect command
	if (self.model != "progs/player.mdl")
		return;	// allready gibbed
	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void()	player_diea1	=	[	50,	player_diea2	] {};
void()	player_diea2	=	[	51,	player_diea3	] {};
void()	player_diea3	=	[	52,	player_diea4	] {};
void()	player_diea4	=	[	53,	player_diea5	] {};
void()	player_diea5	=	[	54,	player_diea6	] {};
void()	player_diea6	=	[	55,	player_diea7	] {};
void()	player_diea7	=	[	56,	player_diea8	] {};
void()	player_diea8	=	[	57,	player_diea9	] {};
void()	player_diea9	=	[	58,	player_diea10	] {};
void()	player_diea10	=	[	59,	player_diea11	] {};
void()	player_diea11	=	[	60,	player_diea11 ] {PlayerDead();};

void()	player_dieb1	=	[	61,	player_dieb2	] {};
void()	player_dieb2	=	[	62,	player_dieb3	] {};
void()	player_dieb3	=	[	63,	player_dieb4	] {};
void()	player_dieb4	=	[	64,	player_dieb5	] {};
void()	player_dieb5	=	[	65,	player_dieb6	] {};
void()	player_dieb6	=	[	66,	player_dieb7	] {};
void()	player_dieb7	=	[	67,	player_dieb8	] {};
void()	player_dieb8	=	[	68,	player_dieb9	] {};
void()	player_dieb9	=	[	69,	player_dieb9	] {PlayerDead();};

void()	player_diec1	=	[	70,	player_diec2	] {};
void()	player_diec2	=	[	71,	player_diec3	] {};
void()	player_diec3	=	[	72,	player_diec4	] {};
void()	player_diec4	=	[	73,	player_diec5	] {};
void()	player_diec5	=	[	74,	player_diec6	] {};
void()	player_diec6	=	[	75,	player_diec7	] {};
void()	player_diec7	=	[	76,	player_diec8	] {};
void()	player_diec8	=	[	77,	player_diec9	] {};
void()	player_diec9	=	[	78,	player_diec10	] {};
void()	player_diec10	=	[	79,	player_diec11	] {};
void()	player_diec11	=	[	80,	player_diec12	] {};
void()	player_diec12	=	[	81,	player_diec13	] {};
void()	player_diec13	=	[	82,	player_diec14	] {};
void()	player_diec14	=	[	83,	player_diec15	] {};
void()	player_diec15	=	[	84,	player_diec15 ] {PlayerDead();};

void()	player_die_ax1	=	[	41,	player_die_ax2	] {};
void()	player_die_ax2	=	[	42,	player_die_ax3	] {};
void()	player_die_ax3	=	[	43,	player_die_ax4	] {};
void()	player_die_ax4	=	[	44,	player_die_ax5	] {};
void()	player_die_ax5	=	[	45,	player_die_ax6	] {};
void()	player_die_ax6	=	[	46,	player_die_ax7	] {};
void()	player_die_ax7	=	[	47,	player_die_ax8	] {};
void()	player_die_ax8	=	[	48,	player_die_ax9	] {};
void()	player_die_ax9	=	[	49,	player_die_ax9	] {PlayerDead();};


