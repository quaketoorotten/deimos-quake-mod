/*
==============================================================================

SHAMBLER

==============================================================================
*/

$cd id1/models/shams
$origin 0 0 24
$base base		
$skin base

void() boss2_missile1;
void() boss2_laser1


void() boss2_stand1	=[	0,	boss2_stand2	] {ai_stand();};
void() boss2_stand2	=[	1,	boss2_stand3	] {ai_stand();};
void() boss2_stand3	=[	2,	boss2_stand4	] {ai_stand();};
void() boss2_stand4	=[	3,	boss2_stand5	] {ai_stand();};
void() boss2_stand5	=[	4,	boss2_stand6	] {ai_stand();};
void() boss2_stand6	=[	5,	boss2_stand7	] {ai_stand();};
void() boss2_stand7	=[	6,	boss2_stand8	] {ai_stand();};
void() boss2_stand8	=[	7,	boss2_stand9	] {ai_stand();};
void() boss2_stand9	=[	8,	boss2_stand10] {ai_stand();};
void() boss2_stand10	=[	9,	boss2_stand11] {ai_stand();};
void() boss2_stand11	=[	10,	boss2_stand12] {ai_stand();};
void() boss2_stand12	=[	11,	boss2_stand13] {ai_stand();};
void() boss2_stand13	=[	12,	boss2_stand14] {ai_stand();};
void() boss2_stand14	=[	13,	boss2_stand15] {ai_stand();};
void() boss2_stand15	=[	14,	boss2_stand16] {ai_stand();};
void() boss2_stand16	=[	15,	boss2_stand17] {ai_stand();};
void() boss2_stand17	=[	16,	boss2_stand1 ] {ai_stand();};

void() boss2_walk1		=[      17,        boss2_walk2 ] {ai_walk(7);};
void() boss2_walk2       =[      18,        boss2_walk3 ] {ai_walk(8);};
void() boss2_walk3       =[      19,        boss2_walk4 ] {ai_walk(9);};
void() boss2_walk4       =[      20,        boss2_walk5 ] {ai_walk(10);};
void() boss2_walk5       =[      21,        boss2_walk6 ] {ai_walk(11);};
void() boss2_walk6       =[      22,        boss2_walk7 ] {ai_walk(12);};
void() boss2_walk7       =[      23,        boss2_walk8 ] {ai_walk(7); sound (self, CHAN_BODY, "doors/drclos4.wav", 1, ATTN_IDLE);};
void() boss2_walk8       =[      24,        boss2_walk9 ] {ai_walk(8);};
void() boss2_walk9       =[      25,        boss2_walk10] {ai_walk(9);};
void() boss2_walk10      =[      26,        boss2_walk11] {ai_walk(10);};
void() boss2_walk11      =[      27,        boss2_walk12] {ai_walk(11);};
void() boss2_walk12      =[      28,        boss2_walk1 ] {ai_walk(12); sound (self, CHAN_BODY, "doors/drclos4.wav", 1, ATTN_IDLE);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);};


void() boss2_run1		=[      17,        boss2_run2 ] {ai_run(7);};
void() boss2_run2       =[      18,        boss2_run3 ] {ai_run(8);};
void() boss2_run3       =[      19,        boss2_run4 ] {ai_run(9);};
void() boss2_run4       =[      20,        boss2_run5 ] {ai_run(10);};
void() boss2_run5       =[      21,        boss2_run6 ] {ai_run(11);};
void() boss2_run6       =[      22,        boss2_run7 ] {ai_run(12);};
void() boss2_run7       =[      23,        boss2_run8 ] {ai_run(7); sound (self, CHAN_BODY, "doors/drclos4.wav", 1, ATTN_IDLE);};
void() boss2_run8       =[      24,        boss2_run9 ] {ai_run(8);};
void() boss2_run9       =[      25,        boss2_run10] {ai_run(9);};
void() boss2_run10      =[      26,        boss2_run11] {ai_run(10);};
void() boss2_run11      =[      27,        boss2_run12] {ai_run(11);};
void() boss2_run12      =[      28,        boss2_run1 ] {ai_run(12); sound (self, CHAN_BODY, "doors/drclos4.wav", 1, ATTN_IDLE);
if (random() > 0.8)
	sound (self, CHAN_VOICE, "shambler/sidle.wav", 1, ATTN_IDLE);};



