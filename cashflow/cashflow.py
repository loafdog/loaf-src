#!/usr/bin/python
# from __future__ import print_function
import pdb
import re
import pprint
import json
import shutil
import os
import pygal
import sys

from abc import ABCMeta, abstractmethod

# from locale import currency
# locale.setlocale( locale.LC_ALL, '' )

pp = pprint.PrettyPrinter(width=100)

class Txn(object):
    """
    """
    
    __metaclass__ = ABCMeta

    def __init__(self):
        self.categories = {}
        
    # def __str__(self):
    #     return __repr__()
    
    def __repr__(self):
        tmp = ""
        tmp += 'src={} '.format(self.src)
        if hasattr(self, 'idnum'):
            tmp = "{1} id=[{0}] ".format(self.idnum, tmp)
            
        tmp+="date=[{0}] "\
            "ttype=[{1}] "\
            "info=[{2}] "\
            "amt=[{3}] ".format(self.date,
                               self.ttype,
                               self.info,
                               self.amt)
        if hasattr(self, 'balance'):
            tmp = "{1} id=[{0}] ".format(self.balance, tmp)

        if hasattr(self, 'check') and self.check:
            tmp += "check=[{0}]".format(self.check)
            
        return tmp

    def jdefault(o):
        return o.__dict__
    
    def add_category(self, category):
        self.categories[category.name] = category

    def validate(self):
        if not self.info or self.info == "":
            raise ValueError('invalid info: [{0}] {1}'.format(self.info, self))

    def normalize_date(self):
        (m,d,y) = self.date.split('/')
        # > tells field to be right align, and 0 before > says pad
        # with zeros.  If you use < then instead of 01 you get 10 b/c
        # 1 gets left align and right of 1 gets padded with zero.
        self.date = '{0:0>2}/{1:0>2}/{2}'.format(m,d,y)
         
    @abstractmethod
    def desc(self):
        pass

    @abstractmethod
    def check_num(self):
        pass

class BankTxn(Txn):
    """
    """
    
    def __init__(self, idnum, date, ttype, info, amt, balance, check, src='Bank'):
        Txn.__init__(self)
        self.date = date
        self.normalize_date()
        if 'SH DRAFT'.lower() in ttype.lower() and info == '':
            self.ttype = 'SH DRAFT'
            #self.info = ttype.replace('SH DRAFT', '').replace('sh draft', '')
            # self.info = ttype.replace('sh draft', '').replace('SH DRAFT', '')
            self.info = ttype.replace('sh draft', '')
            self.info = self.info.replace('SH DRAFT', '')
        elif 'WITHDRAW'.lower() in ttype.lower() and info == '':
            self.ttype = 'WITHDRAW'
            self.info = ttype.replace('WITHDRAW', '')
        else:
            self.ttype = ttype
            self.info = info
        self.amt = amt
        self.balance = balance
        self.check = check
        self.idnum = idnum.replace(self.check, '')
        self.src = src

    def desc(self):
        """Return string used to match txn with category

        """
        if "TRANSFER" in self.ttype:
            return self.ttype + " " + self.info           
        elif "SH DRAFT" in self.ttype:
            if self.info == '':
                return self.ttype
        elif "DEPOSIT" in self.ttype:
            if self.info == '':
                return self.ttype
            
        return self.info

    def check_num(self):
        if "SH DRAFT" in self.ttype:
            return self.check
        return ''

    def is_deposit(self):
        if "DEPOSIT" in self.ttype:
            return True
        return False

    def is_no_info(self):
        if self.info == '':
            return True
        return False
            
class CcTxn(Txn):
    """
    """
    
    def __init__(self, date, ttype, info, amt, src='cc'):
        Txn.__init__(self)
        self.date = date
        self.normalize_date()
        self.ttype = ttype
        self.info = info
        self.amt = amt
        self.src = src

    def desc(self):
        """Return string used to match txn with category

        """
        return self.info
            
    def check_num(self):
        return ''
    
