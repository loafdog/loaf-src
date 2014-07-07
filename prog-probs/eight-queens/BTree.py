
class TNode:
    left=None
    right=None
    data=0

    def __init__(self, data):
        self.left=None
        self.right=None
        self.data=data

class BinaryTree:
    root=None

    def __init__(self):
        self.root=None

    def newNode(self, data):
        return TNode(data)

    def insert(self, root, data):
        if (root == None):
            root = self.newNode(data)
            return root

        if (data <= root.data):
            root.left = self.insert(root.left, data)
        else:
            root.right = self.insert(root.right, data)
        return root

    def printTree(self, root):
        if (root == None):
            pass
        else:
            self.printTree(root.left)
            print "%s l=%s r=%s" % (str(root.data),
                                    str(root.left.data if root.left else None),
                                    str(root.right.data if root.right else None))
            self.printTree(root.right)

    def printTree2(self, root):
        if (root == None):
            pass
        else:
            print "%s l=%s r=%s" % (str(root.data),
                                    str(root.left.data if root.left else None),
                                    str(root.right.data if root.right else None))
            self.printTree2(root.left)
            self.printTree2(root.right)

    def printTree3(self, root):
        if (root == None):
            pass
        else:
            self.printTree3(root.left)
            self.printTree3(root.right)

            print "%s l=%s r=%s" % (str(root.data),
                                    str(root.left.data if root.left else None),
                                    str(root.right.data if root.right else None))

    def printLevelOrder(self, root, lvl, tgt):
        if (root == None):
            return 

        if (tgt == lvl):
            print root.data,
            return True
        rc1 = self.printLevelOrder(root.left, lvl+1, tgt)
        rc2 = self.printLevelOrder(root.right, lvl+1, tgt)
        if rc1 or rc2:
            return True
        return False




if __name__ == "__main__":
    btree = BinaryTree()

    # root = btree.newNode(5)
    # btree.insert(root, 1)
    # btree.insert(root, 6)
    # btree.insert(root, 2)
    # btree.insert(root, 7)

    root = btree.newNode(5)
#    for i in range(1,5):
    for i in [1,4,9]:
        data=i
        btree.insert(root, data)
    for i in [6]:
         data=i
         btree.insert(root, data)

    btree.printTree(root)
    print

    for i in range(0,10):
        rc=btree.printLevelOrder(root, 0, i)
        print
        if not rc:
            break

    print

    btree.printTree2(root)
    print
    btree.printTree3(root)
