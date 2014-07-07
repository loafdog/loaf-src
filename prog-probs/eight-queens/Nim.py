
def dbg(msg):
    return

class Nim:
    whoseTurn=0

    def __init__(self, turn=1):
       self.whoseTurn=turn

    def userTurn(self, num_coins):
        while True:
            var = raw_input("There are %d coins left. Enter 1,2,or 3:" % 
                            (num_coins))
            num=int(var)
            if (num < 0 or num > 4):
                print "%d is not valid"%(num)
                continue
            elif (num > num_coins):
                print "%d is not valid. not enough coins in pile"%(num)
                continue
            else:
                break

        return num

    def computerTurn(self, num_coins):
        take=self.findMove(num_coins)
        if take == -1:
            return 1
        return take

    def findMove(self, num_coins):
        dbg("findMove %d"%(num_coins))
        for numTake in [1,2,3]:
            dbg("findMove try %d"%(numTake))
            tmp_coins = num_coins - numTake
            if (self.isPositionBad(tmp_coins) == True):
                dbg("findMove ret take %d"%(numTake))
                return numTake

        dbg("findMove ret take -1")
        return -1

    def isPositionBad(self, num_coins):
        dbg("isPosBad %d"%(num_coins))
        if (num_coins <= 1):
            dbg("isPosBad %d ret True"%(num_coins))
            return True

        if self.findMove(num_coins) == -1:
            dbg("isPosBad %d ret False"%(num_coins))
            return True

        dbg("isPosBad %d ret2 True"%(num_coins))
        return False

    def playGame(self, coins):
        num_coins=coins
        while True:
            take=self.computerTurn(num_coins)
            num_coins -= take
            print "Computer took %d coins"%(take)
            if (num_coins <= 0):
                print "You win, computer lose"
                return

            take=self.userTurn(num_coins)
            num_coins -= take
            if (num_coins <= 0):
                print "Computer wins, you lose"
                return


if __name__ == "__main__":
    game=Nim(0)
    game.playGame(13)

