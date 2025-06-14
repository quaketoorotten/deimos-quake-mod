/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd id1/models/soldier3
$origin 0 -6 24
$base base		
$skin skin


/*
==============================================================================
SOLDIER CODE
==============================================================================
*/

/*
===========
SoldierCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/

float() SoldierCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
		return FALSE;	
							// don't have a clear shot
// missile attack
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
		chance = 0.9;
	else if (enemy_range == RANGE_CLOSE)
		chance = 0.6;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.4;
	else if (enemy_range == RANGE_MID)
		chance = 0.05;

	if (random () < chance)
	{
		self.th_missile ();
		SUB_AttackFinishedSpecial (self, 1 + 2*random());
		if (random() < 0.3)
			self.lefty = !self.lefty;

		return TRUE;
	}

	return FALSE;
};


void() army_fire;

void()	army_stand1	=[	20,	army_stand2	] {ai_stand();};
void()	army_stand2	=[	21,	army_stand3	] {ai_stand();};
void()	army_stand3	=[	22,	army_stand4	] {ai_stand();};
void()	army_stand4	=[	23,	army_stand5	] {ai_stand();};
void()	army_stand5	=[	24,	army_stand6	] {ai_stand();};
void()	army_stand6	=[	25,	army_stand7	] {ai_stand();};
void()	army_stand7	=[	26,	army_stand8	] {ai_stand();};
void()	army_stand8	=[	27,	army_stand1	] {ai_stand();};

void()	army_walk1	=[	28,	army_walk2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
ai_walk(1);};
void()	army_walk2	=[	29,	army_walk3	] {ai_walk(1);};
void()	army_walk3	=[	30,	army_walk4	] {ai_walk(1);};
void()	army_walk4	=[	31,	army_walk5	] {ai_walk(1);};
void()	army_walk5	=[	32,	army_walk6	] {ai_walk(2);};
void()	army_walk6	=[	33,	army_walk7	] {ai_walk(3);};
void()	army_walk7	=[	34,	army_walk8	] {ai_walk(4);};
void()	army_walk8	=[	35,	army_walk9	] {ai_walk(4);};
void()	army_walk9	=[	36,	army_walk10	] {ai_walk(2);};
void()	army_walk10	=[	37,	army_walk11	] {ai_walk(2);};
void()	army_walk11	=[	38,	army_walk12	] {ai_walk(2);};
void()	army_walk12	=[	39,	army_walk13	] {ai_walk(1);};
void()	army_walk13	=[	40,	army_walk14	] {ai_walk(0);};
void()	army_walk14	=[	41,	army_walk15	] {ai_walk(1);};
void()	army_walk15	=[	42,	army_walk16	] {ai_walk(1);};
void()	army_walk16	=[	43,	army_walk17	] {ai_walk(1);};
void()	army_walk17	=[	44,	army_walk18	] {ai_walk(3);};
void()	army_walk18	=[	45,	army_walk19	] {ai_walk(3);};
void()	army_walk19	=[	46,	army_walk20	] {ai_walk(3);};
void()	army_walk20	=[	47,	army_walk21	] {ai_walk(3);};
void()	army_walk21	=[	48,	army_walk22	] {ai_walk(2);};
void()	army_walk22	=[	49,	army_walk23	] {ai_walk(1);};
void()	army_walk23	=[	50,	army_walk24	] {ai_walk(1);};
void()	army_walk24	=[	51,	army_walk1	] {ai_walk(1);};

void() army_CheckForCharge;

void()	army_run1	=[	52,		army_run2	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "soldier/idle.wav", 1, ATTN_IDLE);
army_CheckForCharge();
ai_run(11);};
void()	army_run2	=[	53,		army_run3	] {ai_run(15);};
void()	army_run3	=[	54,		army_run4	] {ai_run(10);};
void()	army_run4	=[	55,		army_run5	] {ai_run(10);};
void()	army_run5	=[	56,		army_run6	] {ai_run(8);};
void()	army_run6	=[	57,		army_run7	] {ai_run(15);};
void()	army_run7	=[	58,		army_run8	] {ai_run(10);};
void()	army_run8	=[	59,		army_run1	] {ai_run(8);}; 

void()	army_runb1	=[	119,		army_runb2	] {ai_charge(11);};
void()	army_runb2	=[	120,		army_runb3	] {ai_charge(15);};
void()	army_runb3	=[	121,		army_runb4	] {ai_charge(10);};
void()	army_runb4	=[	122,		army_runb5	] {ai_charge(10);};
void()	army_runb5	=[	123,		army_runb6	] {ai_charge(8);};
void()	army_runb6	=[	124,		army_runb7	] {ai_charge(15);};
void()	army_runb7	=[	110,		army_runb8	] {ai_charge(10);};
void()	army_runb8	=[	111,		army_runb9	] {ai_charge(8); army_fire();
self.effects = self.effects | EF_MUZZLEFLASH;}; 
void()	army_runb9	=[	112,		army_runb10	] {ai_charge(11);};
void()	army_runb10	=[	113,		army_runb11	] {ai_charge(15);};
void()	army_runb11	=[	114,		army_runb12	] {ai_charge(10);};
void()	army_runb12	=[	115,		army_runb13	] {ai_charge(10);};
void()	army_runb13	=[	116,		army_runb14	] {ai_charge(8);};
void()	army_runb14	=[	117,		army_runb15	] {ai_charge(15);};
void()	army_runb15	=[	118,		army_run1	] {ai_charge(10); SUB_CheckRefireSpecial (army_runb1); };

void()	army_atk1	=[	0,	army_atk2	] {ai_face();};
void()	army_atk2	=[	1,	army_atk3	] {ai_face();};
void()	army_atk3	=[	2,	army_atk4	] {ai_face();};
void()	army_atk4	=[	3,	army_atk5	] {ai_face();army_fire();
self.effects = self.effects | EF_MUZZLEFLASH;};
void()	army_atk5	=[	4,	army_atk6	] {ai_face();};
void()	army_atk6	=[	5,	army_atk7	] {ai_face();};
void()	army_atk7	=[	6,	army_atk8	] {ai_face();};
void()	army_atk8	=[	7,	army_atk9	] {ai_face();};
void()	army_atk9	=[	8,	army_atk10	] {ai_face();};
void()	army_atk10	=[	9,	army_atk11	] {ai_face();SUB_CheckRefireSpecial (army_atk3);};
void()	army_atk11	=[	10,	army_atk12	] {ai_face();};
void()	army_atk12	=[	11,	army_atk13	] {ai_face();};
void()	army_atk13	=[	13,	army_run1	] {ai_face();};

void()	army_pain1	=[	60,		army_pain2	] {};
void()	army_pain2	=[	61,		army_pain3	] {};
void()	army_pain3	=[	62,		army_pain4	] {};
void()	army_pain4	=[	63,		army_pain5	] {};
void()	army_pain5	=[	64,		army_pain6	] {};
void()	army_pain6	=[	65,		army_run1	] {ai_pain(1);};

void()	army_duckdown1	=[	82,	army_duckdown2	] 
{self.nextthink = self.dspeed; self.maxs_z -= 40; self.takedamage = DAMAGE_YES; };
void()	army_duckdown2	=[	83,	army_duckdown3	] {self.pausetime = time + (random()) % 2 + 0.4;};
void()	army_duckdown3	=[	84,	army_duckdown4	] {};
void()	army_duckdown4	=[	85,	army_duckhold	] {};

void()	army_duckup1	=[	85,	army_duckup2	] 
{self.takedamage = DAMAGE_AIM; self.flags = self.flags - (self.flags & FL_DODGED); self.maxs_z += 40;};
void()	army_duckup2	=[	84,	army_duckup3	] {};
void()	army_duckup3	=[	83,	army_duckup4	] {};
void()	army_duckup4	=[	82,	army_run1	] {};

void() army_duckhold =[	85,	army_duckhold 	]
{	
	if(time > self.pausetime)
		self.think = army_duckup1;
}


void(entity attacker, float damage)	army_pain =
{
	
	local float r;
	r = random();

	if(self.health < self.max_health / 2)
		self.skin = 1;

	if (self.flags & FL_DODGED)
		return;

	if (self.pain_finished > time)
		return;

	if (r < 0.2)
		sound (self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
	else if (r < 0.6)
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "soldier/pain2.wav", 1, ATTN_NORM);

	if (skill == 3)
		return;

	army_pain1 ();
	self.pain_finished = time + 0.6;
};

void() army_fire =
{
	
	local	vector	dir;
	local	entity	en;
	
	ai_face();
	
	sound (self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);	

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;
	
	dir = en.origin - en.velocity*0.2;
	dir = normalize (dir - self.origin);
	
	FireBullets (9, dir, '0.1 0.1 0', 2, 1);
};

void() army_CheckForCharge =
{
// check for mad charge
if (!enemy_vis)
	return;
if (time < self.attack_finished)
	return;	
if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
	return;		// too much height change

if ( vlen (self.origin - self.enemy.origin) < 70)
		return;		// use regular attack

// charge		
	SUB_AttackFinished (self, 3);
	army_runb1 ();

};

void()	army_die1	=[	87,	army_die2	] {sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);};
void()	army_die2	=[	88,	army_die3	] {ai_back(5);};
void()	army_die3	=[	89,	army_die4	]
{ai_back(4); };
void()	army_die4	=[	90,	army_die5	] {ai_back(13); };
void()	army_die5	=[	91,	army_die6	] {ai_back(3); };
void()	army_die6	=[	92,	army_die7	] {ai_back(4); };
void()	army_die7	=[	93,	army_die8	] {};
void()	army_die8	=[	94,	army_die9	] {};
void()	army_die9	=[	95,	army_die10	] {};
void()	army_die10	=[	96,	army_die10	]
{
	self.solid = SOLID_NOT; 
};

void()	army_cdie1	=[	98,	army_cdie2	] 
{
	self.cnt = 1;
	sound (self, CHAN_VOICE, "soldier/death2.wav", 1, ATTN_NORM); 
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NORM); 
	self.nextthink = time + 0.43;
};

void()	army_cdie2	=[	98,	army_cdie3	] {ai_forward(5); };
void()	army_cdie3	=[	99,	army_cdie4	]
{ ai_forward(4);};
void()	army_cdie4	=[	100,	army_cdie5	] {ai_forward(13);};
void()	army_cdie5	=[	101,	army_cdie6	] {ai_forward(3);};
void()	army_cdie6	=[	102,	army_cdie7	] {ai_forward(4);};
void()	army_cdie7	=[	103,	army_cdie8	] {};
void()	army_cdie8	=[	104,	army_cdie9	] {};
void()	army_cdie9	=[	105,	army_cdie10	] {};
void()	army_cdie10	=[	106,	army_cdie11	] {};
void()	army_cdie11	=[	107,	army_cdie11	]
{
	self.solid = SOLID_NOT; 
};


void() army_die =
{	
// if die while dodging remove all dodge related tags
	if(self.flags & FL_DODGED)
	{
		self.maxs_z += 40;
		self.flags = self.flags - (self.flags & FL_DODGED);
	}
	

// check for gib
	if (self.health < -30)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);

		//for(float i = 0; i < 2; i++)
			ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		if(!self.cnt) 
			ThrowHead ("progs/h_guard.mdl", self.health);

		remove(self);
		return;
	}
	
// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	
	if(self.spawnflags & DROP_AMMO)
	{
		if(self.ammo_shells <= 0)
			self.ammo_shells = 3; 

		DropBackpack();
	}

	self.skin = 1;
	self.deadflag = DEAD_DEAD;
		
	local float rnd;
	rnd = mod(random()*100, 2);
	rnd = ceil(rnd);
	
	if (rnd == 1)
		army_cdie1 ();
	else
		army_die1 ();
};


void() army_ranged =
{
	army_atk1 ();
};

/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_army =
{	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/soldier.mdl");
	precache_model ("progs/h_guard.mdl");

	precache_sound ("soldier/death1.wav");
	precache_sound ("soldier/death2.wav");
	precache_sound ("soldier/idle.wav");
	precache_sound ("soldier/pain1.wav");
	precache_sound ("soldier/pain2.wav");
	precache_sound ("soldier/sattck1.wav");
	precache_sound ("soldier/sight1.wav");

	precache_sound ("player/udeath.wav");		// gib death


	spawn_army();
};

void() spawn_army =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/soldier.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 45;
	self.max_health = 45;
	self.mass = 100;
	self.ammo_shells = self.ammo_shells;

	self.th_stand = army_stand1;
	self.th_walk = army_walk1;
	self.th_run = army_run1;
	self.th_missile = army_atk1;
	self.th_pain = army_pain;
	self.th_die = army_die;
	self.th_dodge = army_duckdown1;
	self.th_checkattack = SoldierCheckAttack;
	self.dspeed = 0;
	self.th_spawn = spawn_army;
		
	walkmonster_start();
};
