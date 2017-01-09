(
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 2;
s.boot;
)
(

~constructor = { |server|

	var synth_lib = (

		gabor_grain: {|freq=200,amp=0.1, sustain=0.1, width=0.1 |
			var env = LFGauss.ar(sustain, width,loop:0, doneAction:2);
			var amp_mod = amp * AmpComp.ir(freq.max(50)) * 0.5;
			FSinOsc.ar(freq)!2 * amp_mod * env;
		}.asSynthDef(\ir!4, outClass:\OffsetOut).add,

		formant: { |ffreq=200, formmod_freq=1,fm_lo=200, fm_hi=1000, bwfreq=200, amp=0.1|
			Formant.ar(ffreq, LFNoise0.kr(formmod_freq).exprange(fm_lo,fm_hi), 200)!2 * amp;
		},

		mouse_decay: { |osc_freq = 200|
			Decay2.ar(Impulse.ar(MouseX.kr(1,70,1), 0.25), 0.01, MouseY.kr(0.01,0.75,1))!2 * FSinOsc.ar(osc_freq)
		}

	);
	var init = {
		var proxy = ProxySpace.new(server).know = true;

		synth_lib.keysValuesDo( { |k,v| proxy[k]=v; } );
		proxy.fadeTime = 3;

		proxy.out0.ar;  // start with 4 outbuses plus synth_lib
		proxy.out1.ar;
		proxy.out2.ar;
		proxy.out3.ar;

		proxy
	};

	init.()
}
)

(
p = ~constructor.(s).push;
ProxyMixer(p);
)
(//reset
p.pop;
p.clear;
)

// main script
p.fadeTime = 7;

// simple additive on the fly using slots
~z[0..4]= { SinOsc.ar(ExpRand(1000,1500) + LFNoise0.ar(ExpRand(1,7)).exprange(50,100)) * ExpRand(0.05,0.5)};

~saw_lfo = { LFTri.kr(0.25).exprange(0.001,0.3) }
~saw2_lfo = {LFSaw.kr(0.45).exprange(0.01,0.1)}
~tri_lfo = { LFTri.kr(0.25).exprange(0.01,0.1) }
~saw3_lfo = {LFSaw.kr(3).exprange(0.01,0.001)}

~noise = {PinkNoise.ar()* LFTri.kr(0.5).exprange(0.01,0.2)};
~filt = { LPF.ar(~noise.ar, LFNoise0.ar(1).exprange(1200,2500)) }

(
~pattern1 = Pbindef(\grain0,
	\instrument, ~gabor_grain.source.name.asSymbol,
	\dur, 0.01, \amp,0.3, \freq,Pseq([200,250,400],inf), \sustain,0.1);
)

(
~pattern2 = Pbindef(\grain1,
	\instrument, ~gabor_grain.source.name.asSymbol,
	\dur, 0.1, \amp, 0.35, \freq, Prand((300,400..900),inf),\sustain,~saw3_lfo);
)

Pbindef(\grain0, \dur,Pseq((0.001,0.002..0.01),inf), \sustain, ~saw2_lfo, \amp, 0.85)
Pbindef(\grain0, \dur,Prand([0.01,0.02,0.01],inf));
Pbindef(\grain0, \freq, Pseq((50,70..360),inf));

~out0 = ~saw_lfo * ~z
~out0.play;
~out0.end;

~out1 = ~pattern1!2
~out1.play;
~out1.end;


~out2.play;
~out2 = ~pattern2!2
~out2.end;


~out3.play;
~out3 = ~filt;

~verb_out.ar
~verb_out.play;
~verb_out = {FreeVerb.ar(~out3.ar, 1,0.6,0.8)}
