#!/bin/sh

which sloccount >/dev/null || exit 1
which git >/dev/null || exit 1
which mktemp >/dev/null || exit 1

GITDIR=/git
CLONEDIR=/tmp/allgit
for a in $(find $GITDIR -type d -maxdepth 1 | sed -n '2,$p') ; do
	(cd $CLONEDIR && git clone $a 1>/dev/null 2>/dev/null)
done
TOTAL=$(ls -1 $CLONEDIR | wc -l)
TMPFILE=$(mktemp /tmp/mkstatistics.XXXXXXXXX)
(cd $CLONEDIR && sloccount . >/$TMPFILE 2>/dev/null)
echo "Statistics last updated: <b>$(date +'%B %d, %Y')</b><br>"
echo "Published projects: <b>$TOTAL</b><br>"
cat $TMPFILE \
	| grep 'Total Physical' \
	| sed -e 's/ *=/:/' -e 's/: \(.*\)/: <b>\1<\/b>/' -e 's/$/<br>/'
cat $TMPFILE \
	| grep 'Total Estimated Cost to Develop' \
	| sed -e 's/ *=/:/' -e 's/: \(.*\)/: <b>\1<\/b> USD/' -e 's/$/<br>/' \
		-e 's/\$//'
echo "<pre>"
cat $TMPFILE \
	| sed -n -e '/Totals grouped by language/,/^$/p'
echo "</pre>"
echo "<div class='credit'>"
cat $TMPFILE \
	| grep 'Please credit' \
	| cut -d\" -f2- \
	| sed 's/"//g' \
	| sed 's/$/<br>/'
echo "</div>"