//============================================================================



void() CastBFG =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	org = self.origin + v_forward * 20 + v_right * 45.5 + '0 0 42';
	ai_face();
	
	launch_bfgball(normalize((self.enemy.origin + '0 0 16') - org), org);
	
	newmis.dmg = 100;
	newmis.dmg_lsr = 12;
	newmis.dmg_rad = 500;
};

void() CastSSG =
{
	
	local	vector	dir, org;
	local	entity	en;
	
	ai_face();
	self.effects = self.effects | EF_MUZZLEFLASH;

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;
	
	org = self.origin + '0 0 42';
	dir = en.origin - en.velocity*0.1;
	dir = normalize (dir - org);
	
	FireBullets (25, dir, '0.07 0.08 0', 3, 6);

	sound (self, CHAN_VOICE, "weapons/shotgn2.wav", 1, ATTN_NORM);
};

void(float offset) CastLasers =
{
	local	vector	offang;
	local	vector	org, vec;

	offang = vectoangles (self.enemy.origin - self.origin - self.enemy.view_ofs - '0 0 16');
	offang_y = offang_y + offset * 6;
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	makevectors (offang);

	org = self.origin + '0 0 42' + v_forward * 20 + v_right * 45 + v_up *3 ;

	sound (self, CHAN_VOICE, "weapons/hyper.wav", 1, ATTN_NORM);

	// set missile speed
	vec = normalize (v_forward);
	vec_z = 0 - vec_z ;
	
	LaunchLaser(org, vec);
};

void(vector dir, vector org) boss2_launchRocket =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	if(skill <= 1) missile.velocity = normalize(dir)* 800;
	else missile.velocity = normalize(dir)* 900;

	missile.angles = vectoangles(missile.velocity);

	missile.dmg = 90 + random()*35;
	missile.dmg_rad = 128;
	
	missile.touch = T_MissileTouch;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org); 
};

void(float offset) CastRockets =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);
	
	org = self.origin + v_right * 45.5 + '0 0 42' + v_up * 70 + v_right * offset;
	ai_face();

	sound (self, CHAN_VOICE, "weapons/sgun1.wav", 1, ATTN_NORM);
	
	boss2_launchRocket(self.enemy.origin - org + '0 0 16', org);
};


void() boss2_magic1     =[      50,       boss2_magic2    ] {
	sound (self, CHAN_VOICE, "weapons/bfgstart.wav", 1, ATTN_NORM);
};
void() boss2_magic2     =[      51,       boss2_magic3    ] {ai_face();};
void() boss2_magic3     =[      52,       boss2_magic4    ] {ai_face();};
void() boss2_magic4     =[      53,       boss2_magic5    ] {ai_face();};
void() boss2_magic5     =[      54,       boss2_magic6    ] {ai_face();};
void() boss2_magic6     =[      55,       boss2_magic7    ] {ai_face();};																	
void() boss2_magic7     =[      56,       boss2_magic8    ] {CastBFG();};
void() boss2_magic8     =[      57,       boss2_magic9    ] {};
void() boss2_magic9     =[      58,       boss2_magic10    ] {};
void() boss2_magic10     =[      59,       boss2_run1      ] 
{ 
	self.dspeed = 0;
	if (random() > 0.5 && (self.enemy.health > 0))
		boss2_missile1 ();
	else
 		SUB_AttackFinishedSpecial (self, 1 + 2*random() );
};


void() boss2_shotgun1     =[      61,       boss2_shotgun2     ] {
	ai_face();
};
void() boss2_shotgun2    =[      62,       boss2_shotgun3     ] {ai_face();};
void() boss2_shotgun3    =[      63,       boss2_shotgun4     ] {ai_face();};
void() boss2_shotgun4    =[      64,       boss2_shotgun5     ] { CastSSG();};
void() boss2_shotgun5    =[      65,       boss2_shotgun6     ] {};
void() boss2_shotgun6    =[      66,       boss2_shotgun7     ] {};																	
void() boss2_shotgun7    =[      67,       boss2_run1      ] { self.dspeed = self.dspeed + 0.3; SUB_AttackFinishedSpecial (self, 2*random() );};


void() boss2_melee;


