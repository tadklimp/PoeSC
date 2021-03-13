// You cannot open a TCP listening port with sclang :(
// You will have to use UDP
NetAddr.langPort; // Generally port 57120 but could be used by another application so check
thisProcess.openPorts; // See all open ports for sclang.  These are UDP ports



// Trace incoming messages
OSCFunc.trace(false);

~stack = {
	var event = (
		counter: 0,
		list: {|self, cur, next, name, val|
			self[\counter] = self[\counter]+1;
			self[\counter].postln;

			if(self[\counter] %2 == 0){
				"even".postln;
				val[1..].do{ |i|
					if (i.isKindOf(Integer)){
						cur.add(i)
					}{
						cur.add(Rest(1))
					}
				};
				("lenghts are: "++ val[1..]).postln;
				cur.postln;
				Pdefn(name.asSymbol, Pseq(cur.asArray, 1)).condition_({ |val,i|
					var size=cur.size;
					("size is"++ size).postln;
					i.postln%size==0
				});
			}{
				"odd".postln;
				val[1..].do{ |i|
					if (i.isKindOf(Integer)){
						next.add(i)
					}{
						next.add(Rest(1))
					}
				};
				("lenghts are: "++ val[1..]).postln;
				next.postln;
				Pdefn(name.asSymbol, Pseq(next.asArray, 1)).condition_({|val,i|
					var size=next.size;
					("size is"++ size).postln;
					i.postln%size==0 });
			}
		}
	);
	event;
}.value;


(
~counter = {
	var event = (
		counter: 0,
		list: {|self, input_list|
			self[\counter] = self[\counter]+1;

			if(self[\counter] %2 == 0){
				"even".postln;
				List.new;
			}{
				List.new;
			}
		};
	);
	event;
}.value;
);

~da=List.new;
~da.add(10)
~xaxa = ~counter.list
~xaxa.add(2)
~xaxa

(

OSCdef.freeAll;

OSCdef.new(
	'/sylab/length', // It expects Integers and Rests
	{ |msg, time, recAddr, recPort|
		var values = msg;
		var showq;
		var current_list = List.new;
		var next_list = List.new;


		~stack.list(current_list, next_list, "sylab_length", values);

		/*	showq = {|cur,next|
		if (cur.isKindOf(List)){
		// current_list = cur;
		cur.add([1,2,3]);
		};
		// [cur, next].postln;
		};
		showq.value(current_list,List.new);
		("checkkkk=====>>>>> "++current_list).postln;*/
	},
	'/sylab/length', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;


// 'PUU'.asString.do{|i| {case {i==$P}{"ya".postln}{i==$U}{"yuuu".postln}; }.fork}

//
OSCdef.new(
	'/sylab/stress', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		// new_list.add(0); // init list
		values[1..].do{ |i|
			if (i.isKindOf(Symbol)){
				if(i != 'Rest(0)') { i.asString.do{ |x|
					// x.class.postln;
					case
					{x == $P}{ new_list.add(1.0)} // Primary stress
					{x == $S}{ new_list.add(0)} // Secondary stress
					{x == $U}{ new_list.add(0)} // Unstressed
				}
				}{
					// new_list.add(Rest(0))
					// new_list.add(0)
				}
			}
		};

		Pdefn(\sylab_stress, Pseq(new_list.asArray, 1));
		("stresses are: "++ msg[1..]).postln;
		// (Pdefn(\sylab_stress).source.storeArgs).postln;
		new_list.postln;
	},
	'/sylab/stress', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;


OSCdef.new(
	'/sylab/weight', // Name in the global dictionary
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		// new_list.add(0); // init list
		values[1..].do{ |i|
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
		};

		Pdefn(\sylab_weight, Pseq(new_list.asArray, inf));
		("weights are: "++ msg[1..]).postln;
		new_list.postln;

		// ("weights are: "++ msg[1..]).postln
	},
	'/sylab/weight', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;




OSCdef.new(
	'/sylab/text', // Name in the global dictionary
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

		// Pdefn(\sylab_weight, Pseq(new_list.asArray, inf));
		("texts are: "++ msg[1..]).postln;
		new_list.postln;

		// ("weights are: "++ msg[1..]).postln
	},
	'/sylab/text', // A path essentially detailing the name of the listening function
	nil, // nil means to listen to all incoming IPs/ports
).fix;

)



