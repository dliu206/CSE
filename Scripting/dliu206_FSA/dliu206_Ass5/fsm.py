# David Liu
# CSS 390 - Scripting
# Autumn 2020


class Edge:
    def __init__(self, edge_name, state_name, code=None):
        self.edge_name = edge_name
        self.state_name = state_name
        self.code = code

class Machine:

    def __init__(self, name):
        self.name = name
        self.state_list = []
        self.states = {}
        self.event_names = set()

    def header(self, text):
        self.header = text

    def footer(self, text):
        self.footer = text

    def state(self, state_name, action_string, edge_list=None):
        if edge_list is None:
            edge_list = []
        self.state_list.append(state_name)
        for edge in edge_list:
            self.event_names.add(edge.edge_name)

        self.states[state_name] = (action_string, edge_list)

    def edges(self, *args_list):
        e_list = []
        for arg in args_list:
            e_list.append(self.edge(*arg))
        return e_list

    def edge(self, event_name, next_state, optional_action_string=None):
        return Edge(event_name, next_state, optional_action_string)

    def gen(self):
        f = open("output.c", "w")
        self.event_names.add("INVALID")

        f.write(self.header)
        f.write("#include <iostream>\nusing namespace std;\n")

        f.write("enum State {\n")
        for state in self.state_list:
            f.write("\t" + state + "_STATE,\n")
        f.write("};\n")

        f.write("enum Event {\n")
        for event in self.event_names:
            f.write("\t" + event + "_EVENT,\n")
        f.write("};\n")

        f.write("const char * EVENT_NAMES[] = {\n")
        for event in self.event_names:
            if event != "INVALID":
                f.write("\t" + event + ",\n")
        f.write("};\n")

        f.write("Event get_next_event();\n")

        f.write("Event string_to_event(string event_string) {\n")
        for event in self.event_names:
            if event != "INVALID":
                f.write("\tif (event_string == \"" + event + "\") {return " + event + "_EVENT" + ";}\n")

        f.write("\treturn INVALID_EVENT;\n}\n")

        f.write("int " + self.name + "(State initial_state) {\n")
        f.write("\tState state = initial_state;\n\tEvent event;\n\twhile (true) {\n")
        f.write("\tswitch (state) {\n")

        for index in range(len(self.state_list)):
            f.write("\t\tcase " + self.state_list[index] + "_STATE:\n")
            f.write("\t" * 3 + "cerr << \"state " + self.state_list[index] + "\" << endl;\n")
            for line in self.states[self.state_list[index]][0].split('\n'):
                f.write("\t" * 3 + line + "\n")
            f.write("\t" * 3 + "event = get_next_event();\n\t\t\tcerr << \"event \" << EVENT_NAMES[event] << endl;\n"
                    "\t\t\tswitch (event) {\n\n")
            for edge in self.states[self.state_list[index]][1]:
                f.write("\t" * 3 + "case " + edge.edge_name + "_EVENT:\n")
                if edge.code is not None:
                    for line in edge.code.split('\n'):
                        f.write("\t" * 4 + line + "\n")
                f.write("\t" * 4 + "state = " + edge.state_name + "_STATE;\n")
                f.write("\t" * 4 + "break;\n\n")

            f.write("\t" * 3 + "default:\n")
            f.write("\t" * 4 + "cerr << \"INVALID EVENT\" << event << \" in state "
                    + self.state_list[index] + " << endl;\n")
            f.write("\t" * 4 + "return -1;\n" + "\t" * 3 + "}\n" + "\t" * 3 + "break;\n\n")

        f.write("\t" * 2 + "}\n")
        f.write("\t}\n")
        f.write("}\n")

        f.write(self.footer)
        f.close()
