#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys

from Bio import SeqIO

__author__ = 'Matthew L. Bendall'
__copyright__ = "Copyright (C) 2017 Matthew L. Bendall"

def main(args):
    for s in SeqIO.parse(args.fasta, 'fasta'):
        # Set the new ID
        if args.delim:
            acc = s.id.split(args.delim)[args.idx]
        else:
            acc = s.id.split()[args.idx]
        newdef = 'ti|%s|gi|000|ref|%s| %s' % (args.taxid, acc, s.id)
        # Remove gaps from sequence
        newseq = str(s.seq).replace('-','').upper()
        # Print sequence
        print >>args.outfile, '>%s' % newdef
        for i in range(0, len(newseq), 60):
            print >>args.outfile, newseq[i:i+60]

if __name__ == '__main__':             
    import argparse
    parser = argparse.ArgumentParser(description='Add taxon ID to FASTA file')
    parser.add_argument('--idx', type=int, default=0,
                        help='index to find accession (after split)')
    parser.add_argument('--delim',
                        help='delimiter to split sequence name. Default is whitespace')
    parser.add_argument('taxid',
                        help='taxonomy ID to add to sequence name')
    parser.add_argument('fasta',
                        help='Fasta file')
    parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'),
                        default=sys.stdout)                        
    main(parser.parse_args())