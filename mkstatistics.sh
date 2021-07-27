#!/bin/sh

function sh_files {
	for a in $(find $1 -type f -not -path \*/.git\*) ; do
		if head -1 $a | grep '#!/bin/sh' >/dev/null ; then
			echo $a
		fi
	done
}

function m4_files {
	for a in $(find $1 \
	    -type f \
	    -not -path \*/.git\* \
	    -path \*.m4 \
	    -or -path \*.in \
	    -or -path \*.ac) ; do
		if file $a | grep 'M4 macro language' >/dev/null ; then
			echo $a
		fi
	done
}

function cpp_files {
	find $1 \
		-not -path \*/.git\* \
		-path \*[.]cpp \
		-or -path \*[.]hpp \
		-or -path \*[.]cc \
		-or -path \*[.]cxx
	for a in $(find $1 -type f \
	    -not -path \*/.git\* \
	    -path \*[.]h \
	    -not -path \*majik?/lib\*) ; do
		if head -1 $a | grep class >/dev/null ; then
			echo $a
		fi
	done
}

function cpp_loc {
	cat $(cpp_files $1) | wc -l
}

function shell_loc {
	cat $(sh_files $1) | wc -l
}

function m4_loc {
	cat $(m4_files $1) | wc -l
}

which git >/dev/null || exit 1

GITDIR=/git
PUBLISHED=/git/published
CLONEDIR=/tmp/allgit

if [ ! -x $CLONEDIR ] ; then
	mkdir $CLONEDIR
fi
for a in $(cat $PUBLISHED) ; do
	(cd $CLONEDIR && git clone file://${GITDIR}/$a)
done

SHELL_LOC=$(shell_loc $CLONEDIR)
CPP_LOC=$(cpp_loc $CLONEDIR)
M4_LOC=$(m4_loc $CLONEDIR)

C_LOC=$(cat $(find $CLONEDIR \
	-path \*[.][ch] \
	-not -path \*/.git\* \
	-not -path \*majik?/lib\*) | wc -l)
LPC_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-path \*majik?/lib\*[.][ch]) | wc -l)
JAVA_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-path \*[.]java) | wc -l)
AWK_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-path \*[.]awk) | wc -l)

TOTAL_LOC=$(expr $C_LOC + $LPC_LOC + $JAVA_LOC + \
	$CPP_LOC + $SHELL_LOC + $AWK_LOC + $M4_LOC)

echo "<p>"
echo "Projects published: <b>$(ls -1 $CLONEDIR | wc -l)</b><br>"
echo "Published lines of code: <b>\t$TOTAL_LOC</b><br>"
echo "Statistics last updated: <b>$(date +'%B %d, %Y')</b><br>"
echo "<pre>"
echo "C\t<b>$C_LOC</b> lines"
echo "C++\t<b>$CPP_LOC</b> lines"
echo "LPC\t<b>$LPC_LOC</b> lines"
echo "Java\t<b>$JAVA_LOC</b> lines"
echo "Shell\t<b>$SHELL_LOC</b> lines"
echo "AWK\t<b>$AWK_LOC</b> lines"
echo "M4\t<b>$M4_LOC</b> lines"
echo "</pre>"
echo "</p>"

