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

// receives total stanza score, defined as the sum of each letter's value.
// controls (a) the selected scale: sum % (total num of scales = 108)
// and (b) the Tempo: (sum / number of phrases)/120
OSCdef.new(
	'/stanza/score',
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		// Pdefn(\syllab_weight, Pseq(new_list.asArray, inf));
		~stanza.score.value_(values[1..]).changed(\value);
		("total score is "++values[1..]).postln;

	},
	'/stanza/score',
	nil,
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
	'/syllab/text',
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



// receives syllable's score, defined as the sum of each letter's value.
// defines the final pitch of this syllable, modulo ~stanza.scale_size
OSCdef.new(
	'/syllab/score',
	{
		|msg, time, recAddr, recPort|
		var values = msg;
		var new_list = List.new;

		// Pdefn(\syllab_weight, Pseq(new_list.asArray, inf));
		~phrase.syll_score.value_(values[1..]).changed(\value);
		("score is "++values[1..]).postln;

	},
	'/syllab/score',
	nil,
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

