/* Copyright (C) 2008 Kevin W. Hamlen
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA  02110-1301, USA.
 *
 * The latest version of this program can be obtained from
 * http://songs.sourceforge.net.
 */


#ifdef HAVE_CONFIG_H
#  include "config.h"
#else
#  include "vsconfig.h"
#endif

#ifdef HAVE_STDLIB_H
#  include <stdlib.h>
#endif

#include "chars.h"
#include "songidx.h"
#include "fileio.h"

/* skipesc(<ptr>)
 *   Walk <ptr> past any LaTeX macros or braces until we reach the next "real" character.
 */
void
skipesc(p)
	const WCHAR **p;
{
	for (;;)
	{
		if (**p == wc_backslash)
		{
			++(*p);
			if (wc_isalpha(**p)) while (wc_isalpha(**p)) ++(*p);
			else if (**p) ++(*p);
			while (wc_isspace(**p)) ++(*p);
		}
		else if (**p == wc_lbrace)
		{
			++(*p);
			while (wc_isspace(**p)) ++(*p);
		}
		else if (**p == wc_rbrace)
			++(*p);
		else
			break;
	}
}

/* songcmp(<song1>,<song2>)
 *   Return a negative number if <song1> is less than <song2>, a positive number if <song1>
 *   is greater than <song2>, and 0 if <song1> and <song2> are equal. The ordering is first
 *   by title, then by index. This function is suitable for use with qsort().
 */
int
songcmp(s1,s2)
	const void *s1;
	const void *s2;
{
	static WCHAR buf1[MAXLINELEN+1], *bp1;
	static WCHAR buf2[MAXLINELEN+1], *bp2;
	const WCHAR *t1 = (*((const SONGENTRY **) s1))->title;
	const WCHAR *t2 = (*((const SONGENTRY **) s2))->title;
	int diff;

	for (;;)
	{
		skipesc(&t1);
		while(*t1 && !wc_isalpha(*t1) && !wc_isdigit(*t1))
		{
			++t1;
			skipesc(&t1);
		}
		skipesc(&t2);
		while(*t2 && !wc_isalpha(*t2) && !wc_isdigit(*t2))
		{
			++t2;
			skipesc(&t2);
		}
		if ((*t1==wc_null) || (*t2==wc_null))
		{
			if ((*t1==wc_null) && (*t2==wc_null)) break;
			return (t1!=wc_null) ? 1 : -1;
		}
		if (wc_isdigit(*t1) || wc_isdigit(*t2))
		{
			long n1, n2;
			WCHAR *p1, *p2;
			if (!wc_isdigit(*t1)) return 1;
			if (!wc_isdigit(*t2)) return -1;
			n1 = ws_strtol(t1, &p1, 10);
			t1 = p1;
			n2 = ws_strtol(t2, &p2, 10);
			t2 = p2;
			if (n1 == n2) continue;
			return n1-n2;
		}
		for (bp1=buf1; wc_isalpha(*t1); skipesc(&t1)) *bp1++=wc_tolower(*t1++);
		for (bp2=buf2; wc_isalpha(*t2); skipesc(&t2)) *bp2++=wc_tolower(*t2++);
		*bp1 = *bp2 = wc_null;
		if ((diff = ws_coll(buf1,buf2)) != 0) return diff;
	}
	if (((*((const SONGENTRY **) s1))->title[0] == wc_asterisk)
	    && ((*((const SONGENTRY **) s2))->title[0] != wc_asterisk))
		return 1;
	if (((*((const SONGENTRY **) s1))->title[0] != wc_asterisk)
	    && ((*((const SONGENTRY **) s2))->title[0] == wc_asterisk))
		return -1;
	return (*((const SONGENTRY **) s1))->idx - (*((const SONGENTRY **) s2))->idx;
}
