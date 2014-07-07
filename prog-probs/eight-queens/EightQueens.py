import pdb
from copy import deepcopy

class Board:
    board=None

    def __init__(self, input_board=None, size=3):
        if not input_board:
            self.board = [[0]*size for i in range(size)]
        else:
            self.board = deepcopy(input_board.board)

    def size(self):
        if not self.board: return 0
        return len(self.board)

    def numOpenSpots(self):
        spots=[row.count(0) for row in self.board]
        num_spots=sum(spots)
        return num_spots

    def numQueens(self):
        queens=[row.count(9) for row in self.board]
        # count the number of queens on board
        num_queens=queens.count(1)
        return num_queens

    def rowHasQueen(self, row):
        if self.board[row].count(9) == 0:
            return False
        return True

    def getQueens(self):
        pos_list=[]
        for row, item in enumerate(self.board):
            pos_list.append(0)
            for col, val  in enumerate(item):
                #print "pos r=%d c=%d v=%d row=%s pos=%s"%(row, col, val, item, pos_list)
                if val == 9:
                    pos_list[-1]=col+1
        return tuple(pos_list)

    def printBoard(self):
        # print the board
        print '\n'.join(str(row) for row in self.board)
        num_queens=self.numQueens()
        pos_list=self.getQueens()
        print num_queens, pos_list

    def placeQueen(self, x, y):
        if x >= self.size():
            return False
        if y >= self.size():
            return False

        # set queen
        if self.board[x][y] == 0:
            self.board[x][y]=9
        else:
            #print "%d %d is %d" %(x,y,self.board[x][y])
            return False

        # fill row with ones
        for col, item in enumerate(self.board[x]):
            if item == 0:
                self.board[x][col]=1

        # fill col with ones
        for row, item in enumerate(self.board):
            if item[y] == 0:
                self.board[row][y]=1

        # down to right
        col=y
        for row, item in enumerate(self.board[x:]):
            try:
                #print "dr: col=%d row=%d item=%s" %(col,row,item)
                if item[col] == 0: item[col]=1
                col+=1
            except IndexError as e:
                break

        # up to left
        col=y-1
        for row, item in reversed(list(enumerate(self.board[:x]))):
            try:
                if col < 0: break
                #print "ul: col=%d row=%d item=%s" %(col,row,item)
                if item[col] == 0: item[col]=1
                col-=1
            except IndexError as e:
                break

        # down to left
        col=y
        for row, item in enumerate(self.board[x:]):
            try:
                if col < 0: break
                #print "dl: col=%d row=%d item=%s" %(col,row,item)
                if item[col] == 0: item[col]=1
                col-=1
            except IndexError as e:
                break

        # up to right
        col=y+1
        for row, item in reversed(list(enumerate(self.board[:x]))):
            try:
                #print "ur: col=%d row=%d item=%s" %(col,row,item)
                if item[col] == 0: item[col]=1
                col+=1
            except IndexError as e:
                break

        return True

#############################################################################

def findSolution(solutions, board, r, c):
    #print "enter %d %d lvl=%s"%(r,c,lvl)
    #board.printBoard()
    # found a solution
    if board.size() == board.numQueens():
        sol=board.getQueens()
        if sol not in solutions:
            print "found solution"
            board.printBoard()
            solutions.add(sol)
        return True

    # check if board has empty spots
    if board.numOpenSpots() == 0:
        #print "no more open spots lvl=%s"%(lvl)
        #board.printBoard()
        return False

    final_rc=True
    oldboard = Board(board)
    # for each col in row try to place a queen
    for tryc in xrange(0,board.size()):
        rc = board.placeQueen(r,tryc)
        #print "  check %d %d rc=%d lvl=%s"%(r,tryc,rc,lvl)
        #board.printBoard()
        if rc:
            tryr = r+1
            if tryr >= board.size():
                tryr=0
            rc=findSolution(solutions, board,tryr,0)
            if not rc:
                final_rc=rc
            #print "fs rc=%s lvl=%s"%(str(rc), lvl)
            board=Board(oldboard)

    if final_rc == False:
        return False

    # tried all cols in row, now try again with next row
    tryr = r+1
    if tryr >= board.size():
        tryr=0
    if board.rowHasQueen(tryr):
        #print "row %d has queen lvl=%s"%(tryr,lvl)
        return False

    rc=findSolution(solutions, board,tryr,tryc)
    return rc

def runFindSolutions(queens):
    size=queens
    solution_set=set()

    br = Board(size=size)
    print "start %d %d"%(0,0)
    findSolution(solution_set, br, 0, 0)

    for s in sorted(solution_set):
        print s

    print "%d %s"%(len(solution_set), solution_set)

if __name__ == "__main__":

    runFindSolutions(10)
