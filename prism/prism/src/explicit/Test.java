package explicit;

import java.util.ArrayList;
import java.util.BitSet;
import java.util.List;
import java.util.Random;
import java.util.Set;

import edu.jas.structure.Value;
import prism.PrismComponent;
import prism.PrismException;

public class Test {

	public static final int MAXnumberOfStates = (int) 2000;
	public static final int MAXnumberOfLabels = 1;

	public static DTMCSimple<Double> GenerateModel(int numberOfStates){

		Random random = new Random();
		DTMCSimple<Double> dtmcSimple = new DTMCSimple<Double>(numberOfStates);

		double threshold = 2 * Math.log(numberOfStates) / numberOfStates;
		for (int source = 0; source < numberOfStates; source++) {
			double outgoing = 0; // number of outgoing transitions of source
package explicit;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.BitSet;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.AbstractMap.SimpleEntry;

import edu.jas.structure.Value;

import prism.Evaluator;
import prism.PrismComponent;
import prism.PrismException;

/**
 * Decides which states of a labelled Markov chain are probabilistic bisimilar.  The implementation
 * is based on the bisimilarity algorithm from the paper "Efficient computation of
 * equivalent and reduced representations for stochastic automata" by Peter Buchholz.
 */
public class Buchholz<Value> extends AbstractBisimulation<Value> {

	public Buchholz(PrismComponent parent) throws PrismException {
		super(parent);
	}


	public static final double ACCURACY = 1E-5;
	public static final int PRECISION = 3;
	private ArrayList<List<SimpleEntry<Integer, Double>>> transitions;

	private static class EquivalenceClass {
		private boolean initialized;
		private double value;
		private int next;

		/**
		 * Initializes this equivalence class as uninitialized (no state belonging to this equivalence
		 * class has been found yet).
		 */
		public EquivalenceClass() {
			this.initialized = false;
			this.value = 0;
			this.next = 0;
		}
	}

	/**
	 * Decides probabilistic bisimilarity for the given labelled Markov chain.
	 * This method calculates equivalence classes of states in a discrete-time Markov chain (DTMC) where
	 * bisimilar states are grouped together in the same set
	 * @param dtmc The DTMC
	 * @param propNames Names of the propositions in {@code propBSs}
	 * @return A list of sets, where each set represents an equivalence class of bisimilar states.
	 */
	public List<Set<Integer>> decide(List<BitSet> propBSs) {
		List<Integer> indices = new ArrayList<Integer>();
		for (int state = 0; state < numStates; state++) {
			int label = partition[state];
			if (!indices.contains(label)) {
				indices.add(label);
			}
		}

		int numberOfEquivalenceClasses = indices.size(); // number of equivalence classes
		List<Set<Integer>> classes = new ArrayList<Set<Integer>>(); // equivalence classes
		TreeSet<Integer> splitters = new TreeSet<Integer>(); // potential splitters
		int[] clazzOf = new int[numStates]; // for each state ID, the index of its equivalence class
		for (int clazz = 0; clazz < numberOfEquivalenceClasses; clazz++) {
			classes.add(new HashSet<Integer>());
			splitters.add(clazz);
		}

		for (int state = 0; state < numStates; state++) {
			int label = partition[state];
			int index = indices.indexOf(label);
			clazzOf[state] = index;
			classes.get(index).add(state);
		}

		double[] values = new double[numStates];
		while (!splitters.isEmpty()) {
			List<EquivalenceClass> split = new ArrayList<EquivalenceClass>();
			for (int clazz = 0; clazz < numberOfEquivalenceClasses; clazz++) {
				split.add(new EquivalenceClass());
			}
			int splitter = splitters.first();
			splitters.remove(splitter);

			// computing values
			Arrays.fill(values, 0);
			for (int target : classes.get(splitter)) {
				 for (SimpleEntry<Integer, Double> pair : transitions.get(target)) {
					int source = pair.getKey();
					double probability = pair.getValue();
					values[source] += probability;
				}
			}

			for (int state = 0; state < numStates; state++) {
				int clazz = clazzOf[state];
				if (!split.get(clazz).initialized) {
					classes.set(clazz, new HashSet<Integer>());
					classes.get(clazz).add(state);
					split.get(clazz).initialized = true;
					split.get(clazz).value = values[state];
				} else {
					if (Math.abs(split.get(clazz).value - values[state]) >= ACCURACY && split.get(clazz).next == 0) {
						splitters.add(clazz);
					}
					while (Math.abs(split.get(clazz).value - values[state]) >= ACCURACY && split.get(clazz).next != 0) {
						clazz = split.get(clazz).next;
					}
					if (Math.abs(split.get(clazz).value - values[state]) < ACCURACY) {
						clazzOf[state] = clazz;
						classes.get(clazz).add(state);
					} else {
						splitters.add(numberOfEquivalenceClasses);
						clazzOf[state] = numberOfEquivalenceClasses;
						split.get(clazz).next = numberOfEquivalenceClasses;
						split.add(new EquivalenceClass());
						split.get(numberOfEquivalenceClasses).initialized = true;
						split.get(numberOfEquivalenceClasses).value = values[state];
						classes.add(new HashSet<Integer>());
						classes.get(numberOfEquivalenceClasses).add(state);
						numberOfEquivalenceClasses++;
					}
				}
			}
		}
		return classes;
	}

	@Override
	protected DTMC<Value> minimiseDTMC(DTMC<Value> dtmc, List<String> propNames, List<BitSet> propBSs){
		numStates = dtmc.getNumStates();
		initialisePartitionInfo(dtmc, propBSs);

		// Build new model
		Evaluator<Value> eval = dtmc.getEvaluator();
		transitions = new ArrayList<>(numStates);
		for (int i = 0; i < numStates; i++) {
			transitions.add(new ArrayList<>());
		}

		for (int source = 0; source < numStates; source++) {
			Iterator<Map.Entry<Integer, Value>> iter = dtmc.getTransitionsIterator(source);
			while (iter.hasNext()) {
				Map.Entry<Integer, Value> e = iter.next();
				int target = e.getKey();
				double probability = eval.toDouble(e.getValue());
				transitions.get(target).add(new SimpleEntry<>(source, probability));
			}
		}

		List<Set<Integer>> classes = decide(propBSs);
		numBlocks = classes.size();

		int[] stateOf = new int[numStates];
		int id = 0;
		for (Set<Integer> clazz : classes) {
			for (Integer s : clazz) {
				partition[s] = id;
				stateOf[id] = s;
			}
			id++;
		}

		mainLog.println("Minimisation with Buchholz: " + numStates + " to " + numBlocks + " States ");

		DTMCSimple<Value> dtmcNew = new DTMCSimple<Value>(numBlocks);
		for(int b = 0; b < numBlocks; b++) {
			int s = stateOf[b];
			Iterator<Map.Entry<Integer, Value>> iter = dtmc.getTransitionsIterator(s);
			while (iter.hasNext()) {
				Map.Entry<Integer, Value> e = iter.next();
				dtmcNew.addToProbability(b, partition[e.getKey()], e.getValue());
			}
		}
		attachStatesAndLabels(dtmc, dtmcNew, propNames, propBSs);
		return dtmcNew;
	}

	@Override
	public boolean[] bisimilar(DTMC<Value> dtmc, List<BitSet> propBSs){
		if (!(dtmc instanceof DTMCSimple))
			throw new IllegalArgumentException("Expected an instance of DTMCSimple.");

		numStates = dtmc.getNumStates();
		initialisePartitionInfo(dtmc, propBSs);

		// Build new model
		Evaluator<Value> eval = dtmc.getEvaluator();
		transitions = new ArrayList<>(numStates);
		for (int i = 0; i < numStates; i++) {
			transitions.add(new ArrayList<>());
		}

		for (int source = 0; source < numStates; source++) {
			Iterator<Map.Entry<Integer, Value>> iter = dtmc.getTransitionsIterator(source);
			while (iter.hasNext()) {
				Map.Entry<Integer, Value> e = iter.next();
				int target = e.getKey();
				double probability = eval.toDouble(e.getValue());
				transitions.get(target).add(new SimpleEntry<>(source, probability));
			}
		}

		List<Set<Integer>> classes = decide(propBSs);
		boolean[] bisimilar = new boolean[numStates * numStates];
		for (Set<Integer> clazz : classes) {
			for (Integer s : clazz) {
				for (Integer t : clazz) {
					bisimilar[s * numStates + t] = true;
				}
			}
		}
		return bisimilar;
	}
}


			double[] probability = new double[numberOfStates];

			for (int target = 0; target < numberOfStates; target++) {
				if (random.nextDouble() < threshold) {
					probability[target] = 1;
					outgoing++;
				}
			}
			if (outgoing > 0) {
				for (int target = 0; target < numberOfStates; target++) {

					if(probability[target]/outgoing > 0.0) {
						dtmcSimple.setProbability(source, target, probability[target]/outgoing);
					}

				}
			} else {
				dtmcSimple.setProbability(source, source, 1.0);
			}
		}
		return dtmcSimple;
	}

