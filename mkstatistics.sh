#!/bin/sh

which sloccount >/dev/null || exit 1
which git >/dev/null || exit 1
which mktemp >/dev/null || exit 1

GITDIR=/git
PUBLISHED=/git/published
CLONEDIR=/tmp/allgit
if [ -x $CLONEDIR ] ; then
	echo "Deleting $CLONEDIR ..."
	sleep 2
	rm -rf $CLONEDIR
fi
mkdir $CLONEDIR
for a in $(cat $PUBLISHED) ; do
	(cd $CLONEDIR && git clone file://${GITDIR}/$a)
done
echo find /tmp/allgit -path \*/.git\* -delete
sleep 2
find /tmp/allgit -path \*/.git\* -delete
TOTAL=$(ls -1 $CLONEDIR | wc -l)
TMPFILE=$(mktemp /tmp/mkstatistics.XXXXXXXXX)
(cd $CLONEDIR && sloccount --crossdups --addlangall . >/$TMPFILE 2>/dev/null)
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
