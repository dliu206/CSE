
def AStar(initial_state):

    global back_cost, COUNT, LINKS, MAX_OPEN_LENGTH, CLOSED, TOTAL_COST
    CLOSED = []
    LINKS[initial_state] = None

    OPEN = MPQ()
    OPEN.insert(initial_state, heu(initial_state))

    back_cost[initial_state] = 0.0

    while len(OPEN) > 0:

        (S, P) = OPEN.delete_min()

        CLOSED.append(S)

        if Problem.GOAL_TEST(S):
            return path
        COUNT += 1

        for op in Problem.OPS:
            if op.precond(S):
                new_state = op.state_transf(S)
                edge_cost = S.edge_distance(new_state)
                if (new_state in CLOSED):
                    new_g = back_cost[S] + edge_cost
                    if new_g < back_cost[new_state]:
                        CLOSED.remove(new_state)
                        back_cost[new_state] = back_cost[S] + edge_cost
                        OPEN.insert(new_state, new_g + heu(new_state))
                        LINKS[new_state] = S

                elif new_state in OPEN:
                    P = OPEN[new_state]
                    new_g = back_cost[S] + edge_cost + heu(new_state)
                    if new_g < P:
                        back_cost[new_state] = back_cost[S] + edge_cost
                        del OPEN[new_state]
                        OPEN.insert(new_state, new_g)
                        LINKS[new_state] = S

                else:
                    back_cost[new_state] = back_cost[S] + edge_cost
                    OPEN.insert(new_state, back_cost[S] + edge_cost + heu(new_state))
                    LINKS[new_state] = S
    return None