class Category(object):

    def __init__(self, name, pattern=None):
        self.name = name
        if pattern is None:
            self.pattern = name
        else:
            self.pattern = pattern

        self.compiled_pattern = re.compile(self.pattern, re.I)
        self.total = 0
        self.txns = []
        
    def __repr__(self):
        return "{0} {1}".format(self.name, self.total)

    def add_txn(self, txn):
        self.txns.append(txn)
        try:
            self.total += float(txn.amt)
            txn.add_category(self)
        except ValueError:
            print >>sys.stderr, 'float convert fail: {0}'.format(txn)
            raise
        except TypeError:
            print >>sys.stderr, 'float convert fail: {0}'.format(txn)
            raise
        
    def print_txns(self, details=False, rfd=None):
        if self.total == 0:
        #    pass
            return
        msg = "total={0:10.2f} name={1:40} num={2}".format(self.total, self.name, len(self.txns))

        if not details:
            # report.txt
            print >>rfd, msg
            return
            
        print >>rfd, '-'*80
        print >>rfd, msg
        
        # sort txns by date
        st = sorted(self.txns, key=lambda tx: tx.date)
        for t in st:
            msg = "{0:10} [{2:10.2f}] {1:3} {4:5} {3} ".format(t.date,
                                                            t.src,
                                                            t.amt,
                                                            t.desc(),
                                                            t.check_num())
            
            print >>rfd, '  {0}'.format(msg)

        msg = "{0:10} [{1:10.2f}]".format('Total',
                                          self.total)
        print >>rfd, '  {0}'.format(msg)

class Categories(object):
    """How to classify txns.  The info section of a txn is matched against
    a categories pattern. Read in cats from a file. A hacky thing is
    cats subtotal. Maybe should be a separate class from here? Maybe
    in addition to Category create a CategorySubtotals? It would
    contain a hash of Categories that matched prefix only. Would
    replace cat_totals.

    """
    
    def __init__(self, input_file):
        self.cats = {}
        self.cat_totals = {}

        self.input_file = input_file
        self.cats['unknown'] = Category('unknown', None)
       
    def __repr__(self):
        return "Num Cats={0}   "\
            "Sub Cats={1}".format(len(self.cats), len(self.cat_totals))

    def dump(self):
        pp.pprint(self.cats)
        pp.pprint(self.cat_totals)

    def to_safe_pattern(self, pattern):
        if pattern[-1] == '|':
            pattern[-1] = ''
        pattern = pattern.replace('*','\\*')
        pattern = pattern.replace('\\\\','\\')
        pattern = pattern.replace('||','|')
        return pattern
    
    def read_file(self):
        with open(self.input_file) as f:
            for line in f:
                if re.match('^#', line) or not line:
                    continue
                parts = line.rstrip('\n').split('=')
                if len(parts) != 2:
                    continue
                (name, pattern) = parts
                pattern = self.to_safe_pattern(pattern)
                # print pattern
                if name == 'cat':
                    c = Category(pattern)
                    self.cat_totals[pattern] = c
                else:
                    c = Category(name, pattern)
                    self.cats[name] = c

    def find_match(self, txn):
        """Given a txn search all cats for a match.  If match found return the
        specific cat obj that matches and group cat obj.
        If no match is found return unknown cat obj.

        """
        # print "MATCHING {0}".format(txn)
        for c in self.cats:

            # print "    pattern[{0}]".format(self.cats[c].pattern)
            
            #p = re.compile(self.cats[c].pattern, re.I)
            p = self.cats[c].compiled_pattern
            m = p.search(txn.desc())
            # pdb.set_trace()
            # m = re.search(self.cats[c].pattern, txn.desc(), re.I)
            if m != None:
                #print "  MATCH [{0}] in {1}=[{2}]".format(txn.desc(), c,
                #                                         self.cats[c].pattern)

                # take the category name, split on _, take first
                # item and use as key in cat_totals. 
                group_cat = None
                parts = c.split('_')
                group_cat_name = parts[0]
                if group_cat_name in self.cat_totals:
                    group_cat = self.cat_totals[group_cat_name]

                return (self.cats[c], group_cat)
        
        print "NO MATCH txn desc=[{0}] [{1}]".format(txn.desc(), txn)
        return (self.cats['unknown'], None)
            
    def print_txns(self, details=False, rfd=None):
        for c in sorted(self.cats.iterkeys()):
            self.cats[c].print_txns(details, rfd)
        # report.txt
        print >>rfd, '='*80
                    
