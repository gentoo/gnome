# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit autotools python-single-r1

if [[ ${PV} = 9999 ]]; then
	inherit git-r3
fi

DESCRIPTION="Translation tool for XML documents that uses gettext files and ITS rules"
HOMEPAGE="http://itstool.org/"
if [[ ${PV} = 9999 ]]; then
	EGIT_REPO_URI="https://github.com/itstool/itstool.git"
else
	SRC_URI="https://github.com/itstool/itstool/archive/${PV}.tar.gz"
fi

LICENSE="GPL-3+"
SLOT="0"

if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-linux"
fi

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
		dev-libs/libxml2[python,${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

src_prepare() {
	eapply_user
	eautoreconf
}

src_test() {
	suite="${S}"/tests/run_tests.py
	PYTHONPATH="." "${PYTHON}" ${suite} || die "test suite '${suite}' failed"
	unset suite
}