void() boss2_CheckContinueLaser =
{
	local entity	targ = self.enemy;
	local vector	spot1 = self.origin + self.view_ofs;
	local	vector	spot2 = targ.origin + targ.view_ofs;

	if (targ.health < 0)
		boss2_run1();

	if (vlen(spot1 - spot2) <= 200)
		boss2_melee();
};

void() boss2_laser1     =[      69,       boss2_laser2    ] {
sound (self, CHAN_VOICE, "shambler/sboom.wav", 1, ATTN_NORM);
ai_face ();
};
void() boss2_laser2     =[      70,       boss2_laser3     ] { ai_face ();};
void() boss2_laser3     =[      71,       boss2_laser4     ] { ai_face ();};
void() boss2_laser4     =[      72,       boss2_laser5     ] { ai_face (); CastLasers(-2); CastLasers(-1.5);};
void() boss2_laser5     =[      73,       boss2_laser6     ] { ai_face (); CastLasers(-1); CastLasers(-0.5);};
void() boss2_laser6     =[      74,       boss2_laser7     ] { ai_face (); CastLasers(0);  CastLasers(0);   };
void() boss2_laser7     =[      75,       boss2_laser8     ] { ai_face (); CastLasers(1);  CastLasers(0.5); };
void() boss2_laser8     =[      76,       boss2_laser9     ] { ai_face (); CastLasers(2);  CastLasers(1.5); };
void() boss2_laser9     =[      77,       boss2_laser10    ] { ai_face (); CastLasers(3);  CastLasers(2.5); boss2_CheckContinueLaser(); };
void() boss2_laser10    =[      76,       boss2_laser11    ] { ai_face (); CastLasers(-2); CastLasers(-1.5);};
void() boss2_laser11    =[      75,       boss2_laser12    ] { ai_face (); CastLasers(-1); CastLasers(-0.5);};
void() boss2_laser12    =[      74,       boss2_laser13    ] { ai_face (); CastLasers(0);  CastLasers(0);   };
void() boss2_laser13    =[      73,       boss2_laser14    ] { ai_face (); CastLasers(1);  CastLasers(0.5); };
void() boss2_laser14    =[      72,       boss2_laser15    ] { ai_face (); CastLasers(2);  CastLasers(1.5); };
void() boss2_laser15    =[      73,       boss2_laser16    ] { ai_face (); CastLasers(-1); CastLasers(-0.5);};
void() boss2_laser16    =[      74,       boss2_laser17    ] { ai_face (); CastLasers(0);  CastLasers(0);   };
void() boss2_laser17    =[      75,       boss2_laser18    ] { ai_face (); CastLasers(1);  CastLasers(0.5); };
void() boss2_laser18    =[      76,       boss2_laser19    ] { ai_face (); CastLasers(2);  CastLasers(1.5); };
void() boss2_laser19    =[      77,       boss2_laser20    ] { ai_face (); CastLasers(3);  CastLasers(2.5);boss2_CheckContinueLaser(); };
void() boss2_laser20    =[      78,       boss2_laser21    ] { ai_face (); };
void() boss2_laser21    =[      79,       boss2_run1       ] { ai_face ();  self.dspeed = self.dspeed + 0.6; SUB_AttackFinishedSpecial (self, 2*random() ); };


void() boss2_kick1	=[      81,     boss2_kick2]{
	sound (self, CHAN_VOICE, "shambler/melee1.wav", 1, ATTN_NORM);
	ai_charge(1);
};
void() boss2_kick2=[      82,     boss2_kick3] {ai_charge(8);};
void() boss2_kick3=[      83,     boss2_kick4] {ai_charge(14);};
void() boss2_kick4=[      84,     boss2_kick5] {ai_charge(7);};
void() boss2_kick5=[      85,     boss2_kick6] {ai_charge(3); shamkick (); };
void() boss2_kick6=[      86,     boss2_kick7] {ai_charge(6);};
void() boss2_kick7=[      87,     boss2_kick8] {ai_charge(6);};
void() boss2_kick8=[      88,     boss2_kick9] {ai_charge(3);};
void() boss2_kick9=[      89,     boss2_kick10] {ai_charge(3); };
void() boss2_kick10=[      90,   boss2_run1      ] {ai_charge(1); self.dspeed = self.dspeed + 0.3;
if (random() > 0.5 && (self.enemy.health > 0))
		boss2_missile1 (); };