class InputFile(object):
    """ ABC to represent lines from a txn input file
    """
    
    __metaclass__ = ABCMeta
    
    def __init__(self, input_dir, txn_file, src):
        self.input_dir = input_dir
        self.txn_file = txn_file
        self.src = src
        
        self.lines = []
        self.id_idx = -1
        self.date_idx = -1
        self.ttype_idx = -1
        self.desc_idx = -1
        self.debit_idx = -1
        self.credit_idx = -1

        self.balance_idx = -1
        self.check_idx = -1
        self.max_idx = 0

    # def __str__(self):
    #     return '{} {}'.format()

    def __repr__(self):
         return '  {} {}\n  num_lines={} max_idx={} id={} date={} ttype={} desc={} debit={} credit={} bal={} check={}'.format(
             self.input_dir, self.txn_file,
             len(self.lines),
             self.max_idx,
             self.id_idx,
             self.date_idx,
             self.ttype_idx,
             self.desc_idx,
             self.debit_idx,
             self.credit_idx,
             self.balance_idx,
             self.check_idx
             )

    def read_file(self):
        input_file = os.path.join(self.input_dir, self.txn_file)
        try:
            with open(input_file) as f:
                for line in f:
                    if re.match('^#', line) or not line:
                        continue
                    self.lines.append(line)
        except IOError:
            print 'Warn: {0} not found'.format(input_file)

#    @abstractmethod
    def parse():
        pass

    def parse_lines_header(self):
        try:
            parts = self.lines[0].rstrip('\n').replace('"','').split(',')
        except IndexError:
            print >>sys.stderr, '{}'.format(self)
            raise

        if len(parts) < 1:
            print >>sys.stderr, 'Warn: line is invalid len(parts)={0}: [{1}]'.format(len(parts),
                                                                               self.lines[0])
            print >>sys.stderr, self
            exit -1
        
        if len(parts) < 5:
            print >>sys.stderr, 'Warn: line is invalid len(parts)={0}: [{1}]'.format(len(parts),
                                                                               self.lines[0])
            print >>sys.stderr, self
            exit -1

        max_idx = 0
        for i, p in enumerate(parts):
            if 'Date' in p:
                self.date_idx = i
                max_idx = i if i > max_idx else max_idx
            elif ('Description' == p):
                if (self.src == 'DCU'):
                    self.ttype_idx = i
                    max_idx = i if i > max_idx else max_idx
                else:
                    self.desc_idx = i
                    max_idx = i if i > max_idx else max_idx
            elif 'Transaction' == p:
                self.ttype_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Payee' == p or 'Memo' == p:
                self.desc_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Debit' in p:
                self.debit_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Credit' in p:
                self.credit_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Amount' in p:
                self.debit_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Balance' in p:
                self.balance_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Check Number' in p:
                self.check_idx = i
                max_idx = i if i > max_idx else max_idx
            elif 'Transaction Number' in p:
                self.id_idx = i
                max_idx = i if i > max_idx else max_idx
            else:
                pass
        if max_idx < 1:
            print >>sys.stderr, 'Header line missing? max_idx={}\n{}'.format(max_idx, self)
            print >>sys.stderr, 'Exiting on error...'
            sys.exit(1)
        self.max_idx = max_idx
        
    def parse_lines(self):
        txns = []
        for line in self.lines[1:]:
            t = self.parse_line(line)
            if t:
                txns.append(t)
        return txns
        
    def parse_line(self, line):
        # TODO can i parse a line for any txn in ABC? If parse returns
        # a txn how do i know what kind of txn to return?
        
        # print 'Parsing lines for {0}'.format(self)
        # for line in lines:
        #     txn = line.parse()
        #     if txn is not None:
        #         self.txns.append(txn)
        
        if not line or line == '\n':
            # print 'Warn: line is empty:[{0}]'.format(line)
            return None

        # some input files have , inside "" fields. That messes up the
        # split big time. So remove the comma inside quoted field.
        # Only remove one such thing in a line. If more than one field
        # with comma in a line need to add some more code here
        #
        m = re.search('("[^",]+?,[^",]+?")', line)
        if m:
            #print >>sys.stderr,'comma in quotes in line: [{}]\n\t{}'.format(m.group(1), line)

            # Now get rid of comma in match string. Then replace the
            # match with de-comma'd string. boo yah.
            tmp = re.sub(',', '', m.group(1))
            line = re.sub(m.group(1), tmp, line)
            #print >>sys.stderr,'new line: [{}]'.format(line)
        
        # If a split results in parts array that does not equal parts
        # determined in parse header we have a problem.  Well equal is
        # too strong.  We don't parse entire header of each input
        # file.  Don't care about some fields.  So at least check to
        # see if we have less parts than we know about from header.
        parts = line.rstrip('\n').replace('"','').split(',')
        if len(parts) < self.max_idx:
            print 'Warn: line is invalid len parts={0} max_idx={1} [{2}]'.format(len(parts),
                                                                                 self.max_idx,
                                                                                 parts)
            return None

        idnum = parts[self.id_idx]
        date = parts[self.date_idx]
        ttype = parts[self.ttype_idx]
        info = parts[self.desc_idx]
        balance = parts[self.balance_idx]
        check = parts[self.check_idx]
        
        amt = None
        if parts[self.debit_idx] != '':
            try:
                amt = float(parts[self.debit_idx])
                if amt > 0: amt*=-1
            except ValueError:
                print >>sys.stderr, 'Bad debit amt={} parts={}\n{}'.format(parts[self.debit_idx],
                                                                           parts, self)
                raise
        elif parts[self.credit_idx] != '':
            try:
                amt = float(parts[self.credit_idx])
            except ValueError:
                raise ValueError('No amt found in line parts: {0}'.format(parts))
        else:
            print >>sys.stderr, '{}'.format(self)
            print >>sys.stderr, 'No amt found in line parts: debit_idx={0} credit_idx={1} {3}'.format(self.debit_idx, self.credit_idx, parts)
            sys.exit(1)

        if self.check_idx > 0:
            txn = BankTxn(idnum, date, ttype, info, amt, balance, check, self.src)
        else:
            txn = CcTxn(date, ttype, info, amt, self.src)
        return txn
                
    def dump_raw_lines(self):
        return self.lines

