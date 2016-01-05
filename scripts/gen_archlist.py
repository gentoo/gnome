#!/usr/bin/env python2
# vim: set sw=4 sts=4 et :
# Author(s): Nirbheek Chauhan <nirbheek@gentoo.org>
#
# Given a category/package list, and (optionally) a new/old release number,
# generates a STABLEREQ list, or a KEYWORDREQ list.
#
# Toggle STABLE to control which type of list to generate.
#
# You can use test-data/package-list to test the script out.
#
# NOTE: This script assumes that there are no broken keyword deps
#
# BUGS:
# * belongs_release() is a very primitive function, which means usage of
#   old/new release numbers gives misleading output
# * Will show multiple versions of the same package in the output sometimes.
#   This happens when a cp is specified in the cpv list, and is resolved as
#   a dependency as well.
# TODO:
# * Support recursive checking of needed keywords in deps
#

from __future__ import division, print_function

import argparse
import collections
import logging
import logging.config

import portage

logger = logging.getLogger('gen_archlist')

#############
# Constants #
#############
# GNOME_OVERLAY = PORTDB.getRepositoryPath('gnome')
portage.portdb.porttrees = [portage.settings['PORTDIR']]
STABLE_ARCHES = ('alpha', 'amd64', 'arm', 'hppa', 'ia64', 'ppc', 'ppc64',
                 'sparc', 'x86')
UNSTABLE_ARCHES = ('~alpha', '~amd64', '~arm', '~hppa', '~ia64', '~m68k',
                   '~ppc', '~ppc64', '~s390', '~sh', '~sparc', '~x86',
                   '~x86-fbsd')
ALL_ARCHES = STABLE_ARCHES + UNSTABLE_ARCHES
SYSTEM_PACKAGES = []

############
# Settings #
############
CHECK_DEPS = False
# Check for stable keywords
# This is intended to switch between keywordreq (for ~arch)
# and stablereq (for moving from ~arch to arch)
STABLE = True

# if not STABLE:
#     print 'Currently broken for anything except STABLEREQ'
#     print 'Please set STABLE to True'
#     sys.exit(1)

###############
# Preparation #
###############

ARCHES = None
if STABLE:
    ARCHES = STABLE_ARCHES
else:
    ARCHES = UNSTABLE_ARCHES


####################
# Define Functions #
####################
def make_unstable(kws):
    """Transform `kws` into a list of unstable keywords."""
    return set([
        kwd if kwd.startswith('~') else '~' + kwd
        for kwd in kws
    ])


def belongs_release(cpv, release):
    """Check if `cpv` belongs to the release `release`."""
    # FIXME: This failure function needs better logic
    if CHECK_DEPS:
        raise Exception('This function is utterly useless with RECURSIVE mode')
    return portage.versions.cpv_getversion(cpv).startswith(release)


def issystempackage(cpv):
    for i in SYSTEM_PACKAGES:
        if cpv.startswith(i):
            return True
    return False


def get_kws(cpv, arches=ARCHES):
    """Return keywords of `cpv` filtered by `arches`."""
    return set([
        kwd for kwd in portage.portdb.aux_get(cpv, ['KEYWORDS'])[0].split()
        if kwd in arches
    ])


def can_stabilize_cpv(cpv, release=None):
    """Whether `cpv` matches stabilization criteria.

    `cpv` must:
    * belong to the release
    * not be p.masked
    * have keywords
    """
    if release and not belongs_release(cpv, release):
        return False
    if not portage.portdb.visible([cpv]):
        return False
    if not get_kws(cpv, arches=ALL_ARCHES):
        return False
    return True


def match_wanted_atoms(atom, release=None):
    """Return a list of CPV matching `atom`.

    If `release` is provided, CPVs are filtered against it.

    The list is sorted by descending order of version.
    """
    # xmatch is stupid, and ignores ! in an atom...
    if atom.startswith('!'):
        return []

    return [
        cpv for cpv in reversed(portage.portdb.xmatch('match-all', atom))
        if can_stabilize_cpv(cpv, release)
    ]


