NetAddr.langPort; // Generally port 57120 but could be used by another application so check
thisProcess.openPorts; // See all open ports for sclang.  These are UDP ports

// Trace incoming messages
OSCFunc.trace(true,true);
OSCFunc.trace(false);
~counter
(
// reset
OSCdef.freeAll;

// Assign a new ID to each new Stanza
// and pass the number of included phrases
OSCdef.new(
	'/stanza/trigger',
	{
		|msg, time, recAddr, recPort|
		~stanza.id.value_(~stanza.id.value+1).changed(\init);
		~stanza.num_of_phrases.value_(msg[1]);
	},
	'/stanza/trigger', // A path detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;

// Check Stanza's playback mode (Serial or Parallel)
OSCdef.new(
	'/stanza/mode',
	{
		|msg, time, recAddr, recPort|
		case
		{msg[1] == 'seq'} { ~stanza.mode.value_('seq') }
		{msg[1] == 'par'} { ~stanza.mode.value_('par') };
	},
	'/stanza/mode',
	nil,
).fix;


// receives amount of syllables in each word
// that could effect fx parameters
// e.g. every syll_length change x
OSCdef.new(
	'/syllab/length', // It expects Integers and Rests
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		~phrase.trig.value_(~phrase.trig.value+1).changed(\value);
		~phrase.syll_length.value_(values[1..]).changed(\value);
	},
	'/syllab/length', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;



// receives the syllable's stress, Primary, Secondary, or Unstressed.
// it scales the pitch collection
OSCdef.new(
	'/syllab/stress', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		~phrase.syll_stress.value_(values[1..]).changed(\value);
	},
	'/syllab/stress',
	nil,
).fix;


// it receives the syllable's weight: Light or Heavy
// it scales duration
OSCdef.new(
	'/syllab/weight',
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		~phrase.syll_weight.value_(values[1..]).changed(\value);
	},
	'/syllab/weight',
	nil,
).fix;




OSCdef.new(
	'/syllab/text', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		// new_list.add(0); // init list
		/*		values[1..].do{ |i|
		if (i.isKindOf(Symbol)){
		if(i != 'Rest(0)') { i.asString.do{ |x|
		// x.class.postln;
		case
		{x == $H}{ new_list.add(2.0)}
		{x == $L}{ new_list.add(1.0)}
		}
		}{
		new_list.add(0)
		}
		}
		};*/

		// Pdefn(\syllab_weight, Pseq(new_list.asArray, inf));
		("texts are: "++ msg[1..]).postln;
		// new_list.postln;

		// ("weights are: "++ msg[1..]).postln
	},
	'/syllab/text', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;

// receives each line's punctuation
OSCdef.new(
	'/phrase/punct',
	{
		|msg, time, recAddr, recPort|
		var values = msg;
			~phrase.punctuation.value_(values[1..]).changed(\value);

	},
	'/phrase/punct',
	nil,
).fix;



// receives each line's adjectives
OSCdef.new(
	'/phrase/adj',
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		// add new Adjectives to ~phrase dictionary
		values[1..].do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') {
					i.do{ |x|
						new_list.add(x);
				}};
				~phrase.adjectives.value_(new_list.asArray).changed(\update);
			}
		};
		// if there are no Adjectives return an empty Array
		if (values[1..].size == 0){
			~phrase.adjectives.value_([]).changed(\update);
		};
	},
	'/phrase/adj',
	nil,
).fix;
)



OSCdef.all; // All OSC listening functions stored as dictionary
OSCdef.all.keys
OSCdef.freeAll;



// A test Pbind
// TODO: Find a way to have multiple speeds inside of Pbind :(
(
Pbind(
	\dur, 0.25 * Pdefn(\syllab_weight),
	\degree, Pdefn(\syllab_stress)*7,
	\amp, 0.1
	// \stretch, Pconst(21,Pdefn(\syllab_weight)).trace(prefix:'stretch: ')
).play
);



// \syllab_length defines the Macro-Talea of the phrase, i.e a general multiplier of speed
// \syllab_stress is simply assigned here to pitch
(

Pbindef(\try,
	\talea_trigger, Pn(Pdefn(\syllab_stress),inf,\step1), // dummy placeholder for triggering Pgate of \speed
	// this solves the problem of necessarily having a Pn-trigger placed above the Pgate
	// it should be the same Pdefn as the \dur Pdefn
	\speed, Pgate(Pdefn(\syllab_length),1,\step1).trace, // talea multiplier for \dur
	// \degree, Pn(Pshuf([1,3,5,7]),inf),
	\degree, Pn(Pshuf([1]),inf),
	\octave, Pn((Pdefn(\syllab_stress)*2)+3,inf), // syllab stress effects octave
	\dur, 0.125*Pkey(\speed) ,
	\amp, 0.5
	// \dur, 0.25 ,
).play(quant:1);
)



