/*
==============================================================================

KNIGHT

==============================================================================
*/

$cd id1/models/knight2
$origin 0 0 24
$base base
$skin skin

void() hknight_char1;
void() hknight_run1;
void() hk_idle_sound;

void() hknight_MissileHome =
{
	local vector	dir, vtemp;
	local entity 	targ = self.enemy;

	vtemp = targ.origin + targ.view_ofs;
	
	if (time > self.ltime)
	{
		setmodel (self, "progs/k_spike.mdl");
		setsize (self, VEC_ORIGIN, VEC_ORIGIN);		
		setorigin (self, self.origin);
		newmis.nextthink = 6 + time;
		newmis.think = SUB_Remove;
		return;
	}
	if (self.enemy.health < 1)
	{
		remove(self);
		return;
	}
	dir = normalize(vtemp - self.origin);
	
	self.velocity = dir * 300;

	self.angles = vectoangles(self.velocity);
	self.nextthink = time + 0.23;
	self.think = hknight_MissileHome;	
};

void(vector org, vector dir) launch_hknightMissile=
{
	local float 	flytime;
	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;

	flytime = vlen(dir) * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	newmis.angles = vectoangles(dir);
	
	if(random() < 0.3)
	{
		newmis.ltime = time + 2.5;
		newmis.nextthink = flytime + time;
		newmis.think = hknight_MissileHome;
		newmis.enemy = self.enemy;
		newmis.touch = Laser_Touch;
		setmodel (newmis, "progs/k_homspike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
		setorigin (newmis, org);
	}
	else
	{
		setmodel (newmis, "progs/k_spike.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
		setorigin (newmis, org);
		newmis.nextthink = 6 + time;
		newmis.think = SUB_Remove;
	}

	newmis.velocity = dir * 300;

	newmis.touch = spike_touch;
};

void(float offset) hknight_shot =
{
	local	vector	org, dir;
	local entity	targ = self.enemy;
	local vector	targorg = targ.origin + targ.view_ofs;
	
	makevectors (self.angles);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	org = self.origin + '0 0 42' + v_right * offset;
	dir = normalize (targorg - org);
	
	launch_hknightMissile (org, dir);
	newmis.classname = "knightspike";

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
};

void() hknight_CheckForCharge =
{
// check for mad charge
if (!enemy_vis)
	return;
if (time < self.attack_finished)
	return;	
if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
	return;		// too much height change

if ( vlen (self.origin - self.enemy.origin) < 80)
		return;		// use regular attack

// charge		
	SUB_AttackFinished (self, 1);
	hknight_char1 ();

};

void() hknight_CheckContinueCharge =
{
	if (time > self.attack_finished)
	{
		SUB_AttackFinished (self, 3);
		hknight_run1 ();
		return;		// done charging
	}
	if (random() > 0.5)
		sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
};

void() hknight_slice =
{
	local vector	delta;
	local float 	ldmg;

	if (!self.enemy)
		return;		// removed before stroke
		
	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 80)
		return;
		
	ldmg = (random() + random() + random()) * 6;
	T_Damage (self.enemy, self, self, ldmg, 2);
	sound (self, CHAN_VOICE, "demon/dhit2.wav", 1, ATTN_NORM);
};


void(float uppercut) hknightpunch =
{
local vector	delta;
local float 	ldmg, kick;

	if (!self.enemy)
		return;
	ai_charge(0);
	kick = 20;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)	
		return;

	if (!CanDamage (self.enemy, self))
		return;
		
	ldmg = 20 + (random() + random() + random()) * 5;

	if(uppercut == 1)
	{
		kick = 200;
		self.enemy.origin_z = self.enemy.origin_z + 30;
		self.enemy.velocity_z = 400;

		if(!(self.enemy.movetype & MOVETYPE_WALK))
			self.enemy.flags = self.enemy.flags - (self.enemy.flags & FL_ONGROUND);
	}
	T_Damage (self.enemy, self, self, ldmg, kick);
	sound (self, CHAN_VOICE, "demon/dhit2.wav", 1, ATTN_NORM);

};

//===========================================================================

