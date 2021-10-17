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
TOTAL_COMMITS=0
TOTAL_MY_COMMITS=0
for a in $(cat $PUBLISHED) ; do
	(cd $CLONEDIR && git clone file://${GITDIR}/$a)
	COMMITS=$(cd $CLONEDIR/$a && git log --pretty=oneline|wc -l)
	TOTAL_COMMITS=$(expr $COMMITS + $TOTAL_COMMITS)
	MY_COMMITS=$(cd $CLONEDIR/$a && git log --pretty=email \
		| egrep "^From: " \
		| egrep "namhas|tleino" \
		| wc -l)
	TOTAL_MY_COMMITS=$(expr $MY_COMMITS + $TOTAL_MY_COMMITS)
done
CONTRIB_COMMITS=$(expr $TOTAL_COMMITS - $TOTAL_MY_COMMITS)

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
JS_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-path \*[.]js) | wc -l)
HTML_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-path \*[.]html) | wc -l)
ROFF_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-not -path \*majik3/lib\* \
	-path \*[.][123456789]) | wc -l)
AWK_LOC=$(cat $(find $CLONEDIR \
	-not -path \*/.git\* \
	-path \*[.]awk) | wc -l)

TOTAL_LOC=$(expr $C_LOC + $LPC_LOC + $JAVA_LOC + \
	$CPP_LOC + $SHELL_LOC + $AWK_LOC + $M4_LOC + $HTML_LOC + $ROFF_LOC + \
	$JS_LOC)

echo "<p>"
echo "Projects published: <b>$(ls -1 $CLONEDIR | wc -l)</b><br>"
echo "Published lines of code: <b>$TOTAL_LOC</b><br>"
echo "Total commits: <b>$TOTAL_COMMITS</b><br>"
echo "Commits from contributors: <b>$CONTRIB_COMMITS</b><br>"
echo "Last updated: <b>$(date +'%B %d, %Y')</b><br>"
echo "<pre>"
echo "C          <b>$C_LOC</b> lines"
echo "C++        <b>$CPP_LOC</b> lines"
echo "LPC        <b>$LPC_LOC</b> lines"
echo "Javascript <b>$JS_LOC</b> lines"
echo "Java       <b>$JAVA_LOC</b> lines"
echo "Shell      <b>$SHELL_LOC</b> lines"
echo "Roff       <b>$ROFF_LOC</b> lines"
echo "HTML       <b>$HTML_LOC</b> lines"
echo "AWK        <b>$AWK_LOC</b> lines"
echo "M4         <b>$M4_LOC</b> lines"
echo "</pre>"
echo "</p>"