void() boss2_missile1	=[      91,     boss2_missile2]{ ai_face ();
	sound (self, CHAN_VOICE, "shambler/sboom.wav", 1, ATTN_NORM);
};
void() boss2_missile2=[      92,     boss2_missile3] { ai_face ();};
void() boss2_missile3=[      93,     boss2_missile4] {ai_face ();};
void() boss2_missile4=[      94,     boss2_missile5] {ai_face ();};
void() boss2_missile5=[      95,     boss2_missile6] {CastRockets(-12); };
void() boss2_missile6=[      96,     boss2_missile7] {ai_face ();};
void() boss2_missile7=[      97,     boss2_missile8] {ai_face ();};
void() boss2_missile8=[      98,     boss2_missile9] {CastRockets(0);};
void() boss2_missile9=[      99,     boss2_missile10] {ai_face (); };
void() boss2_missile10=[      100,   boss2_missile11] {ai_face ();  };
void() boss2_missile11=[      101,   boss2_missile12] {CastRockets(12);  };
void() boss2_missile12=[      102,   boss2_missile13] {ai_face ();  };
void() boss2_missile13=[      103,   boss2_missile14] {ai_face ();  };
void() boss2_missile14=[      104,   boss2_run1      ] {ai_face (); self.dspeed = self.dspeed + 0.3; SUB_AttackFinishedSpecial (self, 2*random() ); };


void() boss2_melee =
{
	local float chance;
	chance = random();	
	local entity	targ;
	
	targ = self.enemy;
	
	if(self.dspeed >= 1)
		boss2_magic1();

	else if ( fabs(self.origin_z - targ.origin_z) < 20)
	{
		if(((targ.flags & FL_ONGROUND) && !(targ.flags & FL_FLY)) && (random() < 0.5))
			boss2_kick1();
		else
			boss2_shotgun1();
	}
	else
		boss2_shotgun1();
};		
	

void() boss2_ranged = 
{
	local vector	spot1, spot2;	
	local entity	targ;
	
	targ = self.enemy;
	
	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	
	if(self.dspeed >= 1)
		boss2_magic1();
	else if (vlen(spot1 - spot2) <= 200)
		boss2_melee();
	else if (random() < 0.5)
		boss2_laser1();
	else
		boss2_missile1();

};

void() boss2_pain1      =[      42, 	boss2_pain2      ] {};
void() boss2_pain2      =[      43, 	boss2_pain3      ] {};
void() boss2_pain3      =[      44, 	boss2_pain4      ] {};
void() boss2_pain4      =[      45, 	boss2_pain5      ] {};
void() boss2_pain5      =[      46, 	boss2_pain6      ] {};
void() boss2_pain6      =[      47, 	boss2_pain7      ] {};
void() boss2_pain7      =[      48, 	boss2_run1       ] {};


void(entity attacker, float damage)	boss2_pain =
{
	if(self.health < self.max_health / 2)
		self.skin = 1;

	if (self.health <= 0)
		return;		// allready dying, don't go into pain frame

	if (random()*7200 > damage)
		return;		// didn't flinch
	
	if (self.pain_finished > time)
		return;
	sound (self, CHAN_VOICE, "shambler/shurt2.wav", 1, ATTN_NORM);
	self.pain_finished = time + 1.25;
		
	boss2_pain1 ();
	self.effects = 0;
};


//============================================================================

void() boss2_gibs = 
{	
	sound (self, CHAN_BODY, "player/udeath.wav", 1, ATTN_NORM);
	ThrowHeadBoss ("progs/h_shams.mdl", -100);

	for(float i = 0; i < 4; i++)
		ThrowGibBoss ("progs/gib1_green.mdl", -400);

	ThrowGibBoss ("progs/gib2_green.mdl", -400);

	for(float i = 0; i < 8; i++)
		ThrowGibBoss ("progs/gib3_green.mdl", -400);
};


void(float offset, float offsetheight, vector org) boss2_explosion =
{
	local vector exporg;
	makevectors(self.angles);
	
	newmis = spawn();

	exporg = org + v_right * offset + v_up * offsetheight;
	setorigin(newmis, exporg);

	newmis.think = BecomeExplosion;
	newmis.nextthink = time;	

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, newmis.origin_x);
	WriteCoord (MSG_BROADCAST, newmis.origin_y);
	WriteCoord (MSG_BROADCAST, newmis.origin_z);
};

