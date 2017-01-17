#! /usr/bin/env python
# -*- coding: utf-8 -*-

import sys

from Bio import SeqIO
from Bio import Entrez

__author__ = 'Matthew L. Bendall'
__copyright__ = "Copyright (C) 2017 Matthew L. Bendall"



def main(args):
    accessions = [l.strip('\n') for l in args.acc_list if not l.startswith('#')]    
    print >>sys.stderr, 'Searching for %d accessions...' % len(accessions)
        
    seqs = {}
    print >>sys.stderr, '\tLoading from %d files...' % len(args.fasta)
    for f in args.fasta:
        for s in SeqIO.parse(f, 'fasta'):
            fields = s.id.strip('|').split('|')
            ids = {fields[i]:fields[i+1] for i in range(0,len(fields),2)}
            myacc = ids['ref'].split('.')[0]
            seqs[myacc] = s

    print >>sys.stderr, '\tLoaded %d sequences.' % len(seqs)
            
    goodseqs = []
    notfound = []
    for acc in accessions:
        if acc not in seqs:
            notfound.append(acc)
        else:
            goodseqs.append(seqs[acc])
    
    print >>sys.stderr, 'Found %d accessions so far...' % len(goodseqs)
    
    if notfound:
        print >>sys.stderr, '\tSearching entrez for %d remaining accessions...' % len(notfound)
        if not args.email:
            sys.exit("Must provide email to NCBI in order to use Entrez")
        Entrez.email = args.email
        res = Entrez.read(Entrez.epost("nuccore", id=','.join(notfound)))
        handle = Entrez.efetch(db='nuccore', rettype='gb', retmode='text',
                               webenv=res['WebEnv'], query_key=res['QueryKey'])
        
        entrezseqs = [s for s in SeqIO.parse(handle, 'genbank')]
        for s in entrezseqs:
            sfeat = [f for f in s.features if f.type=='source']
            assert len(sfeat) == 1, 'Number of source features is incorrect:\n%s' % s
            sfeat = sfeat[0]
            assert 'db_xref' in sfeat.qualifiers, 'db_xref not in qualifiers:\n%s' % s
            q = dict(_.split(':') for _ in sfeat.qualifiers['db_xref'])
            assert 'taxon' in q, 'taxon not in db_xref:%s' % s
            newid = 'ti|%s|gi|0|ref|%s|' % (q['taxon'], s.id)
            s.id = s.name = newid
            s.description = '%s %s' % (newid, s.description)
            goodseqs.append(s)
    
    nseqs = SeqIO.write(goodseqs, args.outfile, 'fasta')
    print >>sys.stderr, 'Wrote %d sequences.' % nseqs

if __name__ == '__main__':                
    import argparse
    parser = argparse.ArgumentParser(description='Subset fasta with list of accessions')
    parser.add_argument('--email',
                        help='Email for Entrez')
    parser.add_argument('--fasta', action='append',
                        help='Fasta files to look for sequences')
    parser.add_argument('acc_list', type=argparse.FileType('rU'),
                        help='List of accessions')
    parser.add_argument('outfile', nargs='?', type=argparse.FileType('w'),
                        default=sys.stdout)                        
    main(parser.parse_args())
