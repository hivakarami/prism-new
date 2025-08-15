import re

def remove_deadlock_entries(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        in_declaration = False
        for line in infile:
            if line.strip() == "#DECLARATION":
                in_declaration = True
            elif line.strip() == "#END":
                in_declaration = False
                
            if in_declaration:
                outfile.write(line)
            else:
                match = re.match(r'(\d+):?\s*(.*)', line)
                if match:
                    state, labels = match.groups()
                    labels = [lbl for lbl in labels.split() if lbl != 'deadlock']
                    if labels:  # Only write the line if there are remaining labels
                        outfile.write(f"{state} {' '.join(labels)}\n")
                else:
                    outfile.write(line)

remove_deadlock_entries('cdp.lab', 'without-deadlock.lab')