def get_best_deps(cpv, kws, release=None):
    """
    Returns a list of the best deps of a cpv, optionally matching a release,
    and with max of the specified keywords
    """
    # Take raw dependency strings and convert it to a list of atoms
    atoms = portage.portdb.aux_get(cpv, ['DEPEND', 'RDEPEND', 'PDEPEND'])
    atoms = ' '.join(atoms).split()  # consolidate atoms
    atoms = list(set(atoms))  # de-duplicate

    deps = set()

    for atom in atoms:
        if not portage.isvalidatom(atom):
            continue

        cpvs = match_wanted_atoms(atom, release)
        if not cpvs:
            logger.debug('Encountered an irrelevant atom: %s', atom)
            continue

        best_cpv_kws = ['', []]
        for candidate_cpv in cpvs:
            if STABLE:
                # Check that this version has unstable keywords
                unstable_kws = make_unstable(kws)
                cur_unstable_kws = make_unstable(
                    get_kws(candidate_cpv, arches=kws | unstable_kws)
                )
                if cur_unstable_kws.intersection(unstable_kws) != unstable_kws:
                    best_cpv_kws[0] = 'none'
                    logger.debug('Insufficiant unstable keywords in: %s',
                                 candidate_cpv)
                    continue

            candidate_kws = get_kws(candidate_cpv, arches=kws)
            if candidate_kws == kws:
                # This dep already has all requested keywords
                best_cpv_kws[0] = 'alreadythere'
                break

            # Select the version which needs least new keywords
            if len(candidate_kws) > len(best_cpv_kws[1]):
                best_cpv_kws = [candidate_cpv, candidate_kws]
            elif not best_cpv_kws[0]:
                # This means that none of the versions have any of the stable
                # keywords that *we checked* (i.e. kws).
                best_cpv_kws = [candidate_cpv, []]

        if best_cpv_kws[0] == 'alreadythere':
            logger.debug('DEP %s is already %s, ignoring', atom,
                         'stable' if STABLE else 'keyworded')
            continue
        elif best_cpv_kws[0] == 'none':
            continue
        elif not best_cpv_kws[0]:
            # We get this when the if STABLE: block above rejects everything.
            # This means that this atom does not have any versions with
            # unstable keywords matching the unstable keywords of the cpv
            # that pulls it.
            # This mostly happens because an || or use dep exists. However, we
            # make such deps strict while parsing
            # XXX: We arbitrarily select the most recent version for this case
            deps.add(cpvs[0])
        elif not best_cpv_kws[1]:
            # This means that none of the versions have any of the stable
            # keywords that *we checked* (i.e. kws). Hence, we do another pass;
            # this time checking *all* keywords.
            #
            # XXX: We duplicate some of the things from the for loop above
            # We don't need to duplicate anything that caused a 'continue' or
            # a 'break' above
            cpvs = match_wanted_atoms(atom, release)
            best_cpv_kws = ['', []]
            for candidate_cpv in cpvs:
                cur_kws = get_kws(candidate_cpv)
                if len(cur_kws) > len(best_cpv_kws[1]):
                    best_cpv_kws = [candidate_cpv, cur_kws]
                elif not best_cpv_kws[0]:
                    # This means that none of the versions have any of
                    # the stable keywords *at all*. No choice but to
                    # arbitrarily select the latest version in that case.
                    best_cpv_kws = [candidate_cpv, []]

            deps.add(best_cpv_kws[0])
        else:
            deps.add(best_cpv_kws[0])

    return list(deps)


def max_kws(cpv, release=None):
    """Build `cpv` maximum expected keyword coverage.

    Find the intersection of "most keywords it can have" and
    "keywords it has", and returns a sorted list

    If STABLE; makes sure it has unstable keywords right now

    Returns [] if current cpv has best keywords
    Returns None if no cpv has keywords
    """
    current_kws = set(get_kws(cpv, arches=ALL_ARCHES))
    maximum_kws = set()  # Maximum keywords that a cpv has
    missing_kws = set()

    # Build best keyword coverage for `cpv`
    for atom in match_wanted_atoms('<=' + cpv, release):
        kws = get_kws(atom)

        # Consider stable keywords only
        if STABLE:
            kws = [kwd for kwd in kws if not kwd.startswith('~')]

        maximum_kws.update(set(kws))

    # Build list of keywords missing to achieve best coverage
    for kwd in maximum_kws:
        # Skip stable keywords with no corresponding unstable keyword in `cpv`
        if STABLE and '~' + kwd not in current_kws:
            continue
        missing_kws.add(kwd)

    if maximum_kws:
        return missing_kws
    else:
        # No cpv has the keywords we need
        return None


