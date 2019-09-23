# Minimax
def minimax(
        curr_state=None,
        mp=2,
        alpha_beta=False,
        cust_eval=False):
    global t_limit, USE_CUST_EVAL, hashDict, hashedMoves

    t_limit = float("inf")
    USE_CUST_EVAL = cust_eval

    pop_help(curr_state, mp - 1)

    if alpha_beta:
        value = alphaBeta_v2(curr_state, 0, mp - 1, float("-inf"), float("inf"))
    else:
        value = solve_tree_helper(0, mp - 1, curr_state)


def solve_tree_helper(depth, max_height, root):
    global hashedState, N_STATIC_EVALS, t_limit, starTime, hashDict
    if State(root.board).whose_turn == 'W':
        arr = hashedState[root]
        if (time.time() - starTime) * .9 > t_limit:
            return State(root.board).static_eval()
        if depth == max_height:
            m = State(arr[0].board).static_eval()
        else:
            m = solve_tree_helper(depth + 1, max_height, arr[0])
        hashDict[m] = arr[0]
        for a in range(1, len(arr)):
            if depth == max_height:
                value = State(arr[a].board).static_eval()
                hashDict[m] = arr[a]
            else:
                value = solve_tree_helper(depth + 1, max_height, arr[a])
            m = max(value, m)
        return m
    else:
        arr = hashedState[root]
        if (time.time() - starTime) * .9 > t_limit:
            return State(root.board).static_eval()
        if depth == max_height:
            m = State(arr[0]).static_eval()
        else:
            m = solve_tree_helper(depth + 1, max_height, arr[0])
        hashDict[m] = arr[0]
        for a in range(1, len(arr)):
            if depth == max_height:
                value = MY_TTS_State(arr[a]).static_eval()
                hashDict[m] = arr[a]
            else:
                value = solve_tree_helper(depth + 1, max_height, arr[a])
            m = min(value, m)
        return m


def solve_tree_with_pruning(depth, max_height, root):
    global hashDict, hashedState, alpha, beta, starTime, t_limit
    if State(root.board).whose_turn == 'W':
        if (time.time() - starTime) * .9 > t_limit:

            return State(root.board).static_eval()

        bestValue = beta
        pop_help(root, 1)
        for state in hashedState[root]:
            if depth == max_height:

                value = State(state.board).static_eval()
                hashDict[value] = state
            else:
                value = solve_tree_with_pruning(depth + 1, max_height, state)

            bestValue = max(bestValue, value)
            alpha = max(alpha, bestValue)

            if beta <= alpha:

                break
        return bestValue
    else:
        if (time.time() - starTime) * .9 > t_limit:

            return State(root.board).static_eval()

        bestValue = alpha

        for state in hashedState[root]:
            if depth == max_height:

                value = State(state.board).static_eval()
                hashDict[value] = state
            else:
                value = solve_tree_with_pruning(depth + 1, max_height, state)

            bestValue = min(bestValue, value)
            beta = min(beta, bestValue)
            if beta <= alpha:

                break

        return bestValue


def pop_help(s, depth):
    global hashedState, hashedMoves,t_limit, starTime
    if (time.time() - starTime) * 0.9 < t_limit:
        if depth >= 0:
            b = s.board
            who = s.whose_turn

            if who == 'W':
                newWho = 'B'
            else:
                newWho = 'W'

            states = []
            for i in range(len(b)):
                for j in range(len(b[0])):
                    if b[i][j] == ' ':
                        new_state = State(b)
                        new_state.board[i][j] = who
                        new_state.whose_turn = newWho

                        states.append(new_state)
                        hashedMoves[new_state] = (i, j)
                        pop_help(new_state, depth - 1)

            hashedState[s] = states


def alphaBeta(root, depth, max_height, alpha, beta):
    global hashedState, hashDict
    if depth == max_height:
        value = State(root.board).static_eval()
        hashDict[value] = root
        return value

    children = hashedState[root]
    if len(children) == 0:
        value = State(root.board).static_eval()
        hashDict[value] = root
        return value

    if State(root.board).whose_turn == 'W':
        for state in children:
            result = alphaBeta(state, depth + 1, max_height, alpha, beta)
            if result > alpha:
                alpha = result
            if alpha >= beta:
                N_CUTOFFS += 1
                return alpha
        return alpha

    if State(root.board).whose_turn == 'B':
        for state in children:
            result = alphaBeta(state, depth + 1, max_height, alpha, beta)
            if result < beta:
                beta = result
            if beta <= alpha:
                return beta
        return beta


def alphaBeta_v2(root, depth, max_height, alpha, beta):
    global hashedState, hashDict
    children = hashedState[root]

    if State(root.board).whose_turn == 'W':
        for state in children:
            if depth == max_height:
                value = tate(root.board).static_eval()
                hashDict[value] = root
            else:
                value = alphaBeta_v2(state, depth + 1, max_height, alpha, beta)
            alpha = max(alpha, value)

            if beta <= alpha:
                break
        return alpha
    else:
        for state in children:
            if depth == max_height:
                value = State(root.board).static_eval()
                hashDict[value] = root
            else:
                value = alphaBeta_v2(state, depth + 1, max_height, alpha, beta)
            beta = min(beta, value)
            if beta <= alpha:
                break
        return beta


def turn(current_state, time_limit):
    global Utterances, max_height, starTime, t_limit, prepare, hashedMoves, hashDict
    starTime = time.time()
    t_limit = time_limit

    pop_help(current_state, 2)
    value = solve_tree_with_pruning(0, 2, current_state)

    location = hashedMoves[hashDict[value]]
    new_state = State(current_state.board)
    who = current_state.whose_turn
    new_who = 'B'
    if who == 'B': new_who = 'W'
    new_state.whose_turn = new_who
    new_state.board[location[0]][location[1]] = who

    return [[location, new_state], Utterances[random.randint(0, len(Utterances) - 1)]]


def get_ready(initial_state):
    global starTime, USE_CUST_EVAL

    minimax(initial_state, 3, True, False)

    return "But uh, how do you play this game?"
