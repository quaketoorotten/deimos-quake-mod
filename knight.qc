$cd id1/models/knight
$origin 0 0 24
$base base
$skin badass3

void()	knight_stand1	=[	0,	knight_stand2	] {ai_stand();};
void()	knight_stand2	=[	1,	knight_stand3	] {ai_stand();};
void()	knight_stand3	=[	2,	knight_stand4	] {ai_stand();};
void()	knight_stand4	=[	3,	knight_stand5	] {ai_stand();};
void()	knight_stand5	=[	4,	knight_stand6	] {ai_stand();};
void()	knight_stand6	=[	5,	knight_stand7	] {ai_stand();};
void()	knight_stand7	=[	6,	knight_stand8	] {ai_stand();};
void()	knight_stand8	=[	7,	knight_stand9	] {ai_stand();};
void()	knight_stand9	=[	8,	knight_stand1	] {ai_stand();};

void()	knight_walk1	=[	53,		knight_walk2	] {
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);

	ai_walk(3);
};

void()	knight_walk2	=[	54,		knight_walk3	] {ai_walk(2);};
void()	knight_walk3	=[	55,		knight_walk4	] {ai_walk(3);};
void()	knight_walk4	=[	56,		knight_walk5	] {ai_walk(4);};
void()	knight_walk5	=[	57,		knight_walk6	] {ai_walk(3);};
void()	knight_walk6	=[	58,		knight_walk7	] {ai_walk(3);};
void()	knight_walk7	=[	59,		knight_walk8	] {ai_walk(3);};
void()	knight_walk8	=[	60,		knight_walk9	] {ai_walk(4);};
void()	knight_walk9	=[	61,		knight_walk10	] {ai_walk(3);};
void()	knight_walk10	=[	62,	knight_walk11	] {ai_walk(3);};
void()	knight_walk11	=[	63,	knight_walk12	] {ai_walk(2);};
void()	knight_walk12	=[	64,	knight_walk13	] {ai_walk(3);};
void()	knight_walk13	=[	65,	knight_walk14	] {ai_walk(4);};
void()	knight_walk14	=[	66,	knight_walk1	] {ai_walk(3);};

void()	knight_run1	=[	9,		knight_run2	] {
	if (random() < 0.2)
		sound (self, CHAN_VOICE, "knight/idle.wav", 1,  ATTN_IDLE);

	ai_run(26);
};

void()	knight_run2	=[	10,		knight_run3	] {ai_run(18);};
void()	knight_run3	=[	11,		knight_run4	] {ai_run(21);};
void()	knight_run4	=[	12,		knight_run5	] {ai_run(25);};
void()	knight_run5	=[	13,		knight_run6	] {ai_run(24);};
void()	knight_run6	=[	14,		knight_run7	] {ai_run(18);};
void()	knight_run7	=[	15,		knight_run8	] {ai_run(22);};
void()	knight_run8	=[	16,		knight_run1	] {ai_run(24);};