# FIXME: This is broken
def kws_wanted(current_kws, target_kws):
    """Generate a list of kws that need to be updated."""
    wanted = set()
    for kwd in target_kws:
        if STABLE and '~' + kwd not in current_kws:
            # Skip stable keywords with no corresponding unstable keyword
            continue
        wanted.add(kwd)
    return wanted


def gen_cpv_kws(cpv, kws_aim, depgraph, check_dependencies, new_release):
    """Build a list of CPV-Keywords.

    If `check_dependencies` is True, append dependencies that need to be
    updated to the list.
    """
    wanted = kws_wanted(get_kws(cpv, arches=ALL_ARCHES), kws_aim)

    if not wanted:
        # This happens when cpv has less keywords than kws_aim
        # Usually happens when a dep was an || dep, or under a USE-flag
        # which is masked in some profiles. We make all deps strict in
        # get_best_deps()
        # So... let's just stabilize it on all arches we can, and ignore for
        # keywording since we have no idea about that.
        if not STABLE:
            logger.warn('MEH')
            logger.info('DEP %s is already %s, ignoring', cpv,
                        'stable' if STABLE else 'keyworded')
            return None

        wanted = get_kws(cpv, arches=make_unstable(kws_aim))

    cpv_kw_list = [(cpv, wanted)]

    if check_dependencies and not issystempackage(cpv):
        deps = get_best_deps(cpv, wanted, release=new_release)
        logger.debug('Dependencies of %s are: %s', cpv, deps)

        for dep in deps:
            if dep in depgraph:
                # XXX: assumes that `kws_aim` of previously added cpv is
                #      larger than current
                continue

            depgraph.add(dep)
            # XXX: Assumes that dependencies are keyworded the same than cpv
            dep_deps = gen_cpv_kws(dep, wanted, depgraph, check_dependencies,
                                   new_release)
            dep_deps.reverse()

            for cpv_kw_tuple in dep_deps:
                # Make sure we don't already have the same [(cpv, kws)]
                if cpv_kw_tuple not in cpv_kw_list:
                    cpv_kw_list.append(cpv_kw_tuple)

    cpv_kw_list.reverse()
    return cpv_kw_list


def consolidate_dupes(cpv_kws):
    """Consolidate duplicate CPVs with differing keywords.

    Cannot handle CPs with different versions since we don't know if they are
    inter-changeable.
    """
    # Build maximum requested keywords for each cpv
    cpv_kws_dict = collections.defaultdict(set)
    for dep_set in cpv_kws:
        for cpv, kws in dep_set:
            cpv_kws_dict[cpv].update(kws)

    # Update cpv with their maximum request keywords
    clean_cpv_kws = []
    for dep_set in cpv_kws:
        clean_cpv_kws.append([
            (cpv, cpv_kws_dict.pop(cpv))
            # Keep only first occurence of cpv
            for cpv, _ in dep_set if cpv in cpv_kws_dict
        ])

    return clean_cpv_kws


def get_per_slot_cpvs(cpvs):
    """Return best CPV per slot.

    Classify the CPVs into slots, and yield the best atom for each slot.
    This only works with a pre-sorted list as returned by `match_wanted_atoms`.
    """
    slots = set()
    for cpv in cpvs:
        slot = portage.portage.portdb.aux_get(cpv, ['SLOT'])[0]
        if slot in slots:
            continue
        slots.add(slot)
        yield cpv


def append_slots(cpv_kws):
    """Append slots at the end of cpv atoms"""
    slotifyed_cpv_kws = []
    for cpv, kws in cpv_kws:
        slot = portage.portage.portdb.aux_get(cpv, ['SLOT'])[0]
        cpv = "%s:%s" % (cpv, slot)
        slotifyed_cpv_kws.append([cpv, kws])
    return slotifyed_cpv_kws