class Institution(object):
    """
    A bank or credit card company

    Attributes:
      name
      txn_file
    """
    
    __metaclass__ = ABCMeta

    def __init__(self, name, report_name, input_dir, txn_files,
                 check_file=None, deposit_file=None):
        self.name = name
        self.report_name = report_name
        self.input_dir = input_dir
        self.txn_files = txn_files
        self.input_files = []
        for f in txn_files:
            self.input_files.append(InputFile(input_dir, f, report_name))

        self.check_file = check_file
        self.deposit_file = deposit_file

        self.txns = []

    # def __str__(self):
    #     return self.name

    def __repr__(self):
        return '{} num_txns={}\n{}'.format(
            self.name,
            len(self.txns),
            self.input_files
            )
    
    def parse_input(self):
        for f in self.input_files:
            f.read_file()
            f.parse_lines_header()
            self.txns += f.parse_lines()
    
    def dump_txns(self):
        return self.txns

    def match_txns(self, categories):
        print '\nMatching txns for {0}'.format(self)
        for t in self.txns:
            # if txn is a check get desc/info from checks
            # if check
            
            (c, group) = categories.find_match(t)
            #print "  txn: {0}".format(t)
            #print "  cat: {0}".format(c)
            c.add_txn(t)
            if group:
                #print 'Adding {0} to group {1}'.format(t, group)
                group.add_txn(t)

    # @abstractmethod                
    # def add_line(self, line):
    #     pass

    
    def update_check_file(self):
        pass

    def update_deposit_file(self):
        pass
    