void()	hknight_stand1	=[	0,	hknight_stand2	] {ai_stand();};
void()	hknight_stand2	=[	1,	hknight_stand3	] {ai_stand();};
void()	hknight_stand3	=[	3,	hknight_stand4	] {ai_stand();};
void()	hknight_stand4	=[	4,	hknight_stand5	] {ai_stand();};
void()	hknight_stand5	=[	5,	hknight_stand6	] {ai_stand();};
void()	hknight_stand6	=[	6,	hknight_stand7	] {ai_stand();};
void()	hknight_stand7	=[	7,	hknight_stand8	] {ai_stand();};
void()	hknight_stand8	=[	8,	hknight_stand9	] {ai_stand();};
void()	hknight_stand9	=[	9,	hknight_stand1	] {ai_stand();};

//===========================================================================

void()	hknight_walk1	=[	10,		hknight_walk2	] {
hk_idle_sound();
ai_walk(2);};
void()	hknight_walk2	=[	11,		hknight_walk3	] {ai_walk(5);};
void()	hknight_walk3	=[	12,		hknight_walk4	] {ai_walk(5);};
void()	hknight_walk4	=[	13,		hknight_walk5	] {ai_walk(4);};
void()	hknight_walk5	=[	14,		hknight_walk6	] {ai_walk(4);};
void()	hknight_walk6	=[	15,		hknight_walk7	] {ai_walk(2);};
void()	hknight_walk7	=[	17,		hknight_walk8	] {ai_walk(2);};
void()	hknight_walk8	=[	18,		hknight_walk9	] {ai_walk(3);};
void()	hknight_walk9	=[	19,		hknight_walk10	] {ai_walk(3);};
void()	hknight_walk10	=[	20,	hknight_walk11	] {ai_walk(4);};
void()	hknight_walk11	=[	21,	hknight_walk12	] {ai_walk(3);};
void()	hknight_walk12	=[	22,	hknight_walk13	] {ai_walk(4);};
void()	hknight_walk13	=[	23,	hknight_walk14	] {ai_walk(6);};
void()	hknight_walk14	=[	24,	hknight_walk15	] {ai_walk(2);};
void()	hknight_walk15	=[	25,	hknight_walk16	] {ai_walk(2);};
void()	hknight_walk16	=[	26,	hknight_walk17	] {ai_walk(4);};
void()	hknight_walk17	=[	27,	hknight_walk18	] {ai_walk(3);};
void()	hknight_walk18	=[	28,	hknight_walk19	] {ai_walk(3);};
void()	hknight_walk19	=[	29,	hknight_walk1	] {ai_walk(3);};

//===========================================================================

void()	hknight_run1	=[	30,		hknight_run2	] {
hk_idle_sound();
ai_run (20); if(random() < 0.6) hknight_CheckForCharge (); };
void()	hknight_run2	=[	31,		hknight_run3	] {ai_run(25);};
void()	hknight_run3	=[	32,		hknight_run4	] {ai_run(18);};
void()	hknight_run4	=[	33,		hknight_run5	] {ai_run(16);};
void()	hknight_run5	=[	34,		hknight_run6	] {ai_run(14);};
void()	hknight_run6	=[	35,		hknight_run7	] {ai_run(25);};
void()	hknight_run7	=[	36,		hknight_run8	] {ai_run(21);};
void()	hknight_run8	=[	37,		hknight_run1	] {ai_run(13);};

//============================================================================

void()	hknight_pain1	=[	38,		hknight_pain2	] {sound (self, CHAN_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);};
void()	hknight_pain2	=[	39,		hknight_pain3	] {};
void()	hknight_pain3	=[	40,		hknight_pain4	] {};
void()	hknight_pain4	=[	41,		hknight_pain5	] {};
void()	hknight_pain5	=[	42,		hknight_run1	] {};

//============================================================================

void()	hknight_die1	=[	99,	hknight_die2	] {};
void()	hknight_die2	=[	100,	hknight_die3	] {};
void()	hknight_die3	=[	101,	hknight_die4	]
{ ai_back(7);};
void()	hknight_die4	=[	102,	hknight_die5	] {};
void()	hknight_die5	=[	103,	hknight_die6	] {};
void()	hknight_die6	=[	104,	hknight_die7	] {ai_back(10);};
void()	hknight_die7	=[	105,	hknight_die8	] {ai_back(10);};
void()	hknight_die8	=[	106,	hknight_die9	] {ai_back(10);};
void()	hknight_die9	=[	107,	hknight_die10	] {};
void()	hknight_die10	=[	108,	hknight_die11	] {};
void()	hknight_die11	=[	109,	hknight_die12	] {};
void()	hknight_die12	=[	110,	hknight_die12	] 
{	
	self.solid = SOLID_NOT; 
};


