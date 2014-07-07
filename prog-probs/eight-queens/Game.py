
import inspect

dbgLevel = 1

def dbg(msg, lvl=1):
    if (dbgLevel >= lvl):
        caller=inspect.stack()[1]
        frame=caller[0]
        info=inspect.getframeinfo(frame)
        print "%s():%d: %s" % (info.function,
                               info.lineno,
                               msg)


class Move:
    taken=1
    def __init__(self, taken=1):
        #dbg("new move take %d"%(taken), lvl=1)
        self.taken=taken

    def __str__(self):
        return "move take %d"%(self.taken)

    def show(self):
        print "%d coins taken" %(self.taken)

    def getUser(self, state):
        while True:
            var = raw_input("Enter 1,2,or 3:")
            num=int(var)
            if (num < 0 or num > 4):
                print "%d is not valid"%(num)
                continue
            elif (num > state.numCoins):
                print "%d is not valid. not enough coins in pile"%(num)
                continue
            else:
                self.taken=num
                return self
        return None

    def findBestMove(self, state):
        dbg("Enter %s"%(state),lvl=1)
        for numTake in [1,2,3]:
            next_state = State(state.numCoins, state.turn, state.numTurns)
            move = Move(numTake)
            if next_state.makeMove(move):
                # move is valid so eval it
                dbg("eval %s"%(move),lvl=1)
                move = self.evaluatePosition(next_state)
                dbg("move is %s"%(move),lvl=1)
                if (move != None):
                    dbg("ret take %d"%(numTake), lvl=1)
                    #return Move(numTake)
                    return move

        return None

    def evaluatePosition(self, state):
        dbg(state, lvl=1)
        if (state.isGameOver() and state.whoseTurn() == 0):
            dbg("game over %s"%(state), lvl=1)
            return None
        move=self.findBestMove(state)
        dbg("move %s"%(move), lvl=1)
        return move

    def getComputer(self, state):
        move=self.findBestMove(state)
        if move is None:
            return Move(1)
        return move


class State:
    # the board
    numCoins=0
    # whose turn it is
    turn=0
    # num turns
    numTurns=0

    def __init__(self, num=13, turn=0, numTurns=0):
        self.numCoins=num
        self.turn=turn
        self.numTurns=numTurns

    def __str__(self):
        return "coins=%d turn=%d nTurns=%d"%(self.numCoins, self.turn, self.numTurns)

    def show(self):
        #print "%d coins in pile. Player %d turn" % (self.numCoins, self.turn)
        print "Current game: %s"%(self)

    def whoseTurn(self):
        return self.turn

    def isGameOver(self):
        return self.numCoins <= 0

    def makeMove(self, move):
        if (self.numCoins - move.taken) < 0: return False
        self.numCoins -= move.taken
        if self.turn == 0: self.turn = 1
        else: self.turn = 0
        self.numTurns+=1
        return True

    def showResult(self):
        print "%d coins in pile." % (self.numCoins)
        if (self.turn == 0):
            print "Computer wins"
        else:
            print "Playa wins"

class Game:
    state=None
    def __init__(self, state=None):
        if state is None:
            self.state = State()
        else:
            self.state = state

    def play(self):
        while (not self.state.isGameOver()):
            self.state.show()
            if (self.state.whoseTurn() == 0):
                move = Move()
                move = move.getComputer(self.state)
                move.show()
            elif (self.state.whoseTurn() == 1):
                move = Move()
                move.getUser(self.state)
                move.show()
            else:
                print "unknown player turn"
                break
            self.state.makeMove(move)

        self.state.showResult()

if __name__ == "__main__":
    test_state = State(num=3)
    game=Game(test_state)
    game.play()