class Dcu(Institution):
    def __init__(self, name, input_dir, txn_files, check_file, deposit_file):
        Institution.__init__(self, name, 'DCU', input_dir, txn_files, check_file, deposit_file)

    def update_deposit_file(self):
        dep_txns = {}
        input_file = os.path.join(self.input_dir, self.deposit_file)
        try:
            # open file to read in mappings.  If no file that's ok,
            # must be 1st time running.
            with open(input_file) as f:
                dep_txns = json.load(f)
                shutil.copy2(input_file, "{0}.bak".format(input_file))
        except IOError:
            print 'Warn: {0} not found'.format(input_file)
            
        #pp.pprint(dep_txns)

        # is a hash of txn id num -> desc/info
        #
        for txn in self.txns:
            if txn.is_deposit():
                if txn.is_no_info():
                    if txn.idnum in dep_txns:
                        txn.info = dep_txns[txn.idnum]['info']
                    else:
                        dep_txns[txn.idnum] = {
                            'date': txn.date,
                            'info': txn.info,
                            'amt': txn.amt
                        }

        # Save mapping file
        with open(input_file, 'w') as f:
            json.dump(dep_txns, f, indent=4, sort_keys=True)

    def update_check_file(self):
        checks = {}
        input_file = os.path.join(self.input_dir, self.check_file)
        try:
            with open(input_file) as f:
                checks = json.load(f)
                shutil.copy2(input_file, "{0}.bak".format(input_file))
        except IOError:
            print 'Warn: {0} not found'.format(input_file)
            
        #pp.pprint(checks)

        # checks is a hash of check num -> desc/info
        #
        for txn in self.txns:
            num = txn.check_num()
            if num == '':
                # not a check
                continue
            # Why is json file getting output with info set to SH
            # DRAFT? should be blank.
            # pdb.set_trace()
            if num in checks:
                # use check mapping file info value
                txn.info = checks[num]['info']
            else:
                # some txn files i hand edited to add info bout check
                # num. added it before SH DRAFT text but in same
                # column in txn.
                checks[num] = {
                    'date': txn.date,
                    'info': txn.info,
                    'amt': txn.amt
                    }
        
        with open(input_file, 'w') as f:
            json.dump(checks, f, indent=4, sort_keys=True)
    
class Fidelity(Institution):
    def __init__(self, name, input_dir, txn_files, check_file, deposit_file):
        Institution.__init__(self,name, 'FID', input_dir, txn_files, check_file, deposit_file)

class CapitalOne(Institution):
    def __init__(self, name, input_dir, txn_files, check_file, deposit_file):
        Institution.__init__(self, name, 'CAP', input_dir, txn_files, check_file, deposit_file)

class Chart(object):

    def __init__(self, reports, output_dir):
        self.reports = reports
        self.output_dir = output_dir

    def draw(self):

        ch = pygal.Bar()
        ch.title = self.reports[0].title
        ch.x_labels = self.reports[0].names

        sr = sorted(self.reports, key=lambda r: r.year)
        for r in sr:
            print r
            chart = pygal.Bar()
            chart.title = '{0} {1}'.format(r.title, r.year)
            chart.x_labels = r.names
            chart.add(r.year, r.series)
            chart_file = os.path.join(self.output_dir, '{0}_{1}.svg'.format(r.title, r.year))
            chart.render_to_file(chart_file)

            ch.add(r.year, r.series)

        all_chart_file = os.path.join(self.output_dir, '{0}_all.svg'.format(ch.title))
        ch.render_to_file(all_chart_file)
        
class Report(object):
    """
    """
    
    def __init__(self, year, categories, freport):
        self.year = year
        self.categories = categories
        self.freport = freport
        self.series = []
        self.total = 0

    def __repr__(self):
        return '{0}:{1:.2f}:{2}:\n\t{3}'.format(self.year, self.total, self.title, self.series)
    
    def print_line(self, name, **kwargs):
        # print_line('catA') prints total for catA
        # print_line('msg', val) prints msg and val
        if 'amt' in kwargs:
            total = kwargs['amt']
        elif name in self.categories.cats:
            total = self.categories.cats[name].total
        elif name in self.categories.cat_totals:
            total = self.categories.cat_totals[name].total
        else:
            raise ValueError('No key [{0}] in categories'.format(name))

        # report.txt
        print >>self.freport, "{1:10.2f} :: {0:20} ".format(name, total)
        return total

class FmfrrReport(Report):
    names = ['fmfrr_payment']
    title = 'fmfrr'

    def run(self):
        self.total = 0
        self.series = []

        print >>self.freport, """
        FMFRR: Deposits should be zero.
        If diff is negative I'm owed. If positive I owe.
        """
        cats = self.categories.cats

        name = 'fmfrr_payment'
        payments = cats[name].total
        self.print_line(name)

        name = 'fmfrr_transfer'
        xfers = cats[name].total
        self.print_line(name)

        self.print_line('fmfrr diff', amt=payments+xfers)
        # report.txt
        print >>self.freport, "-"*80

        
class FixedReport(Report):
    names = sorted(['insurance', 'loans', 'mortgage', 'taxes', 'util'])
    title = 'Fixed Total'

    def run(self):
        self.total = 0
        self.series = []
        
        for name in sorted(self.names):
            self.print_line(name)
            val = self.categories.cat_totals[name].total
            self.total += val
            self.series.append(val)

        print >>self.freport, "-"*30
        self.print_line(self.title, amt=self.total)
        print >>self.freport, "-"*80