void() hknight_die =
{
// check for gib
	if (self.health < -60)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_hellkn.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		remove(self);
		return;
	}
	
	// don't die a regular death again as corpse
	if((self.deadflag & DEAD_DEAD))
		return;

// regular death
	sound (self, CHAN_VOICE, "hknight/death1.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	self.skin = 1;
	hknight_die1 ();
	self.deadflag = DEAD_DEAD;
};


//============================================================================

void()	hknight_magica1 =[	91,	hknight_magica2	] {ai_face(); self.cnt ++; sound (self, CHAN_VOICE, "hknight/attack1.wav", 1, ATTN_NORM);};
void()	hknight_magica2 =[	92,	hknight_magica3	] {ai_face();hknight_shot(-20);};
void()	hknight_magica3 =[	93,	hknight_magica4	] {ai_face();};
void()	hknight_magica4 =[	94,	hknight_magica5	] {ai_face();};
void()	hknight_magica5 =[	95,	hknight_magica6	] {ai_face();hknight_shot(20);};
void()	hknight_magica6 =[	96,	hknight_magica7	] {ai_face();};
void()	hknight_magica7 =[	97,	hknight_run1	] 
{
	if (random() < 0.6 && self.cnt <= 3)
		SUB_CheckRefireSpecial (hknight_magica1);
	else
		SUB_AttackFinished (self, 3);
};

//===========================================================================

void()	hknight_char1	=[	43,	hknight_char2	] { ai_charge(30); sound (self, CHAN_VOICE, "knight/sword2.wav", 1, ATTN_NORM);};
void()	hknight_char2	=[	44,	hknight_char3	] {ai_charge(35); hknight_slice();};
void()	hknight_char3	=[	45,	hknight_char4	] {ai_charge(28); hknight_slice();};
void()	hknight_char4	=[	46,	hknight_char5	] {ai_charge(26); hknight_slice();};
void()	hknight_char5	=[	47,	hknight_char6	] {ai_charge(24); hknight_slice();};
void()	hknight_char6	=[	48,	hknight_char7	] {ai_charge(30);};
void()	hknight_char7	=[	49,	hknight_char8	] {ai_charge(31);}
void()	hknight_char8	=[	50,	hknight_char9	] { ai_charge(33); hknight_CheckContinueCharge (); };
void()	hknight_char9	=[	51,	hknight_char10	] {ai_charge(27);  hknight_slice();};
void()	hknight_char10	=[	52,	hknight_char11	] {ai_charge(22);  hknight_slice();};
void()	hknight_char11	=[	53,	hknight_char12	] {ai_charge(22);  hknight_slice();};
void()	hknight_char12	=[	54,	hknight_char13	] {ai_charge(28);  hknight_slice();};
void()	hknight_char13	=[	55,	hknight_char14	] {ai_charge(18);  hknight_slice();};
void()	hknight_char14	=[	56,	hknight_char15	] {ai_charge(18); };
void()	hknight_char15	=[	57,	hknight_char16	] {ai_charge(18); };
void()	hknight_char16	=[	58,	hknight_char1	] {ai_charge(18); hknight_CheckContinueCharge (); };

//===========================================================================

void()	hknight_slice1	=[	59,	hknight_slice2	] {ai_charge(9); sound (self, CHAN_VOICE, "knight/sword1.wav", 1, ATTN_NORM);};
void()	hknight_slice2	=[	60,	hknight_slice3	] {ai_charge(6);};
void()	hknight_slice3	=[	61,	hknight_slice4	] {ai_charge(13);};
void()	hknight_slice4	=[	62,	hknight_slice5	] {ai_charge(4);};
void()	hknight_slice5	=[	63,	hknight_slice6	] {ai_charge(7);  hknight_slice();};
void()	hknight_slice6	=[	64,	hknight_slice7	] {ai_charge(15);  hknight_slice();};
void()	hknight_slice7	=[	65,	hknight_slice8	] {ai_charge(8);  hknight_slice();};
void()	hknight_slice8	=[	66,	hknight_slice9	] {ai_charge(2);  hknight_slice();};
void()	hknight_slice9	=[	67,	hknight_slice10	] {ai_charge(2);};
void()	hknight_slice10	=[	68,	hknight_slice11	] {ai_charge(3);};
void()	hknight_slice11	=[	69,	hknight_slice12	] {ai_charge(3);};
void()	hknight_slice12	=[	70,	hknight_run1	] {ai_charge(3);};

