
~phrase= (
	id: 0,
	parallel: Ref(true), // affects Pbindef players
	syll_length: Ref([]),
	syll_stress: Ref([]),
	syll_weight: Ref([]),
	num_words: Ref("Int"),
	adjs: Ref([]),
	nouns: Ref([]),

	instr: Ref([]),
	pitch_material: Ref([]),
	scale: Ref("Scale"),
	steps_octave: Ref("Int"),
	stack: Ref(true), // affects Pdefns
	recursion: Ref(true) // affects Pbindef players
);

~phrase.stack.value_(true)
~phrase.stack.value

(
~length_ctrl.remove;
~length_ctrl=SimpleController(~phrase.syll_length);
~length_ctrl.put(
	\value, {|values, tag, args|
		// Here I work around the problem that ".condition_" imposes
		// on the included Pdefns, i.e. every time place the incoming
		// list into a new List, so that the new Pdefn can register correctly
		// the List.size and use it as "wait" argument in its conditional execution.
		var newList = List.new;
		var local_env = ();
		var pos = ("pos"++~phrase.id).asSymbol; // create a new name every time
		if(~phrase.stack.value==true){ // check if phrases are played until end before new phrase begins
			values.value.do{ |i|
				if (i.isKindOf(Integer)){
					newList.add(i)
				}{
					newList.add(Rest(1))
			}};
			local_env.put(pos, newList);
			local_env.postln;
			("lenghts are: "++ values.value).postln;
			Pdefn(\sylab_length, Pseq(local_env[pos].asArray, 1)).condition_({ |val,i|
				var size = local_env[pos].size;
				("New Pattern starts in ..."++ (size- i)).postln;
				i.postln%size==0;
			});
		}{
			values.value.do{ |i|
				if (i.isKindOf(Integer)){
					newList.add(i)
				}{
					newList.add(Rest(1))
			}};
			local_env.put(pos, newList);
			local_env.postln;
			("lenghts are: "++ values.value).postln;
			Pdefn(\sylab_length, Pseq(local_env[pos].asArray, 1))// no conditional trigger here!
		};
		~phrase.id = ~phrase.id+1;
	}
);

);

~length_ctrl.put(\fafa, {|a,b,c| "haha".postln})


currentEnvironment.keys

~phrase.syll_length.value_([1,2,5,3,4]).changed(\value)
~phrase.id
~checker= List.new;
~checker[2].value.class

~phrase