class VarReport(Report):
    names = sorted([
            'beauty',
            'car',
            'clothes',
            'dining',
            'grocery',
            'health',
            'house',
            'karenbaking',
            'karenwork',
            'kids',
            'hobby',
            'misc',
            'sport',
            'travel'
        ])
    title = 'Var Total'
    
    def run(self):
        self.total = 0
        self.series = []

        for name in sorted(self.names):
            self.print_line(name)
            val = self.categories.cat_totals[name].total
            self.total += val
            self.series.append(val)

        # report.txt            
        print >>self.freport, "-"*30
        self.print_line(self.title, amt=self.total)
        print >>self.freport, "-"*80

class AllSubCatOutcomeReport(Report):

    def __init__(self, year, categories, freport, cat_total):
        Report.__init__(self, year, categories, freport)
        self.cat_total = cat_total
        self.title = '{} Total'.format(cat_total.name)

    def run(self):
        self.names = []
        for c in self.categories.cats:
            #if self.cat_total.name in c:
            if c.startswith(self.cat_total.name):
                self.names.append(c)
                    
        self.total = 0
        self.series = []
        self.names = sorted(self.names)
        for name in self.names:
            self.print_line(name)
            val = self.categories.cats[name].total
            # technically total is already calculated in the cat_total
            # object.  don't need to re-add vals up here.
            self.total += val
            self.series.append(val)

        # report.txt            
        print >>self.freport, "-"*30
        self.print_line(self.title, amt=self.total)
        print >>self.freport, "-"*80

class SavingsReport(Report):
    names = sorted(['investment', 'college', 'savings'])
    title = 'Savings'

    def run(self):
        self.total = 0
        self.series = []

        for name in sorted(self.names):
            self.print_line(name)
            val = self.categories.cat_totals[name].total
            self.total += val
            self.series.append(val)
            #self.print_line(name)
            #total += self.categories.cat_totals[name].total

        print >>self.freport, "-"*30
        self.print_line(self.title, amt=self.total)
        print >>self.freport, "-"*80

class IncomeReport(Report):
    names = ['income']
    title = 'Income'
        
    def run(self):
        self.total = 0
        self.series = []

        for name in sorted(self.names):
            self.print_line(name)
            val = self.categories.cat_totals[name].total
            self.total += val
            self.series.append(val)
        #self.total = self.categories.cat_totals['income'].total
        print >>self.freport, "-"*30
        self.print_line(self.title, amt=self.total)
        print >>self.freport, "-"*80    

#############################################################################


conf = {
    'cats': '/Users/mwiczynski/data/private/cashflow_data/2016/cashflow.cat',
    'report_dir': '/Users/mwiczynski/data/private/cashflow_data/reports',
    'chart_dir': '/Users/mwiczynski/data/private/cashflow_data/charts',
    'years': {
        '2016': {
            'input_dir': '/Users/mwiczynski/data/private/cashflow_data/2016',
            'insts': {
                'DCU': {
                    'txn_files': ['dcu-checking-2016.csv'],
                    'check_file': 'dcu-checks-2016.json',
                    'deposit_file': 'dcu-deposits-2016.json'
                },
                'Fidelity': {
                    'txn_files': ['fid-2016.csv']
                },
                'CapOne': {
                    'txn_files': ['capone-credit-2016.csv']
                }
            }
        },
        '2015': {
            'input_dir': '/Users/mwiczynski/data/private/cashflow_data/2015',
            'insts': {
                'DCU': {
                    'txn_files': ['dcu-checking-2015.csv'],
                    'check_file': 'dcu-checks-2015.json',
                    'deposit_file': 'dcu-deposits-2015.json'
                },
                'Fidelity': {
                    'txn_files': ['fid-2015.csv']
                },
                'CapOne': {
                    'txn_files': ['capone-credit-1-2015.csv', 'capone-credit-2-2015.csv']
                }
            }
        },
        '2014': {
            'input_dir': '/Users/mwiczynski/data/private/cashflow_data/2014',
            'insts': {
                'DCU': {
                    'txn_files': ['dcu-checking-2014.csv'],
                    'check_file': 'dcu-checks-2014.json',
                    'deposit_file': 'dcu-deposits-2014.json'
                },
                'Fidelity': {
                    'txn_files': ['fid-2014.csv']
                },
                'CapOne': {
                    'txn_files': ['capone-2014.csv']
                }
            }
        }
    }
}