//===========================================================================

void()	hknight_smasha1	=[	72,	hknight_smasha2	] {ai_face(); sound (self, CHAN_VOICE, "hknight/attack1.wav", 1, ATTN_NORM);};
void()	hknight_smasha2	=[	73,	hknight_smasha3	] {ai_face();};
void()	hknight_smasha3	=[	74,	hknight_smasha4	] {ai_face();};
void()	hknight_smasha4	=[	75,	hknight_smasha5	] {ai_face(); hknightpunch(1);};
void()	hknight_smasha5	=[	76,	hknight_smasha6	] {};
void()	hknight_smasha6	=[	77,	hknight_smasha7	] {};
void()	hknight_smasha7	=[	78,	hknight_smasha8	] {};
void()	hknight_smasha8	=[	79,	hknight_run1	] {};

void()	hknight_smashb1	=[	81,	hknight_smashb2	] {ai_face(); sound (self, CHAN_VOICE, "hknight/grunt.wav", 1, ATTN_NORM);};
void()	hknight_smashb2	=[	82,	hknight_smashb3	] {ai_face();};
void()	hknight_smashb3	=[	83,	hknight_smashb4	] {ai_face();};
void()	hknight_smashb4	=[	84,	hknight_smashb5	] {ai_face();hknightpunch(0);};
void()	hknight_smashb5	=[	85,	hknight_smashb6	] {ai_face();};
void()	hknight_smashb6	=[	86,	hknight_smashb7	] {ai_face();};
void()	hknight_smashb7	=[	87,	hknight_smashb8	] {ai_face();};
void()	hknight_smashb8	=[	88,	hknight_smashb9	] {ai_face();};
void()	hknight_smashb9	=[	89,	hknight_run1	] {ai_face();};

//============================================================================

void() hk_idle_sound =
{
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "hknight/idle.wav", 1, ATTN_NORM);
};

void(entity attacker, float damage)	hknight_pain =
{
	if(self.health < self.max_health / 2)
		self.skin = 1;

	if (self.pain_finished > time)
		return;
	
	sound (self, CHAN_VOICE, "hknight/pain1.wav", 1, ATTN_NORM);
	if (time - self.pain_finished > 6 && skill != 3)
	{	// allways go into pain frame if it has been a while
		hknight_pain1 ();
		self.pain_finished = time + 1;
		return;
	}
	
	if ((random()*30 > damage) )
		return;		// didn't flinch

	if (skill == 3)
		return;

	hknight_pain1 ();
	self.pain_finished = time + 1;
};

float	hknight_type;

void() hknight_melee =
{
	hknight_type = hknight_type + 1;

	if (hknight_type == 1)
		hknight_slice1 ();
	else if (hknight_type == 2)
		hknight_smashb1 ();
	else 
	{
		hknight_smasha1 ();
		hknight_type = 0;
	}
};

/*QUAKED monster_hell_knight (1 0 0) (-16 -16 -24) (16 16 64) Ambush
*/
void() monster_hell_knight =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/hknight.mdl");
	precache_model2 ("progs/k_spike.mdl");
	precache_model2 ("progs/k_homspike.mdl");
	precache_model2 ("progs/h_hellkn.mdl");

	
	precache_sound2 ("hknight/attack1.wav");
	precache_sound2 ("hknight/death1.wav");
	precache_sound2 ("hknight/pain1.wav");
	precache_sound2 ("hknight/sight1.wav");
	precache_sound2 ("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2 ("hknight/slash1.wav");
	precache_sound2 ("demon/dhit2.wav");
	precache_sound2 ("hknight/idle.wav");
	precache_sound2 ("hknight/grunt.wav");

	precache_sound2 ("knight/sword1.wav");
	precache_sound2 ("knight/sword2.wav");
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/hknight.mdl");

	setsize (self, VEC_HULL3_MIN, VEC_HULL3_MAX);
	self.health = 425;
	self.max_health = 425;
	self.mass = 300;
	self.skin = 0;

	self.th_stand = hknight_stand1;
	self.th_walk = hknight_walk1;
	self.th_run = hknight_run1;
	self.th_melee = hknight_melee;
	self.th_missile = hknight_magica1;
	self.th_pain = hknight_pain;
	self.th_die = hknight_die;
	
	walkmonster_start ();
};
