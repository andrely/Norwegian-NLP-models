from glob import glob
import logging
from optparse import OptionParser
import os
from random import sample
from shutil import copyfile
import sys

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)

    parser = OptionParser(usage="%prog -c <CORPUS_DIR> -s <SAMPLE_DIR>")
    parser.add_option("-c", "--corpus-dir", dest='corpus_dir', default=None,
                      help="Wiki corpus directory")
    parser.add_option("-s", "--sample-dir", dest='sample_dir', default=None,
                      help="Directory to sample to.")
    parser.add_option("-n", "--num-samples", dest='num_samples', default=100, type=int,
                      help="Number of article samples to collect.")

    options, args = parser.parse_args()

    if not options.corpus_dir:
        parser.print_help(sys.stderr)
        exit(1)

    if not options.sample_dir:
        parser.print_help(sys.stderr)
        exit(1)

    if not os.path.isdir(options.corpus_dir):
        logging.error("can't find wiki corpus directory" % options.corpus_dir)
        exit(1)

    raw_dir = os.path.join(options.corpus_dir, 'raw')
    sample_raw_dir = os.path.join(options.sample_dir, 'raw')

    if not os.path.isdir(options.sample_dir):
        logging.info("creating sample directory %s" % options.sample_dir)
        os.makedirs(sample_raw_dir)

    logging.info("sampling %d files from %s to %s" %
                 (options.num_samples, options.corpus_dir, options.sample_dir))

    files = [fn for fn in glob(os.path.join(options.corpus_dir, "*")) if os.path.isfile(fn)]

    sampled_files = sample(files, options.num_samples)

    logging.info("copying files")

    for fn in sampled_files:
        base_fn = os.path.basename(fn)

        copyfile(fn, os.path.join(options.sample_dir, base_fn))
        copyfile(os.path.join(raw_dir, base_fn + '.raw'),
                 os.path.join(sample_raw_dir, base_fn + '.raw'))
