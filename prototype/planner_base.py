from operator_base import *
from predicate_evaluator import *

try:
    from Queue import PriorityQueue  # ver. < 3.0
except ImportError:
    from queue import PriorityQueue


class Plan(object):
    def __init__(self, op, head=None, tail=None):
        super(Plan, self).__init__()
        self.head = head
        self.tail = tail
        self.op = op
        self.cost = op.cost
        if self.tail is not None:
            self.cost += tail.cost

    def __str__(self):
        if self.tail is not None:
            return str(self.op) + str(self.tail)
        else:
            return str(self.op)


class PlanningProblem(object):
    """docstring for PlanningProblem"""

    def __init__(self, start, goal, plan_l, plan_r, sorted_ops):
        super(PlanningProblem, self).__init__()
        self.start = start
        self.goal = goal
        self.planL = plan_l
        self.planR = plan_r
        self.ops = sorted_ops
        self.opStack = []
        self.cost = 0
        if plan_l is not None:
            self.cost += plan_l.cost

        if plan_r is not None:
            self.cost += plan_r.cost

    def __cmp__(self, other):
        if other is None:
            return 1

        return -cmp(self.cost, other.cost)

    def __str__(self):
        return ('--PLANNING-PROBLEM--\nSTART' +
                str(self.start) + '\nGOAL' + str(self.goal) +
                '\nOperators: ' + str(self.ops) +
                '\nOp-Stack: ' + str(self.opStack))


def subsets(a):
    if not a:
        return set()

    out = set()
    subs = subsets(a[1:])

    print('subsets of ' + str(a))
    elems = a[:1][0]
    if len(elems) > 0:
        for x in elems:
            out.add(State(preds=[x]))
            for s in subs:
                out.add(s)
                out.add(State(preds=[x]).unify(s))
    else:
        return subs

    return out


class Planner(object):
    """docstring for Planner"""

    def __init__(self, pred_base, op_base):
        super(Planner, self).__init__()
        self.start = None
        self.goal = None
        self.predBase = pred_base
        self.opBase = op_base
        self.problemHeap = PriorityQueue()

    def generate_permutations(self, op, diff):
        opts = [None] * len(op.b_inst)
        print('generate permutations for: ' + str(op) + '\n' + str(diff))
        i = 0
        for x in op.b_inst:
            post_con = op.b_inst.getByTuple(x)
            opts[i] = diff.getAll(post_con.pred, post_con.val)
            i += 1

        out = set()
        subs = subsets(opts)
        for x in subs:
            ps = op.parameterizeB(x)
            if ps is not None:
                out.add(Operator(op.name, ps.a_inst, ps.b_inst, op.cost))

        return list(out)

    def build_problem(self, start, goal, plan_l, plan_r):
        diff = goal.difference(start)

        if len(diff) > 0:
            types = set()
            op_count = {}

            for d in diff:
                predinst = diff.dict[d]
                key = (predinst.pred, predinst.val)
                if not key in types:
                    types.add(key)
                    ops = self.opBase.getOperators(key[0], key[1])

                    if len(ops) == 0:
                        print('Unsolvable problem: "' + str(predinst) + '" can not be achieved!')
                        return None

                    for o in ops:
                        if o in op_count:
                            op_count[o] += 1
                        else:
                            op_count[o] = 1

            sorted_ops = map(lambda t: t[1], sorted(map(lambda t: (t[0].cost / t[1], t[0]), op_count.iteritems())))

            return PlanningProblem(start, goal, plan_l, plan_r, sorted_ops)

        return None

    def testPlan(self, constraints, plan):
        current_state = self.start
        cost = 0
        while plan.tail is not None:
            diff = plan.op.a_inst.difference(start)
            cost += op.cost
            if len(diff) == 0:
                current_state = op.a_inst.unify(current_state)
                plan = plan.tail
            else:
                plan_l = plan.head
                plan_l.cost = cost
                plan.head = None
                new_problem = self.build_problem(current_state,
                                                op.a_inst.unify(current_state),
                                                plan_l,
                                                plan)
                return False, new_problem

        return True, None

    def solve_problem(self, problem):
        print('solving problem...')
        if len(problem.opStack) == 0 and len(problem.ops) > 0:
            op = problem.ops[0]
            problem.ops = problem.ops[1:]
            diff = goal.difference(start)
            problem.opStack = self.generate_permutations(op, diff)

        if len(problem.opStack) > 0:
            for x in problem.opStack:
                print(x)

            op = problem.opStack[0]
            problem.opStack = problem.opStack[1:]

            new_diff = op.a_inst.difference(problem.start)

            if len(new_diff) > 0:
                new_problem = self.build_problem(problem.start,
                                                 op.a_inst,
                                                 problem.planL,
                                                 Plan(op, tail=problem.planR))
                if new_problem is not None:
                    self.problemHeap.put(new_problem)
            else:
                plan = Plan(op, head=problem.planL, tail=problem.planR)
                while plan.head is not None:
                    plan = plan.head

                ok, new_problem = self.testPlan(None, plan)

                if ok:
                    return plan
                else:
                    self.problemHeap.put(new_problem)

        return None

    def init_planner(self, start, goal):
        initial_problem = self.build_problem(start, goal, None, None)
        print(initial_problem)
        self.start = start
        self.goal = goal
        if initial_problem is not None:
            self.problemHeap.put(initial_problem)
            return True
        else:
            return False

    def get_next_plan(self):
        plan = None
        # while plan == None and not self.problemHeap.empty():
        next_problem = self.problemHeap.get()
        print(next_problem)
        plan = self.solve_problem(next_problem)

    # if plan != None:
    # 	return plan, 'Planning successful'
    # else:
    # 	return None, 'Planning failed! Out of options!'


if __name__ == '__main__':
    ppool = PredicatePool()
    ppool.loadFromXML('Test_Predicates.xml')

    oppool = OperatorPool()
    oppool.loadFromXML('Test_Operators.xml', ppool)

    planner = Planner(ppool, oppool)

    pi_1f = PredicateInstance(ppool['onTop'], ('apple', 'table'), False)
    pi_1t = PredicateInstance(ppool['onTop'], ('apple', 'table'), True)
    pi_2f = PredicateInstance(ppool['grasped'], ('apple',), False)
    pi_3f = PredicateInstance(ppool['container'], ('table',), False)

    baseState1 = State(preds=[pi_1f, pi_2f, pi_3f])
    evaluator = PseudoEvaluator(baseState1)

    start = State(evaluator=evaluator)
    goal = State(preds=[pi_1t])

    planner.init_planner(start, goal)
    for x in range(3):
        plan = planner.get_next_plan()

    print(plan)