OSCdef.all; // All OSC listening functions stored as dictionary
OSCdef.freeAll;



// A test Pbind
// TODO: Find a way to have multiple speeds inside of Pbind :(
(
Pbind(
	\dur, 0.25,
	\degree, Pdefn(\sylab_stress)*7,
	\amp, 0.5
	// \stretch, Pconst(21,Pdefn(\sylab_weight)).trace(prefix:'stretch: ')
).play
);



// \sylab_length defines the Macro-Talea of the phrase, i.e a general multiplier of speed
// \syllab_stress is simply assigned here to pitch
(

Pbindef(\try,
	\talea_trigger, Pn(Pdefn(\sylab_stress),inf,\step1), // dummy placeholder for triggering Pgate of \speed
	// this fixes the problem of having a Pn before the Pgate
	// it should be the same Pdefn as the \dur Pdefn
	\speed, Pgate(Pdefn(\sylab_length),1,\step1).trace, // talea multiplier for \dur
	\degree, Pn(Pshuf([1,3,5,7]),inf),
	\octave, Pn((Pdefn(\sylab_stress)*2)+3,inf), // syllab stress effects octave
	\dur, 0.25*Pkey(\speed) ,
).play;
)



// a Duo test
(

Pbindef(\try,
	\talea_trigger, Pn(Pdefn(\sylab_stress),inf,\step1), // dummy placeholder for triggering Pgate of \speed
	// this fixes the problem of having a Pn before the Pgate
	// it should be the same Pdefn as the \dur Pdefn
	\speed, Pgate(Pdefn(\sylab_length),1,\step1).trace, // talea multiplier for \dur
	\degree, Pn(Pshuf([1,3,5,7]),inf),
	\octave, Pn((Pdefn(\sylab_stress)*2)+3,inf), // syllab stress effects octave
	\dur, 0.25*Pkey(\speed) ,
	\pan, -0.5
);


Pbindef(\try2,
	\talea_trigger, Pn(Pdefn(\sylab_stress),inf,\step1), // dummy placeholder for triggering Pgate of \speed
	// this fixes the problem of having a Pn before the Pgate
	// it should be the same Pdefn as the \dur Pdefn
	\speed, Pgate(Pdefn(\sylab_length),1,\step1).trace, // talea multiplier for \dur
	\degree, Pn(Pshuf([1,3,5,7]+4),inf),
	\octave, Pn((Pdefn(\sylab_stress)*2)+3,inf), // syllab stress effects octave
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






////////// old 'sylab/length'

var stack = {|i|
	var event = (
		counter: 0,
		list: {|self,num|
			self[\counter] = self[\counter]+1;
			self[\counter].postln;

			if(self[\counter] %2 == 0){
				"even".postln;
				values[1..].do{ |i|
					if (i.isKindOf(Integer)){
						current_list.add(i)
					}{
						current_list.add(Rest(1))
					}
				};
				("lenghts are: "++ msg[1..]).postln;
				current_list.postln;
				Pdefn(\sylab_length, Pseq(current_list.asArray, 1)).condition_({ |val,i|
					var size=current_list.size;
					("size is"++ size).postln;
					i.postln%size==0
				});
			}{
				"odd".postln;
				values[1..].do{ |i|
					if (i.isKindOf(Integer)){
						next_list.add(i)
					}{
						next_list.add(Rest(1))
					}
				};
				("lenghts are: "++ msg[1..]).postln;
				next_list.postln;
				Pdefn(\sylab_length, Pseq(next_list.asArray, 1)).condition_({|val,i|
					var size=next_list.size;
					("size is"++ size).postln;
					i.postln%size==0 });
			}
		}
	);
	event;
}.value;




s.meter;