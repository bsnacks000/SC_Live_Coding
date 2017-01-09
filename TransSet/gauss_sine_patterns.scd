( // cloud generator
var num = 1;
~pattern_gauss_sine=nil;
num.do({|i|
	~pattern_gauss_sine[i] = Pbind(\instrument,\gauss_sine,
		\dur,0.1, \freq, 1200,
		\grain_dur, 0.005,
		\amp,0.5, \pos, Pwhite(-1,1)
	);
});
)

( // cloud_player
~cloud_gauss_sine = Pbind(\instrument, \cloud_env,
	\inbus, ~pattern_gauss_sine.index,
	\sus_lvl,Pwhite(0.5,0.4), \dur, 3,
	\atk,0.01, \dec,0.12, \sus,1, \rel,3
);
)

/* OUTPUT/FX */
~out0_gsine.play;

~out0_gsine = {FreeVerb.ar(~cloud_gauss_sine.ar,0.1,0.9,0.45)}
~out0_gsine = ~cloud_gauss_sine;

~out0_gsine.end;

~pattern_gauss_sine=nil;
~cloud_gauss_sine=nil;


p[\pattern_gauss_sine].index
p[\cloud_gauss_sine].inbus