def print_cpv_kws(cpv_kws):
    """Takes a list of [cpv, [kws]] and prettifies it"""
    max_len = 0
    kws_all = set()

    for dep_set in cpv_kws:
        for cpv, kws in dep_set:
            # Find the atom with max length (for output formatting)
            max_len = max(max_len, len(cpv))
            # Find the set of all kws listed
            kws_all.update(kws)

    for dep_set in cpv_kws:
        for cpv, kws in dep_set:
            pretty_line = cpv + ' ' * (max_len - len(cpv))

            for kwd in sorted(kws_all):
                if kwd in kws:
                    pretty_line += ' ' + kwd
                else:
                    pretty_line += ' ' + ' ' * len(kwd)

            print(pretty_line)

        if len(dep_set) > 1:
            print()

    return


#####################
# Use the Functions #
#####################
# cpvs that will make it to the final list
def main():
    """Where the magic happens!"""
    parser = argparse.ArgumentParser(
        description='Generate a stabilization request for multiple packages'
    )
    parser.add_argument('-v', '--verbose', action='count',
                        help='Make output more verbose')
    parser.add_argument('--check-dependencies',
                        action='store_true', default=False,
                        help='Check dependencies are keyworded and if not,'
                             ' add them to the list')
    parser.add_argument('--append-slots', action='store_true', default=False,
                        help='Append slots to CPVs output')
    parser.add_argument('file', help='File to read CP from')
    parser.add_argument('old_version', nargs='?',
                        help='An optional argument specifying which release'
                             ' cycle to use to get CPVs which has the'
                             ' reference keywords for stabilization.')
    parser.add_argument('new_version', nargs='?',
                        help='An optional argument specifying which release'
                             ' cycle to use to get the latest CPVs that needs'
                             ' to be stabilized')
    args = parser.parse_args()

    args.verbose = min(max(args.verbose, 0), 2)
    logging.config.dictConfig({
        'version': 1,
        'disable_existing_loggers': True,
        'formatters': {
            'brief': {'format': '%(message)s'},
        },
        'handlers': {
            'console': {
                'class': 'logging.StreamHandler',
                'level': 'DEBUG',
                'formatter': 'brief',
                'stream': 'ext://sys.stdout',
            },
        },
        'loggers': {
            'gen_archlist': {
                'handlers': ['console'],
                'level': [logging.WARN, logging.INFO,
                          logging.DEBUG][args.verbose],
            },
        },
        'root': {
            'handler': ['console'],
        },
    })

    all_cpv_kws = []
    for line in open(args.file).readlines():
        cp = line.strip()

        # Filter useless lines
        if not cp or cp.startswith('#'):
            continue

        if '#' in cp:
            raise Exception('Inline comments are not supported')

        # Convert line to CPV(s)
        if portage.catpkgsplit(cp):
            # cat/pkg is already a categ/pkg-ver
            cpvs = [cp]
        else:
            # Get all the atoms matching the given CP
            cpvs = match_wanted_atoms(cp, release=args.new_version)

        for cpv in get_per_slot_cpvs(cpvs):
            if not cpv:
                logger.warn('%s is an invalid CPV', cpv)
                continue

            kws_missing = max_kws(cpv, release=args.old_version)
            if kws_missing is None:
                logger.info('No versions with stable keywords for %s', cpv)
                # No cpv with stable keywords => select latest
                arches = make_unstable(ARCHES)
                kws_missing = [kw[1:] for kw in get_kws(cpv, arches)]

            elif not kws_missing:
                # Current cpv has the max keywords => nothing to do
                logger.info('CPV %s is already %s, ignoring', cpv,
                            'stable' if STABLE else 'keyworded')
                continue

            all_cpv_kws.append(
                gen_cpv_kws(cpv, kws_missing, set([cpv]),
                            args.check_dependencies, args.new_version)
            )

    all_cpv_kws = consolidate_dupes(all_cpv_kws)
    if args.append_slots:
        all_cpv_kws = append_slots(all_cpv_kws)

    print_cpv_kws(all_cpv_kws)


if __name__ == '__main__':
    main()
