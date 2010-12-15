#
#   Copyright (C) 2010  Kevin W. Hamlen
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
# AC_PATH_VIMFILES
#
# Test for a local vimfiles directory
# and set $vimfilespath to the correct value.
#
#
dnl @synopsis AC_PATH_VIMFILES
dnl
dnl This macro tests for a local vimfiles path and
dnl sets $vimfilespath to the correct value
dnl
dnl @version 1.0
dnl @author Kevin W. Hamlen
dnl
AC_DEFUN([AC_PATH_VIMFILES],[
AC_ARG_WITH([vimfiles-path],AC_HELP_STRING([--with-vimfiles-path=...],[specify vimfiles or .vim directory]),[
    if test ! "$withval" = "yes" ;
    then
        ac_cv_vimfiles_path="$withval"; export ac_cv_vimfiles_path;
    fi;
],[
    vimfilespath=""; export vimfilespath;
])
AC_REQUIRE([AC_PROG_VIM])
AC_CACHE_CHECK([for vimfiles path],[ac_cv_vimfiles_path],[
    if test "x$vim" = x ;
    then
        AC_MSG_WARN([Vim not found. Vim support files will not be installed.])
        ac_cv_vimfiles_path="";
    else
        ac_cv_vimfiles_path=`echo 'exe "norm i".$VIM | p | q!' | $vim -e -s`/vimfiles;
    fi;
    export ac_cv_vimfiles_path;
])
vimfilespath=$ac_cv_vimfiles_path; export vimfilespath;
AC_SUBST(vimfilespath)
])