void() boss2_death6;

void() boss2_death1      =[      107,       boss2_death2     ] {self.ltime = time + 1.2;};
void() boss2_death2      =[      106,       boss2_death3     ] {};
void() boss2_death3      =[      108,       boss2_death4     ] {if(time > self.ltime) boss2_death6();};
void() boss2_death4      =[      109,       boss2_death5     ] {};
void() boss2_death5      =[      110,       boss2_death2     ] {if(time > self.ltime) boss2_death6();};
void() boss2_death6      =[      107,       boss2_death7     ] 
{
	boss2_explosion(-50.5, 60, self.origin); 
	newmis.cnt = 1;
};
void() boss2_death7      =[      106,       boss2_death9     ] 
{
	boss2_explosion(50.5, 90, self.origin); 
	newmis.cnt = 1;
};
void() boss2_death9      =[      108,       boss2_death10     ] 
{
	boss2_explosion(-20.5, 30, self.origin); 
	newmis.cnt = 1;
};
void() boss2_death10      =[      109,       boss2_death11     ] 
{
	boss2_explosion(-30.5, 120, self.origin); 
	newmis.cnt = 1;
};
void() boss2_death11     =[      110,       boss2_death12     ] 
{
	boss2_explosion(30.5, 60, self.origin); 
	newmis.cnt = 1;
};
void() boss2_death12     =[      111,       boss2_death13     ] 
{
	boss2_explosion(-50.5, 60, self.origin); 
};
void() boss2_death13     =[      112,       boss2_death14     ] 
{
	boss2_explosion(40.5, 90, self.origin); 
	boss2_gibs();
	setmodel (self, "progs/boss2_legs.mdl");
	setsize (self,VEC_HULL2_MIN, VEC_HULL2_MAX);
};
void() boss2_death14     =[      113,       boss2_death15     ] 
{
	boss2_explosion(-1.5, 140, self.origin); self.takedamage = DAMAGE_YES; self.color =233;
};

void() boss2_death15     =[      114,       boss2_death15     ]{ };


void() boss2_die =
{
	// check for gib
	if (self.health < -9999)
	{
		boss2_explosion(-30.5, 30, self.origin); 
		boss2_explosion(50.5, 20, self.origin); newmis.cnt = 1;
		boss2_explosion(-20.5, 10, self.origin); newmis.cnt = 1;
		remove(self);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	makevectors(self.angles);
	sound (self, CHAN_VOICE, "boss2/death1.wav", 0.8, ATTN_NORM);
	self.effects = 0;
	self.takedamage = DAMAGE_NO;
	self.movetype = MOVETYPE_TOSS;
	self.skin = 0;
	boss2_death1 ();
	self.deadflag = DEAD_DEAD;
};

//============================================================================


/*QUAKED monster_boss2 (1 0 0) (-42 -42 -24) (42 42 88) Ambush
*/
void() monster_boss2 =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/boss2.mdl");
	precache_model ("progs/boss2_legs.mdl");
	precache_model ("progs/h_shams.mdl");
	
	precache_sound ("shambler/sattck1.wav");
	precache_sound ("shambler/sboom.wav");
	precache_sound ("boss2/death1.wav");
	precache_sound ("shambler/shurt2.wav");
	precache_sound ("shambler/sidle.wav");
	precache_sound ("boss2/ssight.wav");
	precache_sound ("shambler/melee1.wav");
	precache_sound ("shambler/melee2.wav");
	precache_sound ("shambler/smack.wav");
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
	precache_sound ("doors/drclos4.wav");

	spawn_boss2();
};

void() spawn_boss2 =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, "progs/boss2.mdl");

	setsize (self,VEC_HULL2_MIN, VEC_HULL2_MAX);
	self.health = 7200;
	self.max_health = 7200;
	self.mass = 4000;
	self.skin = 0;
	self.dspeed = 0;
	self.color = 58;

	self.th_stand = boss2_stand1;
	self.th_walk = boss2_walk1;
	self.th_run = boss2_run1;
	self.th_die = boss2_die;
	self.th_melee = boss2_melee;
	self.th_missile = boss2_ranged;
	self.th_pain = boss2_pain;
	self.th_spawn = spawn_boss2;
	
	walkmonster_start ();
}