def doit(conf):
    reports = {}
    years = conf['years']
    for year in years:
        print '='*80
        print year
        banks = []
        input_dir = years[year]['input_dir']

        insts = years[year]['insts']
        for ikey in insts:
            if 'check_file' in insts[ikey]:
                cfile = insts[ikey]['check_file']
            else:
                cfile = None

            if 'deposit_file' in insts[ikey]:
                dfile = insts[ikey]['deposit_file']
            else:
                dfile = None

            # TODO can i figure out a way to create class by
            # institution class instead of specific subclass?
            
            if ikey == 'DCU':
                inst = Dcu(ikey,
                           input_dir,
                           insts[ikey]['txn_files'],
                           cfile, dfile)
            elif ikey == 'Fidelity':
                inst = Fidelity(ikey,
                                input_dir,
                                insts[ikey]['txn_files'],
                                cfile, dfile)
            elif ikey == 'CapOne':
                inst = CapitalOne(ikey,
                                  input_dir,
                                  insts[ikey]['txn_files'],
                                  cfile, dfile)
            else:
                inst = None

            banks.append(inst)
    
        for i in banks:
            i.parse_input()
            print i
            #i.dump_raw_lines()

        for i in banks:
            i.update_check_file()
            i.update_deposit_file()

        cats = Categories(conf['cats'])
        cats.read_file()

        for i in banks:
            i.match_txns(cats)

        # Generate reports
        if not os.path.exists(conf['report_dir']):
            os.makedirs(conf['report_dir'])
        if not os.path.exists(conf['chart_dir']):
            os.makedirs(conf['chart_dir'])

        report_file = os.path.join(conf['report_dir'], 'report_{0}.txt'.format(year))
        if os.path.isfile(report_file):
            shutil.copy2(report_file, "{0}.bak".format(report_file))
            
        freport = open(report_file, 'w')

        cats.print_txns(details=True, rfd=freport)
        cats.print_txns(details=False, rfd=freport)

        # r = FmfrrReport(year, cats, freport)
        # reports.append(r)

        r = FixedReport(year, cats, freport)
        if r.title not in reports:
            reports[r.title] = []
        reports[r.title].append(r)

        r = VarReport(year, cats, freport)
        if r.title not in reports:
            reports[r.title] = []
        reports[r.title].append(r)

        # r = SavingsReport(year, cats, freport)
        # reports.append(r)
        # r = IncomeReport(year, cats, freport)
        # reports.append(r)

        for ct in sorted(cats.cat_totals):
            r = AllSubCatOutcomeReport(year, cats, freport, cats.cat_totals[ct])
            if r.title not in reports:
                reports[r.title] = []
            reports[r.title].append(r)

        for key in reports.iterkeys():
            for r in reports[key]:
                r.run()
            chart = Chart(reports[key], conf['chart_dir'])
            chart.draw()
                


def cash2014():
    insts = []
    input_dir = '/Users/mwiczynski/data/private/cashflow_data/2015'
    dcu = Dcu('DCU',
              input_dir,
              'dcu-checking-2015.csv',
              'dcu-checks-2015.json',
              'dcu-deposits-2015.json')
    insts.append(dcu)
    fid = Fidelity('Fidelity',
                   input_dir,
                   'fid-2015.csv')
    insts.append(fid)
    cap = CapitalOne('CapOne',
                     input_dir,
                     'capone-credit-2015.csv')
    insts.append(cap)

    doit(insts, input_dir)

def cash2015():
    print '='*80
    insts = []
    input_dir = '/Users/mwiczynski/data/private/cashflow_data/2015'
    dcu = Dcu('DCU',
              input_dir,
              'dcu-checking-2015.csv',
              'dcu-checks-2015.json',
              'dcu-deposits-2015.json')
    insts.append(dcu)
    fid = Fidelity('Fidelity',
                   input_dir,
                   'fid-2015.csv')
    insts.append(fid)
    cap = CapitalOne('CapOne',
                     input_dir,
                     'capone-credit-2015.csv')
    insts.append(cap)

    doit(insts, input_dir)

