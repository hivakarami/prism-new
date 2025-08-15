/*
 * Copyright (C) 2019 DisCoVeri group, Department of EECS, York University
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You can find a copy of the GNU General Public License at
 * <http://www.gnu.org/licenses/>.
 */

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;
import java.io.PrintWriter;

/**
 * Given a text file that contains a CTMC in the format given by PRISM/MRMC, this app generates 
 * a text file containing the embedded DTMC in the format given by PRISM/MRMC.
 * 
 * @author Maeve Wildes
 */
public class CTMCtoDTMC {
	/**
	 * Transforms a CTMC into the embedded DTMC.
	 * 
	 * @param args[0] prism or mrmc.
	 * @param args[1] the name of the text file that contains a CTMC.
	 * @param args[1] the name of the text file that contains the embedded DTMC.
	 * @param args[2] the precision of the probabilities (the number of digits to represent the 
	 * probabilities). 
	 */
	public static void main (String [] args) {
		final int ARGS = 4;
		if (args.length != ARGS) {
			System.out.println("Usage: java CTMCtoDTMC <prism or mrmc> <file name of CTMC> <file name of DTMC> <precision>");
		} else {
			try {
			        final String checker = args[0];
				final String CTMC = args[1];
				final String DTMC = args[2];
				final int precision = Integer.parseInt(args[3]);

				// read the file containing the CTMC
				final Scanner input = new Scanner(new File(CTMC));
				final int states; // number of states
				final int transitions; // number of transitions
				if (checker.equals("prism")) {
					states = input.nextInt(); // number of states
					transitions = input.nextInt();
				} else if (checker.equals("mrmc")) {
					input.next();
					states = input.nextInt();
					input.next();
					transitions = input.nextInt();
				} else {
				    System.out.println("Usage: java CTMCtoDTMC <prism or mrmc> <file name of CTMC> <file name of DTMC> <precision>");
				    states = 0;
				    transitions = 0;
				    System.exit(0);
				}
				final int[] source = new int[transitions];
				final int [] target = new int [transitions];
				final double[] rate = new double [transitions];
				for (int i = 0; i < transitions; i++) {
					source[i] = input.nextInt();
					target[i] = input.nextInt();
					rate[i] = input.nextDouble();
				}
				input.close();

				// compute the exit rates
				final double[] exitRate = new double[states + 1];
				for (int i = 0; i < transitions; i++) {
					exitRate[source[i]] += rate[i];
				}

				// compute and write the embedded DTMC
				final PrintWriter output = new PrintWriter(DTMC);
				if (checker.equals("prism")) {
					output.println(states + " " + transitions);
				} else {
					output.println("STATES " + states);
					output.println("TRANSITIONS " + transitions);
				}
				for (int i = 0; i < transitions; i++) {
					double probability;
					if (exitRate[source[i]] == 0) {
						if (source[i] == target[i]) {
							probability = 1.0;
						} else {
							probability = 0.0;
						}
					} else {
						probability = rate[i] / exitRate[source[i]];
					}
					output.printf("%d %d %." + (precision - 1) + "f%n", source[i], target[i], probability);
				}
				output.close();
			} catch (FileNotFoundException e) {
				System.out.println("File could not be read or written");
				e.printStackTrace();
			}
		}
	}
}
