# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="xml"

inherit autotools python-single-r1

DESCRIPTION="Translation tool for XML documents that uses gettext files and ITS rules"
HOMEPAGE="http://itstool.org/"
SRC_URI="https://github.com/itstool/itstool/archive/${PV}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64  ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~arm-linux ~x86-linux"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-libs/libxml2[${PYTHON_USEDEP}]"
DEPEND="${RDEPEND}"

src_prepare() {
	eapply "${FILESDIR}/${P}-segfault.patch"
	python_fix_shebang .
	eapply_user
	eautoreconf
}

src_test() {
	suite="${S}"/tests/run_tests.py
	PYTHONPATH="." "${PYTHON}" ${suite} || die "test suite '${suite}' failed"
	unset suite
}
