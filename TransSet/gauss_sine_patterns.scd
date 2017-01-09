( // cloud generator
var num = 5;
~pattern_gauss_sine=nil;
num.do({|i|
	~pattern_gauss_sine[i] = Pbind(\instrument,\gauss_sine,
		\dur,0.01, \freq, Pwhite(400,1600),
		\grain_dur, 0.005,
		\amp,Pwhite(0.001,0.2), \pos, Pwhite(-1,1)
	);
});
)

( // cloud_player
~cloud_gauss_sine = Pbind(\instrument, \cloud_env,
	\inbus, ~pattern_gauss_sine.index,
	\sus_lvl,Pwhite(0.2,0.4), \dur, Pseq([0.1,0.2,0.1,0.3,0.1],inf),
	\atk,0.01, \dec,0.12, \sus,0.1, \rel,0.05
);
)

/* OUTPUT/FX */
~out0_gsine = {FreeVerb.ar(~cloud_gauss_sine.ar,0.1,0.9,0.45)}

~out0_gsine.play;

~out0_gsine.end;

~pattern_gauss_sine=nil;
~cloud_gauss_sine=nil;