void()	knight_runatk1	=[	17,		knight_runatk2	] {
	if (random() > 0.5)
		sound (self, CHAN_WEAPON, "knight/sword2.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);

	ai_charge(20);
};

void()	knight_runatk2	=[	18,	knight_runatk3	] {ai_charge_side();};
void()	knight_runatk3	=[	19,	knight_runatk4	] {ai_charge_side();};
void()	knight_runatk4	=[	20,	knight_runatk5	] {ai_charge_side();};
void()	knight_runatk5	=[	21,	knight_runatk6	] {ai_melee_side();};
void()	knight_runatk6	=[	23,	knight_runatk7	] {ai_melee_side();};
void()	knight_runatk7	=[	24,	knight_runatk8	] {ai_melee_side();};
void()	knight_runatk8	=[	25,	knight_runatk9	] {ai_melee_side();};
void()	knight_runatk9	=[	26,	knight_runatk10	] {ai_melee_side();};
void()	knight_runatk10	=[	27,	knight_run1	] {ai_charge_side();};

void()	knight_atk1	=[	43,		knight_atk2	] {
	sound (self, CHAN_WEAPON, "knight/sword1.wav", 1, ATTN_NORM);
	ai_charge(0);
};

void()	knight_atk2	=[	44,		knight_atk3	] {ai_charge(7);};
void()	knight_atk3	=[	45,		knight_atk4	] {ai_charge(4);};
void()	knight_atk4	=[	46,		knight_atk5	] {ai_charge(0);};
void()	knight_atk5	=[	47,		knight_atk6	] {ai_charge(3);};
void()	knight_atk6	=[	48,		knight_atk7	] {ai_charge(4); ai_melee();};
void()	knight_atk7	=[	49,		knight_atk8	] {ai_charge(1); ai_melee();};
void()	knight_atk8	=[	50,		knight_atk9	] {ai_charge(3); ai_melee();};
void()	knight_atk9	=[	51,		knight_atk10] {ai_charge(1);};
void()	knight_atk10	=[	52,		knight_run1	] {ai_charge(5);};

//===========================================================================

void()	knight_pain1	=[	28,		knight_pain2	] {};
void()	knight_pain2	=[	29,		knight_pain3	] {};
void()	knight_pain3	=[	30,		knight_run1	] {};

void()	knight_painb1	=[	31,	knight_painb2	] {ai_painforward(0);};
void()	knight_painb2	=[	32,	knight_painb3	] {ai_painforward(3);};
void()	knight_painb3	=[	33,	knight_painb4	] {};
void()	knight_painb4	=[	34,	knight_painb5	] {};
void()	knight_painb5	=[	35,	knight_painb6	] {ai_painforward(2);};
void()	knight_painb6	=[	36,	knight_painb7	] {ai_painforward(4);};
void()	knight_painb7	=[	37,	knight_painb8	] {ai_painforward(2);};
void()	knight_painb8	=[	38,	knight_painb9	] {ai_painforward(5);};
void()	knight_painb9	=[	39,	knight_painb10	] {ai_painforward(5);};
void()	knight_painb10	=[	40,	knight_painb11	] {ai_painforward(0);};
void()	knight_painb11	=[	41,	knight_run1	] {};

void(entity attacker, float damage)	knight_pain =
{
	local float r;

	if(self.health < self.max_health / 2)
		self.skin = 1;
	
	if (self.pain_finished > time)
		return;

	r = random();
	
	sound (self, CHAN_VOICE, "knight/khurt.wav", 1, ATTN_NORM);
	self.pain_finished = time + 1;

	if (skill == 3)
		return;
	
	if (r < 0.85)
		knight_pain1 ();
	else
		knight_painb1 ();
};

//===========================================================================


void()	knight_die1	=[	67,	knight_die2	] {};
void()	knight_die2	=[	68,	knight_die3	] {};
void()	knight_die3	=[	69,	knight_die4	] {};
void()	knight_die4	=[	70,	knight_die5	] {};
void()	knight_die5	=[	71,	knight_die6	] {};
void()	knight_die6	=[	72,	knight_die7	] {};
void()	knight_die7	=[	73,	knight_die8	] {};
void()	knight_die8	=[	74,	knight_die9	] {};
void()	knight_die9	=[	75,	knight_die10] {};
void()	knight_die10=[	76,	knight_die10] {
	self.solid = SOLID_NOT; 
};


void()	knight_dieb1	=[	77,	knight_dieb2	] {};
void()	knight_dieb2	=[	78,	knight_dieb3	] {};
void()	knight_dieb3	=[	79,	knight_dieb4	] 	{};
void()	knight_dieb4	=[	80,	knight_dieb5	] {};
void()	knight_dieb5	=[	81,	knight_dieb6	] {};
void()	knight_dieb6	=[	82,	knight_dieb7	] {};
void()	knight_dieb7	=[	83,	knight_dieb8	] {};
void()	knight_dieb8	=[	84,	knight_dieb9	] {};
void()	knight_dieb9 = [	85,	knight_dieb9] {
	self.solid = SOLID_NOT; 
};


void() knight_die =
{
	// check for gib
	if (self.health < -25)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/h_mega.mdl", self.health);
		//for(float i = 0; i < 2; i++)
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

	sound (self, CHAN_VOICE, "knight/kdeath.wav", 1, ATTN_NORM);
	self.movetype = MOVETYPE_TOSS;
	self.takedamage = DAMAGE_YES;
	self.skin = 1;

	if (random() < 0.5)
		knight_die1 ();
	else
		knight_dieb1 ();

	self.deadflag = DEAD_DEAD;
};

void() knight_attack =
{
	local float		len;
	
// decide if now is a good swing time
	len = vlen(self.enemy.origin+self.enemy.view_ofs - (self.origin+self.view_ofs));
	
	if (len<80)
		knight_atk1 ();
	else
		knight_runatk1 ();
};

/*
QUAKED monster_knight (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_knight_cache = 
{
	
	precache_model ("progs/knight.mdl");
	precache_model ("progs/h_mega.mdl");

	precache_sound ("knight/kdeath.wav");
	precache_sound ("knight/khurt.wav");
	precache_sound ("knight/ksight.wav");
	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");
	precache_sound ("knight/idle.wav");
}

void() monster_knight =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_knight_cache ();
	spawn_knight ();
};

void() spawn_knight =
{	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/knight.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 125;
	self.max_health = 125;
	self.mass = 150;
	self.skin = 0;

	self.th_stand = knight_stand1;
	self.th_walk = knight_walk1;
	self.th_run = knight_run1;
	self.th_melee = knight_attack;
	self.th_pain = knight_pain;
	self.th_die = knight_die;
	self.th_spawn = spawn_knight;
		
	walkmonster_start();
};