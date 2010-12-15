EXTRA_DIST = bitmaps/sgen.bmp bitmaps/qcon.bmp bitmaps/qcoff.bmp ftdetect/sbd.vim ftplugin/songbook.vim ftplugin/tex.vim spell/wordlist.txt spell/songbook.latin1.spl syntax/songbook.vim

installdirs-local:
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/bitmaps
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/ftdetect
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/ftplugin
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/spell
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/syntax

install-data-local: bitmaps/sgen.bmp bitmaps/qcon.bmp bitmaps/qcoff.bmp ftdetect/sbd.vim ftplugin/songbook.vim ftplugin/tex.vim spell/songbook.latin1.spl syntax/songbook.vim
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/bitmaps
	$(INSTALL_DATA) bitmaps/sgen.bmp $(DESTDIR)$(vimfilespath)/bitmaps
	$(INSTALL_DATA) bitmaps/qcon.bmp $(DESTDIR)$(vimfilespath)/bitmaps
	$(INSTALL_DATA) bitmaps/qcoff.bmp $(DESTDIR)$(vimfilespath)/bitmaps
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/ftdetect
	$(INSTALL_DATA) ftdetect/sbd.vim $(DESTDIR)$(vimfilespath)/ftdetect
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/ftplugin
	$(INSTALL_DATA) ftplugin/songbook.vim $(DESTDIR)$(vimfilespath)/ftplugin
	$(INSTALL_DATA) ftplugin/tex.vim $(DESTDIR)$(vimfilespath)/ftplugin
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/spell
	$(INSTALL_DATA) spell/songbook.latin1.spl $(DESTDIR)$(vimfilespath)/spell
	-$(mkdir_p) $(DESTDIR)$(vimfilespath)/syntax
	$(INSTALL_DATA) syntax/songbook.vim $(DESTDIR)$(vimfilespath)/syntax

uninstall-local:
	-rm -f $(DESTDIR)$(vimfilespath)/bitmaps/sgen.bmp $(DESTDIR)$(vimfilespath)/bitmaps/qcon.bmp $(DESTDIR)$(vimfilespath)/bitmaps/qcoff.bmp $(DESTDIR)$(vimfilespath)/ftdetect/sbd.vim $(DESTDIR)$(vimfilespath)/ftplugin/songbook.vim $(DESTDIR)$(vimfilespath)/ftplugin/tex.vim $(DESTDIR)$(vimfilespath)/spell/songbook.latin1.spl $(DESTDIR)$(vimfilespath)/syntax/songbook.vim