	public static List<BitSet> Generatelabels(int numberOfStates, int numberOfLabels){
		Random random = new Random();
		List<BitSet> propBSs = new ArrayList<>();
		for(int s = 0; s < numberOfLabels; s++) {
			BitSet bitSet = new BitSet(numberOfStates);
			propBSs.add(bitSet);
		}

		for(int s = 0; s < numberOfStates; s++) {
			int mask = random.nextInt((1<<numberOfLabels));
			for(int i = 0; i < numberOfLabels; i++) {
				if(((mask >> i)&1) == 1) {
					propBSs.get(i).set(s, true);
				}else {
					propBSs.get(i).set(s, false);
				}
			}
		}

		return propBSs;
	}


	private static void RandomModel() {
		try {

			PrismComponent parent = new PrismComponent() {};

			Random random = new Random();
			int numberOfStates = random.nextInt(MAXnumberOfStates) + 1;
			int numberOfLabels = random.nextInt(MAXnumberOfLabels) + 1;
			DTMCSimple<Double> dtmc = GenerateModel(numberOfStates);
			List<BitSet> propBSs = Generatelabels(numberOfStates, numberOfLabels);


			Buchholz<Double> buchholz = new Buchholz<>(parent);
			boolean[] Buchholz = buchholz.bisimilar(dtmc, propBSs);

			Bisimulation<Double> bisimilation = new Bisimulation<>(parent);
			boolean[] Bisimilation = bisimilation.bisimilar(dtmc, propBSs);

			Bisimulation<Double> derisaviSplay = new DerisaviSplayTree<>(parent);
			boolean[] DerisaviSplayTree = derisaviSplay.bisimilar(dtmc, propBSs);

			Bisimulation<Double> derisaviRB = new DerisaviRedBlack<>(parent);
			boolean[] DerisaviRedBlack = derisaviRB.bisimilar(dtmc, propBSs);

			Bisimulation<Double> valmari = new Valmari<>(parent);
			boolean[] Valmari = valmari.bisimilar(dtmc, propBSs);


			// compare the result
			for(int i = 0; i < numberOfStates; i++) {
				for(int j = 0; j < numberOfStates; j++) {
					if(
							Buchholz[i*numberOfStates + j] !=  Bisimilation[i*numberOfStates + j] ||
									Buchholz[i*numberOfStates + j] !=  DerisaviSplayTree[i*numberOfStates + j] ||
									Buchholz[i*numberOfStates + j] !=  DerisaviRedBlack[i*numberOfStates + j] ||
									Buchholz[i*numberOfStates + j] !=  Valmari[i*numberOfStates + j] ) {

						System.out.println("Erorr!! " + i + " " + j + " " + Buchholz[i*numberOfStates + j] + " " + Bisimilation[i*numberOfStates + j]);
						System.out.println(dtmc.toString());
						System.exit(0);
					}

				}
			}

			System.out.println("okay");

		} catch (PrismException e) {
			e.printStackTrace();
		}
	}


	public static void main(String[] args) {

		for(int i = 0; i < 10000; i++)
			RandomModel();
	}


}