// a Duo test
(

Pbindef(\try,
	\talea_trigger, Pn(Pdefn(\syllab_stress),inf,\step1), // dummy placeholder for triggering Pgate of \speed
	// this fixes the problem of having a Pn before the Pgate
	// it should be the same Pdefn as the \dur Pdefn
	\speed, Pgate(Pdefn(\syllab_length),1,\step1).trace, // talea multiplier for \dur
	\degree, Pn(Pshuf([1,3,5,7]),inf),
	\octave, Pn((Pdefn(\syllab_stress)*2)+3,inf), // syllab stress effects octave
	\dur, 0.25*Pkey(\speed) ,
	\pan, -0.5
);


Pbindef(\try2,
	\talea_trigger, Pn(Pdefn(\syllab_stress),inf,\step1), // dummy placeholder for triggering Pgate of \speed
	// this fixes the problem of having a Pn before the Pgate
	// it should be the same Pdefn as the \dur Pdefn
	\speed, Pgate(Pdefn(\syllab_length),1,\step1).trace, // talea multiplier for \dur
	\degree, Pn(Pshuf([1,3,5,7]+4),inf),
	\octave, Pn((Pdefn(\syllab_stress)*2)+3,inf), // syllab stress effects octave
	\dur, 0.5*Pkey(\speed) ,
	\pan, 0.5
);

Ppar([Pbindef(\try),Pbindef(\try2)]).play
)




///////////// troubleshooting multiple speeds in one Pbind

(
Pbind(
	\dur, 1,
	\amp, Pfindur(1,Pseg(Pseq([0.1,1],inf), 0.25 ,\lin,inf)),
).play
);


Rational(4,7).asFloat
a = [2,1,1,2,1,2,2,1]
b = (a.size-1).collect({|i| a[i] %/ a[i+1]; })
b.asFloat.postln



~filterFreqBus = Bus.control(s, 1);

(
Pbind(
	\type, \bus,
	\out, ~filterFreqBus,
	\array, Pseg(Pseq([0.1,0.5],inf), 0.5 ,\sin,inf),
	\dur, 0.001
).play;
)

~filterFreqBus.plot(1); // seems to work

(
Pbind(
	\dur, 2,
	\legato, 1,
	\amp, ~filterFreqBus.asMap
).play;
)











(
s.boot;
~out = 0;

~printUgenMsg = {
	|name, recAddr, freq, phase, amp, dur, pan|
	var header, phaseStr, args;
	header = name ++ " message from " ++ recAddr ++ ": ";
	phaseStr = if(phase == nil, {""}, {", Phase " ++ phase});
	args = "Freq " ++ freq ++ phaseStr ++ ", Amp " ++ amp ++ ", Dur " ++ dur ++ ", Pan " ++ pan;
	postln(header ++ args)
};

SynthDef(\sine, {
	arg out = ~out, freq, phase, amp, dur, pan;
	var sig, env;
	sig = SinOsc.ar(freq, phase, amp);
	env = Env.linen(5, dur, 5);
	sig = sig * EnvGen.kr(env, doneAction: 2);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

OSCdef.new(
	'sine',
	{
		|msg, time, recAddr, recPort|
		var freq, phase, amp, dur, pan;
		freq = msg[1];
		phase = msg[2];
		amp = msg[3];
		dur = msg[4];
		pan = msg[5];
		~printUgenMsg.value("Sine", recAddr, freq, phase, amp, dur, pan);
		Synth(\sine, [\freq, freq, \phase, phase, \amp, amp, \dur, dur, \pan, pan]);
	},
	'/sounds/sine',
	nil
);

SynthDef(\saw, {
	arg out = ~out, freq, amp, dur, pan;
	var sig, env;
	sig = Saw.ar(freq, amp); // Saw doesn't have phase argument
	env = Env.linen(5, dur, 5);
	sig = sig * EnvGen.kr(env, doneAction: 2);
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

OSCdef.new(
	'saw',
	{
		|msg, time, recAddr, recPort|
		var freq, amp, dur, pan;
		freq = msg[1];
		amp = msg[2];
		dur = msg[3];
		pan = msg[4];
		~printUgenMsg.value("Saw", recAddr, freq, nil, amp, dur, pan);
		Synth(\saw, [\freq, freq, \amp, amp, \dur, dur, \pan, pan]);
	},
	'/sounds/saw',
	nil
);
)

s.meter;