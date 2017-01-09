( // cloud generator
var num = 1;
var arr = {b[\prep].choose}!7;
~pattern_drum_samp=nil;
num.do({|i|
	~pattern_drum_samp[i] = Pbind(\instrument,\perc_drum_samp,
		\dur, 0.01,
		\rate,Pbrown(0.05,4.6),
		\amp,Pwhite(0.01,0.05),\atk,0.001, \rel,3,
		\buf_num,Pxrand(arr,inf),\pos,Pbrown(-1,1)
	);
});
)

( // cloud_player
~cloud_drum_samp = Pbind(\instrument, \cloud_env,
	\inbus, ~pattern_drum_samp.index,
	\sus_lvl,0.7, \dur,Pwhite(0.5,3),
	\atk,0.01, \dec,0.7, \sus,3, \rel,5
);
)
~out2_dsamp = {FreeVerb.ar(~cloud_drum_samp.ar,0.6,0.75,0.35)}
~out2_dsamp.play;

~out2_dsamp.end;

~cloud_drum_samp=nil;
~pattern_drum_samp=nil;