def cash2016():
    print '='*80
    insts = []
    input_dir = '/Users/mwiczynski/data/private/cashflow_data/2016'
    dcu = Dcu('DCU',
              input_dir,
              'dcu-checking-2016.csv',
              'dcu-checks-2016.json',
              'dcu-deposits-2016.json')
    insts.append(dcu)
    fid = Fidelity('Fidelity',
                   input_dir,
                   'fid-2016.csv')
    insts.append(fid)
    cap = CapitalOne('CapOne',
                     input_dir,
                     'capone-credit-2016.csv')
    insts.append(cap)
        
    doit(insts, input_dir)

def test():
    print '='*80
    insts = []
    input_dir = './test'
    dcu = Dcu('DCU',
              input_dir,
              'test-dcu.csv',
              'dcu-checks-test.json',
              'dcu-deposits-test.json')
    insts.append(dcu)
    fid = Fidelity('Fidelity',
                   input_dir,
                   'fid-2015.csv')
    insts.append(fid)
    cap = CapitalOne('CapOne',
                     input_dir,
                     'capone-credit-2015.csv')
    insts.append(cap)

    doit(insts, input_dir)
        
#dcu = Dcu('DCU', '/Users/mwiczynski/data/private/2015/dcu/Export.txn')
#dcu = Dcu('DCU', '/Users/mwiczynski/data/private/2015/dcu-checking-2015.txn')
# dcu = Dcu('DCU', 'test-dcu.txn')
#dcu = Dcu('DCU', 'Export.txn')

#dcu = Dcu('DCU', '/Users/mwiczynski/data/private/cashflow_data/2015/dcu-checking-2015.txn')
#dcu = Dcu('DCU', '/Users/mwiczynski/data/private/cashflow_data/2016/dcu-checking-2016.txn')
#insts.append(dcu)
#fid = Fidelity('Fidelity', '/Users/mwiczynski/data/private/cashflow_data/2015/fid-2015.txn')
# fid = Fidelity('Fidelity', '/Users/mwiczynski/data/private/cashflow_data/2016/fid-2016.txn')
# insts.append(fid)
#cap = CapitalOne('CapOne', '/Users/mwiczynski/data/private/cashflow_data/2015/capone-credit-2015.txn')
# cap = CapitalOne('CapOne', '/Users/mwiczynski/data/private/cashflow_data/2016/capone-credit-2016.txn')
# insts.append(cap)

#test()
# cash2015()
# cash2016()

doit(conf)




#############################################################################
# DONE
# parse 2015 dcu file and create txns
# read cat file and create classes
#
# match dcu txns with categories
# print a report
#  categories totals need to be figured
#
# DONE check matching.. used to edit the dcu file to add something to SH
# DRAFT section. bad idea.. don't edit txn file so it can be
# downloaded again. what about a mapping file.. check num -> desc/info
# field. what format? start with json.  generate mapping file
# automatically from dcu txn. Look for SH DRAFT entries. Create a hash
# of check num -> info.  write hash to file.  First try to read file
# in.  That way changes are not lost.  
#
# DONE Blank deposits need annotation just like checks


# TODO
#
# 2014 report shows lots of errors.. 
# - amt from capone should be neg or pos depending if in 3,4, or 5?
#
# LOANS
# - add outstanding amt on loans, honda, heloc, school to report
#
# run on 2015 and compare to perl version.
# - house is off, due to heloc acct method
# - misc off
#
# DONE sort of.  rename dcutxn to banktxn.  make institution generic? remove
# dcu/fid. feed names of insts and txn files in from conf file into a
# hash?
#
# match txn and cat on word boundary.  dance is matching indenpendance
# grill into wrong category.
#
# refactor from one file into many, one class per file? lookup python style
#
# make a python module?
#
# unit tests for classes would be nice
#
# create conf file to load stuff
# - figure out how to store files for each year, use conf file to spec?
# - directory per year
#
#
# in 2014 checks in unknown cat.  Fix it... maybe walk unk category
# and update check file with new check for any dcu check txn in
# cats[unknown]
#
# Graphing
#
# - Report run needs to init total and series.. why? prolly init in
# - base class only so only base has that var.  var is shared among
# - instances? so.. you need to init in each child class, which may
# - mean calling __init__ in each child and have it call parent
# - __init__.

# - DONE Researched graph pkgs.. chose pygal for ease of use vs config.
#   boke something may also work?
#
# - DONE Created fixed cats graph per year and for all years.  Dup pattern
#   for other stuff?
